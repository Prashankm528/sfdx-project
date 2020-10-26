/***********************************************************************************************
 * @author           Sean
 * @date             2020/03/30
 * @group            CHCRM
 * @description      Test class for CHCRM_SignIn_Controller

 * history
 * 2020/03/30  Sean  Created 
 ************************************************************************************************/
@isTest
private with sharing class CHCRM_SignIn_ControllerTests {

    @testSetup
    static void testSetup(){
        setMock();
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        insert events;
    }
    
    private static void setMock(){
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
    }

  	/**
      * @description test Construction method
      * @param  null
      * @return void
      */
  	@isTest
    static void testGetOperationPlatformMethod() {
         setMock();        
    	 System.assertEquals('PC',CHCRM_SignIn_Controller.getOperationPlatform());
    }

    /**
      * @description test updateRecord() method
      * @param  null
      * @return void
      */
    @isTest
    static void testUpdateRecord() {
        setMock();         
      	List<Event> events = [Select Id FROM Event];
      	Datetime signInTime = Datetime.now();
      	CHCRM_SignIn_Controller.updateRecord(events[0].Id, '1', '1', 'Test Address', String.valueOf(signInTime.getTime()));
      	
        List<CHCRM_Event__c> customEvents = [Select Id,
                                                    CHCRM_Check_In_Address__c,
                                                    CHCRM_Check_In_Location__Longitude__s,
                                                    CHCRM_Check_In_Location__Latitude__s,
                                                    CHCRM_Check_In_Time__c FROM CHCRM_Event__c];
                                                    
        System.assertEquals('Test Address', customEvents[0].CHCRM_Check_In_Address__c);
      	System.assertEquals(1, customEvents[0].CHCRM_Check_In_Location__Longitude__s);
      	System.assertEquals(1, customEvents[0].CHCRM_Check_In_Location__Latitude__s);
      	System.assertEquals(signInTime, customEvents[0].CHCRM_Check_In_Time__c);
    }
}