/***********************************************************************************************
 * @author           Xc
 * @date             2020/05/25
 * @group            CHCRM
 * @description      Test class for CHCRM_VisitDetailTriggerHandler and CHCRM_VisitDetailProcess

 * history
 * 2020/04/01  Xc  Created 
 ************************************************************************************************/
@isTest
public with sharing class CHCRM_VisitDetailTriggerHandlerTest {
    @testSetup
    static void testSetup(){
        List<User> userList = new List<User>();
        User wm1 = CHCRM_TestSetup.createUser('visitdetail1','CHCRM Sales Executive','CHCRM_FWS_CER_WM');
        User wm2 = CHCRM_TestSetup.createUser('visitdetail2','CHCRM Sales Executive','CHCRM_FWS_CSR_WM');
        userList.add(wm1);
        userList.add(wm2);
        insert userList;

    }

    static testMethod void testInsertAndUpdateHandler() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        User u1;
        User u2;
        List<User> uList = [SELECT Id,UserName FROM User WHERE Username LIKE 'testchcrmvisitdetail%'];
        System.assertEquals(2, uList.size());
        for(User u : uList) {
            if(u.UserName.startsWith('testchcrmvisitdetail1')) {
                u1 = u;
            } else {
                u2 = u;
            }
        }
        System.runAs(u1) {
            List<Event> eventList = CHCRM_TestSetup.createEvents(1);
            insert eventList;
            CHCRM_Event__c visitDetail = [SELECT Id,OwnerId,CHCRM_Region__c FROM CHCRM_Event__c LIMIT 1];
            System.assertEquals('East China', visitDetail.CHCRM_Region__c);
            visitDetail.OwnerId = u2.Id;
            //update visitDetail;
            //CHCRM_Event__c updVisitDetail = [SELECT Id,OwnerId,CHCRM_Region__c FROM CHCRM_Event__c LIMIT 1];
            //System.assertEquals('South China', updVisitDetail.CHCRM_Region__c);
        }
        Test.stopTest();
    }
}