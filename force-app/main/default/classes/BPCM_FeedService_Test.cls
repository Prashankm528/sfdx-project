/**
* @author: Gabriela Matos
* @date: 19/06/2020
* @group: BPCM
* @description: Test cover for BPCM_FeedService.cls
* @name BPCM_FeedService_Test.cls
*/

@isTest
public with sharing class BPCM_FeedService_Test {
   
    @TestSetup
    static void setupUsers(){
        BPCM_TestDataFactory.addGroupMember('BPCM_All_Users', UserInfo.getUserId());
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor1', 'BPCM_All_Users');
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor2', 'BPCM_All_Users');
    }

    static testMethod void shouldCountCommentsFeedItem_OnCaseTouchHist_1(){

        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'In Progress');
        
        System.runAs(advisor){
            FeedItem fi = BPCM_TestDataFactory.createFeedItem(true, cs.Id);
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
                                                    
        System.assert(!cthList.isEmpty(), 'Case Touch History has not been created!');
        System.assertEquals(cs.Id, cthList[0].BPCM_Case__c);
        System.assertEquals(1, cthList[0].BPCM_Comments__c);
        System.assertEquals(0, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldCountCommentsFeedItem_OnCaseTouchHist_2(){

        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];
        User advisor2 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor2@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'In Progress');

        System.runAs(advisor){
            FeedItem fi = BPCM_TestDataFactory.createFeedItem(true, cs.Id);
        }

        System.runAs(advisor2){
            FeedItem fi2 = BPCM_TestDataFactory.createFeedItem(true, cs.Id);
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

        System.assert(!cthList.isEmpty(), 'Case Touch History has not been created!');
        System.assertEquals(cs.Id, cthList[0].BPCM_Case__c);
        System.assertEquals(1, cthList[0].BPCM_Comments__c);
        System.assertEquals(0, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);

        System.assertEquals(cs.Id, cthList[1].BPCM_Case__c);
        System.assertEquals(1, cthList[1].BPCM_Comments__c);
        System.assertEquals(0, cthList[1].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[1].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[1].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[1].BPCM_Tasks__c);

        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
        System.assertEquals(advisor2.Id, cthList[1].BPCM_UserId__c);
    }

    static testMethod void shouldCountCommentsFeedComment_OnCaseTouchHist_2(){

        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];
        User advisor2 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor2@bpcm.com.testclass' LIMIT 1];
        FeedItem fi;

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'In Progress');
        
        System.runAs(advisor){
            fi = BPCM_TestDataFactory.createFeedItem(true, cs.Id);
        }

        System.runAs(advisor2){
            FeedComment fc = BPCM_TestDataFactory.createFeedComment(true, cs.Id, fi.Id, 'Great!');
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

        System.assert(!cthList.isEmpty(), 'Case Touch History has not been created!');
        System.assertEquals(cs.Id, cthList[0].BPCM_Case__c);
        System.assertEquals(1, cthList[0].BPCM_Comments__c);
        System.assertEquals(0, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);

        System.assertEquals(cs.Id, cthList[1].BPCM_Case__c);
        System.assertEquals(1, cthList[1].BPCM_Comments__c);
        System.assertEquals(0, cthList[1].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[1].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[1].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[1].BPCM_Tasks__c);

        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
        System.assertEquals(advisor2.Id, cthList[1].BPCM_UserId__c);
    }

    static testMethod void shouldCountCommentsFeedComment_OnCaseTouchHist_3(){

        FeedItem fi;
        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];
        User advisor2 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor2@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'In Progress');

        System.runAs(advisor){
            fi = BPCM_TestDataFactory.createFeedItem(true, cs.Id);
        }

        System.runAs(advisor2){
            FeedComment fc = BPCM_TestDataFactory.createFeedComment(true, cs.Id, fi.Id, 'Great!');
        }

        System.runAs(advisor){
            FeedComment fc = BPCM_TestDataFactory.createFeedComment(true, cs.Id, fi.Id, 'Thanks!');
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

        System.assert(!cthList.isEmpty(), 'Case Touch History has not been created!');
        System.assertEquals(cs.Id, cthList[0].BPCM_Case__c);
        System.assertEquals(2, cthList[0].BPCM_Comments__c);
        System.assertEquals(0, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);

        System.assertEquals(cs.Id, cthList[1].BPCM_Case__c);
        System.assertEquals(1, cthList[1].BPCM_Comments__c);
        System.assertEquals(0, cthList[1].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Emails__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[1].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[1].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[1].BPCM_Tasks__c);

        System.assertEquals(advisor.Id, cthList[0].BPCM_UserId__c);
        System.assertEquals(advisor2.Id, cthList[1].BPCM_UserId__c);
    }
}