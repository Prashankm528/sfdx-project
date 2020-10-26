/**
* @author: Gabriela Matos
* @date: 22/06/2020
* @group: BPCM
* @description: Test cover for BPCM_TaskService.cls
* @name BPCM_TaskService_Test.cls
*/

@isTest
public with sharing class BPCM_TaskService_Test {

    @TestSetup
    static void setupUsers(){
        BPCM_TestDataFactory.addGroupMember('BPCM_All_Users', UserInfo.getUserId());
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor1', 'BPCM_All_Users');
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor2', 'BPCM_All_Users');
    }

    static testMethod void shouldCountInboundCallsNewCase_OnCaseTouchHist_2(){

        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, BPCM_Category__c, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCase(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId);
            cs.BPCM_Category__c = 'Becoming a member';
            update cs;
            Task tk = BPCM_TestDataFactory.createTask(true, BPCM_GlobalConstants.TK_INB_CALL_TYPE, contactId, cs.Id, 'Call', 'Completed', BPCM_GlobalConstants.TK_CALL_REC_TYPE);   
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
        //automation in place to create an inbound call for Case origin 'Phone Call'
        System.assertEquals(2, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        //testing case update as well based on metadata
        System.assertEquals(1, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldCountInboundCallsInProgressCase_OnCaseTouchHist_1(){

        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        User advisor2 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor2){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');   
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
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor2.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldCountOutboundCallsInProgressCase_OnCaseTouchHist_1(){

        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        User advisor3 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor3){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            Task tk = BPCM_TestDataFactory.createTask(true, BPCM_GlobalConstants.TK_OUT_CALL_TYPE, contactId, cs.Id, 'Call', 'Completed', BPCM_GlobalConstants.TK_CALL_REC_TYPE);   
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
        System.assertEquals(1, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor3.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldCountOutInbCallsInProgressCase_OnCaseTouchHist_Multi(){

        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];
        User advisor2 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor2@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        //4 case touches: 3 inbound calls, and 1 outbound call
        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            Task tk = BPCM_TestDataFactory.createTask(true, BPCM_GlobalConstants.TK_OUT_CALL_TYPE, contactId, cs.Id, 'Call', 'Completed', BPCM_GlobalConstants.TK_CALL_REC_TYPE);
            Task tk2 = BPCM_TestDataFactory.createTask(true, BPCM_GlobalConstants.TK_INB_CALL_TYPE, contactId, cs.Id, 'Call', 'Completed', BPCM_GlobalConstants.TK_CALL_REC_TYPE); 
        }

        //1 case touch: 1 inbound calls
        System.runAs(advisor2){
            Task tk = BPCM_TestDataFactory.createTask(true, BPCM_GlobalConstants.TK_INB_CALL_TYPE, contactId, cs.Id, 'Call', 'Completed', BPCM_GlobalConstants.TK_CALL_REC_TYPE);
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
        System.assertEquals(2, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(1, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);

        System.assertEquals(cs.Id, cthList[1].BPCM_Case__c);
        System.assertEquals(0, cthList[1].BPCM_Comments__c);
        System.assertEquals(1, cthList[1].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[1].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[1].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[1].BPCM_Tasks__c);
        System.assertEquals(advisor2.Id, cthList[1].BPCM_UserId__c);
    }

    static testMethod void shouldCountTasks_OnCaseTouchHist_1(){

        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId, 'In Progress');
            Task tk = BPCM_TestDataFactory.createTask(true, BPCM_GlobalConstants.TK_OTHER_TYPE, contactId, cs.Id, 'Followup', 'Completed', BPCM_GlobalConstants.TK_TASK_REC_TYPE);   
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
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(1, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldAutomaticallyLogACall_NewCasePhoneCall(){

        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Case cs;
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);

        System.runAs(advisor){
            cs = BPCM_TestDataFactory.createCase(true, 'New Case', 'Please check my homecharge', 'Phone Call', 'BPCM_General_EV', contactId);   
        }
        Test.stopTest();

        List<Task> tkList = [SELECT Type, Subject, Description, OwnerId, WhatId, WhoId FROM Task WHERE WhatId = :cs.Id];

        System.assert(!tkList.isEmpty(), 'Log Call record has not been created!');
        System.assertEquals(cs.Id, tkList[0].WhatId);
        System.assertEquals(contactId, tkList[0].WhoId);
        System.assertEquals(BPCM_GlobalConstants.TK_INB_CALL_TYPE, tkList[0].Type);
        System.assertEquals(cs.Subject, tkList[0].Subject);
        System.assertEquals(cs.Description, tkList[0].Description);
    }
}