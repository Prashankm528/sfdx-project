/* @author            DK
*  @date              08/22/2020
*  @description       Test class for CHCRM_ContactTriggerHandler
  and CHCRM_ContactProcess
*/
@isTest
private with sharing class CHCRM_ContactTriggerHandlerTest {
    private static testMethod void testInsertAndUpdate(){
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
      Contact contact = CHCRM_TestSetup.createContact('TestContact','13312341234','Lead');
      insert contact;      
      update contact;
      System.assertEquals('TestContact', contact.LastName);
      Test.stopTest();
    }
}