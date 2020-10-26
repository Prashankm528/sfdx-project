/* @author            DK
*  @date              08/22/2020
*  @description       Test class for CHCRM_WSPYearlySalesRefTriggerHandler
  and CHCRM_WSPYearlySalesRefProcess
*/
@isTest
private with sharing class CHCRM_WSPYearlySalesRefTRHandlerTest {
    @testSetup
    static void SetupData(){
        Account workshop = CHCRM_TestSetup.createWorkshopAccount('Test Workshop');
        insert workshop;
    }
    private static testMethod void testInsertAndUpdate(){
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
      Account workshop = [Select Id FROM Account LIMIT 1];
      CHCRM_WSP_Yearly_SalesRef__c wspYearlySalesRef = CHCRM_TestSetup.createWSPYearlySalesRef(workshop.Id);
      insert wspYearlySalesRef;
      update wspYearlySalesRef;
      System.assertEquals(workshop.Id, wspYearlySalesRef.CHCRM_Workshop__c);
      Test.stopTest();
    }
 }