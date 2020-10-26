/* @author            DK
*  @date              08/26/2020
*  @description       Test class for CHCRM_HQMonthlyAssignmentTriggerHandler  and CHCRM_HQMonthlyAssignmentProcess
*/
@isTest
private with sharing class CHCRM_HQMonthlyAssignmentTRHandlerTest {
   @testSetup
    static void SetupData(){
        Account workshop = CHCRM_TestSetup.createWorkshopAccount('Test Workshop');
        insert workshop;

        CHCRM_HQ_Monthly_Assgmnt_Obj__c hqAssignmentObj = CHCRM_TestSetup.createHQMonthlyAssgmntObj(CHCRM_TestSetup.CHCRM_HQASSGMNTOBJ_OEMHQ_RECORDTYPE,'Draft','LTT',null);
        insert hqAssignmentObj;
    }
    private static testMethod void testInsertAndUpdate(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        CHCRM_HQ_Monthly_Assgmnt_Obj__c hqAssignmentObj = [SELECT Id FROM CHCRM_HQ_Monthly_Assgmnt_Obj__c LIMIT 1];
        Account workshop = [SELECT Id FROM Account LIMIT 1];
        CHCRM_HQ_Monthly_Assgmnt__c hqMonthlyAssgmnt = CHCRM_TestSetup.createHQMonthlyAssgmnt(CHCRM_TestSetup.CHCRM_HQASSGMNT_OEMHQ_RECORDTYPE,hqAssignmentObj.Id,workshop.Id,'Accepted','Uncovered');
        insert hqMonthlyAssgmnt;
        update hqMonthlyAssgmnt;
        System.assertEquals(CHCRM_TestSetup.CHCRM_HQASSGMNT_OEMHQ_RECORDTYPE, hqMonthlyAssgmnt.RecordTypeId);
        Test.stopTest();
    }
}