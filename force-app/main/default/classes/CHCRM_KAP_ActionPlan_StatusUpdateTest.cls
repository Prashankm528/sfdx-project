/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_ActionPlan_StatusUpdate_Ctrl
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_ActionPlan_StatusUpdateTest {
    
    @testSetup
    static void testSetup(){        
        Account acc = CHCRM_TestSetup.createWorkshopAccount('Account1');
        acc.CHCRM_Key_Account_Flg__c = true;
        insert acc;
        CHCRM_Sub_Channel_Account__c subChannelAccouont = CHCRM_TestSetup.createSubChannelAccount(acc.Id , 'Test1SubChannel', 'SCA-TEST-0001');
        insert subChannelAccouont;
        CHCRM_Sub_Channel_Sub_Account__c subChannelSubAccount = CHCRM_TestSetup.createSubChannelSubAccount(subChannelAccouont.Id , 'Test1SubChannelSub' ,'SCSA-TEST-0001','102201');
        insert subChannelSubAccount;
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(subChannelAccouont.Id , '2020');
        insert kap;
        CHCRM_KAP_Action_Plan__c plan = CHCRM_TestSetup.createKAPActionPlan(kap.Id, 'TestPlan');
        insert plan;
    }
    
    static testMethod void getExeStatusTest(){        
        CHCRM_KAP_Action_Plan__c plan = [SELECT Id FROM CHCRM_KAP_Action_Plan__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        // This code runs as the system user
        Profile profile = [SELECT Id , Name FROM Profile WHERE Name='System Administrator'];
        User systemUser = new User(Alias = 'standt',
                          EmailEncodingKey='UTF-8', LastName='Testing', 
                          TimeZoneSidKey='America/Los_Angeles',
                          LocaleSidKey='en_US', ProfileId = profile.Id,
                          LanguageLocaleKey='en_US',
                           Email='standarduser@testorg.com',
                          UserName='standarduser' + DateTime.now().getTime() + '@testorg.com');
        System.runAs(systemUser) {
            Test.startTest();
            Event e1 = new Event(Subject = 'Test' , 
                                 OwnerId = UserInfo.getUserId() , 
                                 StartDateTime = Datetime.now() , 
                                 EndDateTime = Datetime.now().addMinutes(30) , 
                                 Description = 'Test Description');
            e1.WhatId = plan.Id;
            e1.SOM_Status__c = 'Completed';
            insert e1;
            Test.stopTest();
            String result = CHCRM_KAP_ActionPlan_StatusUpdate_Ctrl.getExeStatus(plan.Id);            
            System.assertEquals('Success', result);
        }
    }

}