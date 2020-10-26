/***********************************************************************************************
 * @author           Xc
 * @date             2020/04/01
 * @group            CHCRM
 * @description      Test class for CHCRM_EventTriggerHandler and CHCRM_EventProcess

 * history
 * 2020/04/01  Xc  Created 
 ************************************************************************************************/
@isTest
private with sharing class CHCRM_EventTriggerHandlerTest {
    @testSetup
    static void testSetup(){
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        Account workshop = CHCRM_TestSetup.createWorkshopAccount('Test Workshop');
        insert workshop;

        CHCRM_HQ_Monthly_Assgmnt_Obj__c hqAssignmentObj = CHCRM_TestSetup.createHQMonthlyAssgmntObj(CHCRM_TestSetup.CHCRM_HQASSGMNTOBJ_OEMHQ_RECORDTYPE,'Draft','LTT',null);
        insert hqAssignmentObj;

        CHCRM_HQ_Monthly_Assgmnt__c hqAssignment = CHCRM_TestSetup.createHQMonthlyAssgmnt(CHCRM_TestSetup.CHCRM_HQASSGMNT_OEMHQ_RECORDTYPE,hqAssignmentObj.Id,workshop.Id,'Accepted','Uncovered');
        insert hqAssignment;
    }

   	static testMethod void testInsertAndDeleteHandler() {
        CHCRM_HQ_Monthly_Assgmnt__c hqAssignment = [Select Id,CHCRM_Acceptance_Status__c FROM CHCRM_HQ_Monthly_Assgmnt__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        try{            
            List<Event> events = CHCRM_TestSetup.createEvents(1);
            events[0].WhatId = hqAssignment.Id;
            //hqAssignment.CHCRM_Acceptance_Status__c = 'Rejected';
            update hqAssignment;
            insert events;
        }catch(Exception error){
            System.assert(error.getMessage().contains('请将关联总部任务状态标记为"已接受"后再继续操作！'));
        }

        try{            
            List<Event> events = CHCRM_TestSetup.createEvents(1);
            events[0].WhatId = hqAssignment.Id;
            //hqAssignment.CHCRM_Acceptance_Status__c = 'No reply';
            update hqAssignment;
            insert events;
        }catch(Exception error){
            System.assert(error.getMessage().contains('请将关联总部任务状态标记为"已接受"后再继续操作！'));
        }

        /*try{            
            List<Event> events = CHCRM_TestSetup.createEvents(1);
            events[0].WhatId = hqAssignment.Id;
            hqAssignment.CHCRM_Acceptance_Status__c = 'Accepted';
            update hqAssignment;
            events[0].StartDateTime = Datetime.newInstance(Date.Today().Year() + 1, Date.Today().Month() + 1, 1,12,0,0);
            events[0].EndDateTime = Datetime.newInstance(Date.Today().Year() + 1, Date.Today().Month() + 1, 1,12,30,0);
            insert events;
        }catch(Exception error){
            System.assert(error.getMessage().contains('拜访开始时间与所关联总部任务年份或月份不符！'));
        }*/
        
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        events[0].WhatId = hqAssignment.Id;
        events[0].StartDateTime = Datetime.newInstance(Date.Today().Year(), Date.Today().Month(), 1,12,0,0);
        events[0].EndDateTime = Datetime.newInstance(Date.Today().Year(), Date.Today().Month(), 1,12,30,0);
        insert events;
        //delete events;     
    }
    
    static testMethod void testInsertHandler(){
        CHCRM_HQ_Monthly_Assgmnt__c hqAssignment = [Select Id,CHCRM_Acceptance_Status__c FROM CHCRM_HQ_Monthly_Assgmnt__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        try{
            List<Event> events = CHCRM_TestSetup.createEvents(1);
            events[0].WhatId = hqAssignment.Id;
            //hqAssignment.CHCRM_Acceptance_Status__c = 'Rejected';
            update hqAssignment;
            insert events;
        }catch(Exception error){
            System.assert(error.getMessage().contains('请将关联总部任务状态标记为"已接受"后再继续操作！'));
        }
    }

    static testMethod void testUpdateHandler() {
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        CHCRM_HQ_Monthly_Assgmnt__c hqAssignment = [Select Id,CHCRM_Acceptance_Status__c FROM CHCRM_HQ_Monthly_Assgmnt__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        insert events;
        events[0].WhatId = hqAssignment.Id;
        events[0].SOM_Status__c = 'Completed';
        update events;
        Event e = [SELECT Id,Subject FROM Event WHERE Id =:events[0].Id LIMIT 1];
        System.assertEquals(e.Subject,'【总部任务】---Test Workshop+LTT');
        hqAssignment = [Select Id,CHCRM_Covered_Status__c FROM CHCRM_HQ_Monthly_Assgmnt__c LIMIT 1];
        System.assertEquals('Covered', hqAssignment.CHCRM_Covered_Status__c);
    }

    static testMethod void testPopulateVisitDetailFields() {
        List<Event> events = CHCRM_TestSetup.createEvents(1);        
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        insert events;
        events[0].SOM_Status__c = 'Completed';
        Datetime curTime = System.now().addMinutes(10);
        events[0].StartDateTime = curTime;
        update events[0];
        CHCRM_Event__c resulte = [SELECT ID , CHCRM_Start_Date__c FROM CHCRM_Event__c limit 1 ];
        System.assertEquals(curTime , resulte.CHCRM_Start_Date__c);
    }
}