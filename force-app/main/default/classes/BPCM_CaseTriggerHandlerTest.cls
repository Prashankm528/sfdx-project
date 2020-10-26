/**
* @author     Sushant Sethi
* @date       11 June 2020
* @description    Test class for BPCM_CaseTriggerHandler class  
* 
*  
*/
@isTest(SeeAllData=False)
public with sharing class BPCM_CaseTriggerHandlerTest {
    
/**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() {
        BPCM_TestDataFactory.addGroupMember('BPCM_All_Users', UserInfo.getUserId());
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor1', 'BPCM_All_Users');
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor2', 'BPCM_All_Users');
    }
/**
* @description - test setup method for updating case fields from AutoSetup Records
*/
    @isTest
    public static void updateCaseRecords() {
        
        //Create Automation Setup Object Record 1
        BPCM_Automation_Setup__c autoSetOne = BPCM_TestDataFactory.createAutomationSetup(true, 1, 'Active', 
        'BPCM_Keyword', 'TESTING12345,TESTING1234', 'BPCM_Account', 'CYC', 'Account renewal', 'N/A', '3-Medium');
        
        //Create Automation Setup Object Record 2
        BPCM_Automation_Setup__c autoSetTwo = BPCM_TestDataFactory.createAutomationSetup(true, 2, 'Active', 
        'BPCM_Keyword', 'Red Light, Fire', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');
        
        //Fetch BPCM Case Record Type
        string caseRecID = [SELECT id from RecordType where DeveloperName ='BPCM_Account' AND SobjectType = 'Case'].Id;
        //Fetch QueueId
        string ownerID = [SELECT id from Group where Type = 'Queue' and DeveloperName='BPCM_CPS_Tier_1'].Id;
        
        //Test Case Creation
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecID;
        testCase.OwnerId = ownerID;
        testCase.Subject='TESTING12345';
        testCase.Description = 'This is description of Case for TESTING12345';
        testCase.Origin='Email';
        testCase.SuppliedName = 'Test';
        testCase.SuppliedEmail = 'test@test.com';
        
        Test.startTest(); 
        insert testCase;
        System.assert(testCase.Id != null, 'Case inserted');
        
        // for update case
        string changeownerID = [SELECT id from Group where Type = 'Queue' and DeveloperName='BPCM_CPS_Tier_2'].Id;
        string caseID = [SELECT id from case where Id = : testCase.Id].Id;
        
        //Test Case Updation
        testCase.Id=caseID;
        testCase.OwnerId = changeownerID;
        
        update testCase;
        Test.stopTest();
        
        //Fetch the fields of the Case Record Inserted
        testCase = [ Select id, BPCM_Category__c, BPCM_Subcategory__c, BPCM_Further_Subcategory__c,Priority,Origin,BPCM_Business_Unit__c
                     from case 
                     where id=:testcase.id];
        
        //The below assert statements tests that the Case fields are set from the Automation Setup Record with a lower process order(1)
        system.assertEquals(testCase.BPCM_Category__c,'CYC');
        system.assertEquals(testCase.BPCM_Subcategory__c,'Account renewal');
        system.assertEquals(testCase.BPCM_Further_Subcategory__c,'N/A');
        system.assertEquals(testCase.Priority,'3-Medium');
        }

    static testMethod void shouldCountCaseTransfer_OnCaseTouchHist_1(){
        
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        
        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            cs.OwnerId = BPCM_TestDataFactory.getQueueIdByName('BPCM_CS_Tier_2');
            update cs;
        }
        Test.stopTest();

        List<BPCM_Case_Touch_History__c> cthList = [SELECT Id, BPCM_UserId__c, 
                                                            BPCM_Inbound_Calls__c,
                                                            BPCM_Outbound_Calls__c,
                                                            BPCM_Outbound_Emails__c,
                                                            BPCM_Outbound_Social_Posts__c,
                                                            BPCM_Tranfers__c,
                                                            BPCM_Comments__c,
                                                            BPCM_Case_Updates__c,
                                                            BPCM_Tasks__c,
                                                            BPCM_Case__c
                                                    FROM BPCM_Case_Touch_History__c
                                                    WHERE BPCM_Case__c =: cs.Id];

        System.assertEquals(cs.Id, cthList[0].BPCM_Case__c);
        System.assertEquals(0, cthList[0].BPCM_Comments__c);
        System.assertEquals(1, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(1, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldCountCaseUpdate_OnCaseTouchHist_1(){
        
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            cs.BPCM_Category__c = 'Becoming a member';
            cs.BPCM_Subcategory__c = 'Tariff Enquiry';
            cs.BPCM_Further_Subcategory__c = 'N/A';
            cs.Status = 'Closed';
            cs.Reason = 'Enquiry';
            cs.BPCM_Customer_Consent_to_Close__c = true;
            update cs;
        }
        Test.stopTest();

        List<BPCM_Case_Touch_History__c> cthList = [SELECT Id, BPCM_UserId__c, 
                                                            BPCM_Inbound_Calls__c,
                                                            BPCM_Outbound_Calls__c,
                                                            BPCM_Outbound_Emails__c,
                                                            BPCM_Outbound_Social_Posts__c,
                                                            BPCM_Tranfers__c,
                                                            BPCM_Comments__c,
                                                            BPCM_Case_Updates__c,
                                                            BPCM_Tasks__c,
                                                            BPCM_Case__c
                                                    FROM BPCM_Case_Touch_History__c
                                                    WHERE BPCM_Case__c =: cs.Id];

        System.assertEquals(cs.Id, cthList[0].BPCM_Case__c);
        System.assertEquals(0, cthList[0].BPCM_Comments__c);
        System.assertEquals(1, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(1, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldNOTCountCaseUpdate_OnCaseTouchHist_0(){
        
        //setting which case field will track if it has changed
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            cs.Subject = 'Becoming a member';
            cs.Description = 'How can I Becoming a member?';
            update cs;
        }
        Test.stopTest();

        List<BPCM_Case_Touch_History__c> cthList = [SELECT Id, BPCM_UserId__c, 
                                                            BPCM_Inbound_Calls__c,
                                                            BPCM_Outbound_Calls__c,
                                                            BPCM_Outbound_Emails__c,
                                                            BPCM_Outbound_Social_Posts__c,
                                                            BPCM_Tranfers__c,
                                                            BPCM_Comments__c,
                                                            BPCM_Case_Updates__c,
                                                            BPCM_Tasks__c,
                                                            BPCM_Case__c
                                                    FROM BPCM_Case_Touch_History__c
                                                    WHERE BPCM_Case__c =: cs.Id
                                                      AND BPCM_Case_Updates__c = 1];

        System.assert(cthList.isEmpty(), 'Case Touch History: Case update created!');
    }

    static testMethod void shouldSetCaseStatusToClosed_Insert(){

        //setting which case field will track if it has changed
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(false, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'New');
            cs.BPCM_Customer_Consent_to_Close__c = true;
            cs.BPCM_Category__c = 'Public Charge';
            cs.BPCM_Subcategory__c = 'Charge not delivering';
            cs.BPCM_Further_Subcategory__c = 'N/A';
            cs.Reason = 'Complaint';
            insert cs;
        }
        Test.stopTest();

        List<Case> csList = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_CLOSED, csList[0].Status);
    }

    static testMethod void shouldSetCaseStatusToClosed_Update(){

        //setting which case field will track if it has changed
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            cs.BPCM_Customer_Consent_to_Close__c = true;
            cs.BPCM_Category__c = 'Public Charge';
            cs.BPCM_Subcategory__c = 'Charge not delivering';
            cs.BPCM_Further_Subcategory__c = 'N/A';
            cs.Reason = 'Complaint';
            update cs;
        }
        Test.stopTest();

        List<Case> csList = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_CLOSED, csList[0].Status);
    }

    static testMethod void shouldSetNewCaseStatusToInProgressPhoneCall_Insert(){

        //setting which case field will track if it has changed
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'New');
        }
        Test.stopTest();

        List<Case> csList = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_IN_PROGRESS, csList[0].Status);
    }

    static testMethod void shouldSetCaseStatusToInProgress_Update(){

        //setting which case field will track if it has changed
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'New');
            cs.BPCM_Category__c = 'Public Charge';
            update cs;
        }
        Test.stopTest();

        List<Case> csList = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_IN_PROGRESS, csList[0].Status);
    }

    static testMethod void shouldNotSetCaseStatusToInProgress_Update(){

        //setting which case field will track if it has changed
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
		User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'New');
            cs.Subject = 'Testing should not consider as its not part of the settings';
            update cs;
        }
        Test.stopTest();

        List<Case> csList = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_NEW, csList[0].Status);
    }

    static testMethod void shouldSetCaseStatusToAssigned_Update(){

        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];
        Group csTier1Queue = new Group(Name='CS Tier 1 Test', Type='Queue');
        insert csTier1Queue;

        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = csTier1Queue.id, SObjectType = 'Case');
            insert testQueue;
        }

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(false, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'New');
        cs.OwnerId = csTier1Queue.Id;
        insert cs;
        Test.stopTest();

        List<Case> csList = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_NEW, csList[0].Status);

        System.runAs(advisor){
            cs.OwnerId = advisor.Id;
            update cs;
        }

        List<Case> csList2 = [SELECT Status FROM Case WHERE Id = :cs.Id];

        System.assert(!csList2.isEmpty(), 'Case record has not been created!');
        System.assertEquals(BPCM_GlobalConstants.CASE_STATUS_ASSIGNED, csList2[0].Status);
    }
 
}