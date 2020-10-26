/********************************************************************************
* Date           : 27-MAR-2020
* Author         : Roselin Hephzibah
* Description    : Test class for GCM_ANZ_Bot_Handler
* Modifications  : 27-MAR-2020 Roselin - Initial
: 01-APR-2020 Roselin - Test coverage for GCM_ContentDownloadHandlerFactoryImpl
********************************************************************************/ 
@isTest
public class GCM_ANZ_Bot_Handler_Test {
/****************************************************************************************************
Testmethod to cover GCM_ANZ_Bot_Handler.
****************************************************************************************************/
    static testMethod void anzBotHandlerTest() {
        
        List<Id> caseIdList = new List<Id>();
        List<Id> caseIdNoEmailList = new List<Id>();
        List<Profile> profileList = [Select Id, Name from Profile Where Name Like: 'GCM%'];
        
        Group grp = new Group();
        grp.Type = 'Queue';
        grp.Name = 'GCM ANZ AU LOT BOT';
        insert grp;
        QueueSobject mappingObject = new QueueSobject(QueueId = grp.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;}
        
        Group grp1 = new Group();
        grp1.Type = 'Queue';
        grp1.Name = 'GCM ANZ Lubes VOC BOT';
        insert grp1;
        QueueSobject mappingObject1 = new QueueSobject(QueueId = grp1.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject1;}
        
        
        
        //GCM User Creation
        User u = new User(Alias = 'standt', Email='gbssfcustomerbotuser@bp.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = profileList[0].Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testBOT@bp.com.customer.gcmdev');

        
        //Create Case
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.OwnerId = grp.Id;
        cs.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs;
        
        Case cs1 = new Case();
        cs1.Subject = 'Test';
        cs1.OwnerId = grp1.Id;
        cs1.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs1;
        caseIdList.add(cs1.Id);
        
        Case cs2 = new Case();
        cs2.Subject = 'Test';
        cs2.OwnerId = grp1.Id;
        cs2.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs2;
        caseIdList.add(cs2.Id);
        
        Case cs3 = new Case();
        cs3.Subject = 'Test';
        cs3.OwnerId = grp.Id;
        cs3.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs3;
        caseIdNoEmailList.add(cs3.Id);
        
        Case cs4 = new Case();
        cs4.Subject = 'Test';
        cs4.OwnerId = grp.Id;
        cs4.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs4;
        caseIdList.add(cs4.Id);
        
        Case cs5 = new Case();
        cs5.Subject = 'Test';
        cs5.OwnerId = grp.Id;
        cs5.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs5;
        caseIdList.add(cs5.Id);
        
        //Insert EmailMessage
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.Subject = 'subject';
        emailMsg.Headers = '"Header_Date":"Wed, 8 Jan 2020 09:27:25 +0000"';
        emailMsg.TextBody = 'messageText';
        emailMsg.FromAddress = 'roselin.hephzibah@bp.com';
        emailMsg.ToAddress = 'rhephzi1@in.ibm.com';
        emailMsg.status = '1';
        emailMsg.Incoming = true;
        String str = '2019-12-06T11:04:10+00:00';
        emailMsg.messagedate = (DateTime)Json.deserialize('"'+str+'"', DateTime.class);
        emailMsg.parentId = cs1.Id;
        insert emailMsg;
        
        EmailMessage emailMsg1 = new EmailMessage();
        emailMsg1.Subject = 'subject';
        emailMsg1.Headers = '"Header_Date":"Wed, 8 Jan 2020 09:27:25 +0000"';
        emailMsg1.TextBody = 'messageText';
        emailMsg1.FromAddress = 'roselin.hephzibah@bp.com';
        emailMsg1.ToAddress = 'rhephzi1@in.ibm.com';
        emailMsg1.status = '1';
        emailMsg1.Incoming = true;
        String str1 = '2019-12-06T11:04:10+00:00';
        emailMsg1.messagedate = (DateTime)Json.deserialize('"'+str1+'"', DateTime.class);
        emailMsg1.parentId = cs.Id;
        insert emailMsg1;
        
        EmailMessage emailMsg2 = new EmailMessage();
        emailMsg2.Subject = 'subject';
        emailMsg2.Headers = '"Header_Date":"Wed, 8 Jan 2020 09:27:25 +0000"';
        emailMsg2.TextBody = 'messageText';
        emailMsg2.FromAddress = 'roselin.hephzibah@bp.com';
        emailMsg2.ToAddress = 'rhephzi1@in.ibm.com';
        emailMsg2.status = '1';
        emailMsg2.Incoming = true;
        String str2 = '2019-12-06T11:04:10+00:00';
        emailMsg2.messagedate = (DateTime)Json.deserialize('"'+str2+'"', DateTime.class);
        emailMsg2.parentId = cs4.Id;
        insert emailMsg2;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl.LinkedEntityId = emailMsg.Id;
        insert cdl;

        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.ContentDocumentId = cvList[1].ContentDocumentId;
        cdl1.LinkedEntityId = emailMsg.Id;
        insert cdl1;

		ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = cvList[1].ContentDocumentId;
        cdl2.LinkedEntityId = cs2.Id;
        insert cdl2; 
        
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = cvList[1].ContentDocumentId;
        cdl3.LinkedEntityId = cs5.Id;
        insert cdl3; 
        
        ContentDocumentLink cdl4 = new ContentDocumentLink();
        cdl4.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl4.LinkedEntityId = cs5.Id;
        insert cdl4;
        
        List<Id> cancelCaseIdList = new List<Id>();
        cancelCaseIdList.add(cs.Id);
        
        List<Id> invalidCaseIdList = new List<Id>();
        invalidCaseIdList.add(emailMsg.Id);
        
        Test.startTest();
        //Call controller methods
        GCM_ANZ_Bot_Handler.addAttachmentRecords(caseIdList);
        GCM_ANZ_Bot_Handler.addAttachmentRecords(caseIdNoEmailList);
        System.runAs(u) {
            ContentVersion cv2 = new ContentVersion();
            cv2.Title = 'Test Document';
            cv2.PathOnClient = 'TestDocument.pdf';
            cv2.VersionData = Blob.valueOf('Test Content');
            cv2.IsMajorVersion = true;
            Insert cv2;
            List<ContentVersion> cvList1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion];
            system.debug('cvlist1'+cvlist1);
            GCM_ANZ_Bot_Attachment__c botAttach  = new GCM_ANZ_Bot_Attachment__c();
            botAttach.GCM_Content_Document_Id__c = cvList1[0].ContentDocumentId;
            botAttach.GCM_Downloaded__c = false;
            insert botAttach;
            
            GCM_ContentDownloadHandlerFactoryImpl cdh = new GCM_ContentDownloadHandlerFactoryImpl();
            cdh.getContentDownloadHandler(new List<Id>{cv2.Id}, null);
        }
        GCM_ANZ_Bot_Handler.cancelLOTCase(invalidCaseIdList);
        GCM_ContentDownloadHandlerFactoryImpl cdh = new GCM_ContentDownloadHandlerFactoryImpl();
        cdh.getContentDownloadHandler(new List<Id>{cv1.Id}, null);
        Test.stopTest();
        
        
        //Assert Statements
        List<GCM_ANZ_Bot_Attachment__c> attachList = [Select Id From GCM_ANZ_Bot_Attachment__c WHERE GCM_content_Document_Id__c =: cvList[0].ContentDocumentId];
        System.assertEquals(attachList.size(), 1);
    }
}