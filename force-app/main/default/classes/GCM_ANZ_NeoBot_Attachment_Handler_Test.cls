/********************************************************************************
* Date           : 18-SEP-2020
* Author         : IBM
* Description    : Test class for GCM_ANZ_NeoBot_Attachment_Handler
* Modifications  : 

********************************************************************************/ 
@isTest
public class GCM_ANZ_NeoBot_Attachment_Handler_Test {
    
    /****************************************************************************************************
	Testmethod to cover GCM_ANZ_NeoBot_Attachment_Handler.
	****************************************************************************************************/
    @testSetup
    static void setupTestData() {
        List<Case> cases = new List<Case>();
        List<Profile> lubeCsrProfile = [Select Id, Name from Profile Where Name Like: 'GCM_Fuels_CSR_GSYS'];
        Id customerAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id fuelsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GCM_Fuels').getRecordTypeId();
        Id nbOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFR_ANZ_NewBusiness').getRecordTypeId();
        //GCM User Creation
        User csrUser = new User(Alias = 'standt', Email='gbssfneobotuser@bp.com', 
                          EmailEncodingKey='UTF-8', LastName='NeoBotUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = lubeCsrProfile[0].Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testNeoBOT@bp.com.customer.gcmdev',
                          GCM_User_Team__c='GCM NeoBOT Test');
        System.runAs(csrUser){
            
            Account testAccount1 = new Account();
        	testAccount1.Name = 'Test Account 1';
			testAccount1.RecordTypeId = customerAccRecordTypeId;
            testAccount1.AccountNumber = '110011';
			insert testAccount1;

			// Create Opportunity
        	Opportunity testOppp1 = new Opportunity();
        	testOppp1.RecordTypeId = nbOppRecordTypeId;
        	testOppp1.Name = 'Test Opportunity 1';
        	testOppp1.OwnerId = csrUser.Id;
			testOppp1.StageName = 'Development';
			testOppp1.AccountId = testAccount1.Id;
			testOppp1.CloseDate = Date.today();            
			Database.insert(testOppp1);
            
            Case request1 = new Case();
            request1.RecordTypeId = fuelsCaseRecordTypeId;
            request1.Subject = 'Test Bot Case 1';
            request1.Description = 'Test Bot Case 1 Desc';
            request1.SuppliedEmail = 'testemail@bp.com.invalid';
            request1.GCM_Opportunity__c = testOppp1.Id;
            request1.Type = 'Card';
            request1.Area__c = 'New Card';
            request1.Sub_Area__c = 'CMT';
            request1.GCM_ByPassValidation_Timestamp__c = Datetime.now();
            cases.add(request1);
            insert cases;
            
            ContentVersion cv1 = new ContentVersion();
            cv1.Title = 'Test Document1';
            cv1.PathOnClient = 'TestDocument.csv';
            cv1.VersionData = Blob.valueOf('Test CSV Content1');
            cv1.IsMajorVersion = true;
            Insert cv1;
            
            cv1 = [Select Id, ContentDocumentId from ContentVersion where Id = :cv1.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
        	cdl.ContentDocumentId = cv1.ContentDocumentId;
        	cdl.LinkedEntityId = request1.Id;
        	insert cdl;
        }
                
    }
/****************************************************************************************************
Testmethod to cover GCM_ANZ_NeoBot_Attachment_Handler create Staging table records.
****************************************************************************************************/
    static testMethod void createBOTAttachmentTest() {
        
        User csrUser = [Select Id, UserName from User where LastName = 'NeoBotUser' limit 1][0];
        List<GCM_Neo_Bot_Event__e> events = new List<GCM_Neo_Bot_Event__e>();
        Case case1 = [Select Id from Case where Subject = 'Test Bot Case 1' limit 1][0];
        ContentDocumentLink contentLink = [Select Id, ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId = :case1.Id Limit 1][0];
        System.runAs(csrUser){
            
            Test.startTest();                    
                GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent event = new GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent();
                event.linkedEntityId = contentLink.LinkedEntityId;
                event.contentDocumentId = contentLink.ContentDocumentId;
                event.fileAlias ='CMT';
                GCM_ANZ_NeoBot_Attachment_Handler.upsertBOTAttachment(new List<GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent>{event});        
            Test.stopTest();
        
            List<GCM_ANZ_Bot_Attachment__c> attachments = [Select Id, GCM_File_Alias__c from GCM_ANZ_Bot_Attachment__c where GCM_Case_Id__c = :contentLink.LinkedEntityId and GCM_Content_Document_Id__c = :contentLink.ContentDocumentId];
            System.assertEquals(true, attachments.size() > 0, 'At least one BOT Attachment should be created.');
            System.assertEquals('CMT', attachments[0].GCM_File_Alias__c, 'At least one BOT Attachment should be created.');
        }
        
    }
/****************************************************************************************************
Testmethod to cover GCM_ANZ_NeoBot_Attachment_Handler update Staging table records.
****************************************************************************************************/
    static testMethod void updateBOTAttachmentTest() {
        
        User csrUser = [Select Id, UserName from User where LastName = 'NeoBotUser' limit 1][0];
        List<GCM_Neo_Bot_Event__e> events = new List<GCM_Neo_Bot_Event__e>();
        Case case1 = [Select Id from Case where Subject = 'Test Bot Case 1' limit 1][0];
        ContentDocumentLink contentLink = [Select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :case1.Id Limit 1][0];
        System.runAs(csrUser){  
            
        	Test.startTest();                            
                GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent event = new GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent();
                event.linkedEntityId = contentLink.LinkedEntityId;
                event.contentDocumentId = contentLink.ContentDocumentId;
                event.fileAlias ='CMT';
                GCM_ANZ_NeoBot_Attachment_Handler.upsertBOTAttachment(new List<GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent>{event});
                //Setting linkedEntityId to blank for Update scenario
                event.linkedEntityId = '';
                event.fileAlias ='MainCSV';
                GCM_ANZ_NeoBot_Attachment_Handler.upsertBOTAttachment(new List<GCM_ANZ_NeoBot_Attachment_Handler.NeoBotEvent>{event});        
            Test.stopTest();
        
          	List<GCM_ANZ_Bot_Attachment__c> attachments = [Select Id, GCM_File_Alias__c from GCM_ANZ_Bot_Attachment__c where GCM_Case_Id__c = :contentLink.LinkedEntityId and GCM_Content_Document_Id__c = :contentLink.ContentDocumentId];
            System.assertEquals(true, attachments.size() > 0, 'At least one BOT Attachment should be created.');
            System.assertEquals('MainCSV', attachments[0].GCM_File_Alias__c, 'At least one BOT Attachment should be created.');
    	}
    }    
}