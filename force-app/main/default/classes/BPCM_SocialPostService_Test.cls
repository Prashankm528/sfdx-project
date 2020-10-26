/**
* @author: Gabriela Matos
* @date: 20/06/2020
* @group: BPCM
* @description: Test cover for BPCM_SocialPostService.cls
* @name BPCM_SocialPostService_Test.cls
*/

@isTest
public with sharing class BPCM_SocialPostService_Test {

    @TestSetup
    static void setupUsers(){
        BPCM_TestDataFactory.addGroupMember('BPCM_All_Users', UserInfo.getUserId());
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor1', 'BPCM_All_Users');
        BPCM_TestDataFactory.createAdvisorUser('TestClassAdvisor2', 'BPCM_All_Users');
    }
    
    static testMethod void shouldCountOutSocialPost_OnCaseTouchHist_1(){

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'In Progress');
        SocialPersona sPers = BPCM_TestDataFactory.createSocialPersona(true, 'John Smith', 'John Smith', 'Twitter', 'Twitter','2345556', contactId);
        SocialPost sp = BPCM_TestDataFactory.createSocialPost(true, 'Twitter', sPers.Id, cs.Id, true);
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
        System.assertEquals(0, cthList[0].BPCM_Comments__c);
        System.assertEquals(0, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(1, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(0, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(UserInfo.getUserId(), cthList[0].BPCM_UserId__c);
    }

    static testMethod void shouldCountOutSocialPost_OnCaseTouchHist_2(){

        User advisor = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor1@bpcm.com.testclass' LIMIT 1];
        User advisor2 = [SELECT Id FROM User WHERE UserName = 'TestClassAdvisor2@bpcm.com.testclass' LIMIT 1];

        Test.startTest();
        Account acc = BPCM_TestDataFactory.createPersonAccount(true, 'John', 'Smith', 'john@smith.com', '+44 7668987654', 'BPCM_Consumer');
        Id contactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(acc.Id);
        Case cs = BPCM_TestDataFactory.createCaseWithStatus(true, 'New Case', 'Please check my homecharge', 'Email', 'BPCM_General_EV', contactId, 'In Progress');
        SocialPersona sPers = BPCM_TestDataFactory.createSocialPersona(true, 'John Smith', 'John Smith', 'Twitter', 'Twitter','2345556', contactId);
        SocialPost sp = BPCM_TestDataFactory.createSocialPost(true, 'Twitter', sPers.Id, cs.Id, false);

        System.runAs(advisor2){
            SocialPost sp1 = BPCM_TestDataFactory.createSocialPost(true, 'Twitter', sPers.Id, cs.Id, true);
        }

        System.runAs(BPCM_TestDataFactory.getAdminUser()){
            SocialPost sp2 = BPCM_TestDataFactory.createSocialPost(true, 'Twitter', sPers.Id, cs.Id, false);
        }

        System.runAs(advisor){
            SocialPost sp3 = BPCM_TestDataFactory.createSocialPost(true, 'Twitter', sPers.Id, cs.Id, true);
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
        System.assertEquals(0, cthList[0].BPCM_Comments__c);
        System.assertEquals(0, cthList[0].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[0].BPCM_Outbound_Emails__c);
        System.assertEquals(1, cthList[0].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[0].BPCM_Tranfers__c);
        System.assertEquals(1, cthList[0].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[0].BPCM_Tasks__c);
        System.assertEquals(advisor2.Id, cthList[0].BPCM_UserId__c);

        System.assertEquals(cs.Id, cthList[1].BPCM_Case__c);
        System.assertEquals(0, cthList[1].BPCM_Comments__c);
        System.assertEquals(0, cthList[1].BPCM_Inbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Calls__c);
        System.assertEquals(0, cthList[1].BPCM_Outbound_Emails__c);
        System.assertEquals(1, cthList[1].BPCM_Outbound_Social_Posts__c);
        System.assertEquals(0, cthList[1].BPCM_Tranfers__c);
        System.assertEquals(1, cthList[1].BPCM_Case_Updates__c);
        System.assertEquals(0, cthList[1].BPCM_Tasks__c);
        System.assertEquals(advisor.Id, cthList[1].BPCM_UserId__c);
    }
}