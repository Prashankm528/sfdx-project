/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_ActionEventController
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_ActionEventControllerTest {
    
    @testSetup
    static void testSetup(){        
        Account eventAcc = CHCRM_TestSetup.createWorkshopAccount('EventAccount');
        eventAcc.CHCRM_Key_Account_Flg__c = true;
        insert eventAcc;
        Id accId = eventAcc.Id;
        CHCRM_Sub_Channel_Account__c subChannelAccouont
            = CHCRM_TestSetup.createSubChannelAccount(accId , 
                                                      'EventSubChannel', 'SCA-TEST-0001');
        insert subChannelAccouont;
        Id subId = subChannelAccouont.Id;       
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(subId , '2020');
        insert kap;
        CHCRM_KAP_Action_Plan__c plan = CHCRM_TestSetup.createKAPActionPlan(kap.Id, 'TestPlan');
        insert plan;
        CHCRM_Event__c visit = new CHCRM_Event__c(CHCRM_KAP_Actual_Completion_Date__c = System.today() -1 ,CHCRM_KAP_Actual_Start_Date__c = System.today() +1 , CHCRM_KAP_Remark__c = 'Test');
        insert visit;
    }
    
    static testMethod void initDataListTest(){
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        CHCRM_KAP_Action_Plan__c plan = [SELECT Id FROM CHCRM_KAP_Action_Plan__c LIMIT 1];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        System.runAs(u) {
            Test.startTest();
            CHCRM_Event__c visit = [SELECT Id FROM CHCRM_Event__c LIMIT 1];
            Event e1 = new Event(Subject = 'Test' , OwnerId = UserInfo.getUserId() , StartDateTime = Datetime.now() , EndDateTime = Datetime.now().addMinutes(30) , Description = 'Test Description');
            e1.CHCRM_Event__c = visit.Id;
            e1.WhatId = plan.Id;
            insert e1;            
            CHCRM_KAP_ActionEventController.Wrapper wrapper = CHCRM_KAP_ActionEventController.initDataList(plan.Id);
            CHCRM_KAP_ActionEventController.EventItem item = wrapper.eventDatatable[0];
            Test.stopTest();
            System.assertEquals('Test', item.remark);
        }
    }

}