/* @author            DK
*  @date              08/20/2020
*  @description       Test class for CHCRM_WSPYearlyStatsTriggerHandler  and CHCRM_WSPYearlyStatsProcess
*/
@isTest
private with sharing class CHCRM_WSPYearlyStatsTriggerHandlerTest {
    @testSetup
    static void SetupData(){
        Account workshop = CHCRM_TestSetup.createWorkshopAccount('Test Workshop');
        insert workshop;
    }
    
    private static testMethod void testInsertAndUpdate(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        Account workshop = [SELECT Id FROM Account LIMIT 1];
        CHCRM_WSP_Yearly_Stats__c wspYearlyStats = CHCRM_TestSetup.createWSPYearlyStats(workshop.Id,'2020',66,66);
        insert wspYearlyStats;
        update wspYearlyStats;
        System.assertEquals(workshop.Id, wspYearlyStats.CHCRM_Workshop__c);
        Test.stopTest();
    }
}