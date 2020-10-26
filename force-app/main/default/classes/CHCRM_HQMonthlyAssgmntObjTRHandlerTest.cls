/* @author            Xc
*  @date              08/14/2020
*  @description       Test class for CHCRM_HQMonthlyAssgmntObjTriggerHandler  and CHCRM_HQMonthlyAssignmentObjProcess
*/
@isTest
private with sharing class CHCRM_HQMonthlyAssgmntObjTRHandlerTest {
    private static testMethod void testInsertAndUpdate(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        CHCRM_HQ_Monthly_Assgmnt_Obj__c hqAssignmentObj = CHCRM_TestSetup.createHQMonthlyAssgmntObj(CHCRM_TestSetup.CHCRM_HQASSGMNTOBJ_OEMHQ_RECORDTYPE,'Draft','LTT',null);
        insert hqAssignmentObj;
        update hqAssignmentObj;
        System.assertEquals(CHCRM_TestSetup.CHCRM_HQASSGMNTOBJ_OEMHQ_RECORDTYPE, hqAssignmentObj.RecordTypeId);
        Test.stopTest();
    }
}