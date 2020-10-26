/***********************************************************************************************
 * @author           Xc
 * @date             2020/04/01
 * @group            CHCRM
 * @description      Test class for CHCRM_ViewEventController

 * history
 * 2020/04/01  Xc  Created 
 * 2020/07/21 WuTong Updated
 ************************************************************************************************/
@isTest
private with sharing class CHCRM_ViewEventControllerTest {


    /**
    * @description test queryEvent method
    * @param  null
    * @return void
    */
    static testMethod void testQueryEvent() {
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        insert events;
      	Event e = [SELECT Id,OwnerId,CHCRM_Event__c,RecordType.DeveloperName ,CHCRM_HQ_Mnthly_Assgmnt__c , SOM_Status__c FROM Event LIMIT 1];
      	CHCRM_Event__c ce = [SELECT Id FROM CHCRM_Event__c LIMIT 1];
        CHCRM_ViewEventController.eventWrapper evView = CHCRM_ViewEventController.queryEventForView(e.Id);
        CHCRM_ViewEventController.eventWrapper evEdit = CHCRM_ViewEventController.queryEventForEdit(e.Id);
        CHCRM_ViewEventController.saveEvent(e,ce);
        System.assertEquals(e.CHCRM_Event__c,ce.Id);
    }
    
    /*@isTest(SeeAllData=true)
    private static testMethod void testSaveEventError1(){
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        insert events;
        Event e1 = [SELECT Id,OwnerId,CHCRM_Event__c,RecordType.DeveloperName ,CHCRM_HQ_Mnthly_Assgmnt__c , SOM_Status__c FROM Event LIMIT 1];
        List<CHCRM_HQ_Monthly_Assgmnt__c> ls = [SELECT ID From CHCRM_HQ_Monthly_Assgmnt__c WHERE CHCRM_Year__c <> '' and CHCRM_Month__c <> '' ORDER BY CHCRM_Year__c , CHCRM_Month__c LIMIT 1];
        e1.CHCRM_HQ_Mnthly_Assgmnt__c = ls[0].Id;
        update e1;
        CHCRM_Event__c ce = [SELECT Id FROM CHCRM_Event__c LIMIT 1];
        Event e = [SELECT Id,OwnerId,CHCRM_Event__c,RecordType.DeveloperName ,CHCRM_HQ_Mnthly_Assgmnt__c , SOM_Status__c FROM Event LIMIT 1];
        e.SOM_Status__c = 'Completed';
        e.RecordType.DeveloperName = 'CHCRM_Event';
        CHCRM_ViewEventController.saveWrapper result = CHCRM_ViewEventController.saveEvent(e,ce);
        System.debug(result.status != null);        
    }*/
    
    
    
    
    
    
    
    
    
    
    
    
}