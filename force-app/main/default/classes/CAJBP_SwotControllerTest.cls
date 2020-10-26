/**
 * @author			  Venkatesh Muniyasamy
 * @date 			  23/12/2019
 * @group			  CAJBP
 * @description	Provides SWOT list of JBP SWOT Custom Component for Related List
 *
 * history
 * 23/12/2019	Venkatesh Muniyasamy			Created
 */
@isTest
public with sharing class CAJBP_SwotControllerTest {
    public static Account account = CAJBP_TestFactory.createCustomerMock();
    public static CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlanMock(account);

    class SWOTMock extends CAJBP_SwotController.SwotDAO {
        public override Map<String, List<CAJBP_SwotController.Swot>> getSwots(Id jbpId) {
            super.getSwots(jbpId);
            Map<String, List<CAJBP_SwotController.Swot>> swot = CAJBP_TestFactory.createJbpRelatedSwot(jbpId, 'Strength');
            return swot;
        }
    }

    @isTest
    static void CAJBP_SwotControllerTest() {
        CAJBP_SwotController.SwotService = new SWOTMock();

        Test.startTest();
            System.assertEquals(false, CAJBP_SwotController.getSwots(jbp.id).isEmpty());
        Test.stopTest();
    }

    @isTest
    static void itShouldUpdateSwotOrder() {
        CAJBP_Joint_Business_Plan__c jbpDb = CAJBP_TestFactory.createJointBusinessPlan();

        List<CAJBP_SWOT__c> swots = CAJBP_TestFactory.createJbpSwot(jbpDb.id).values()[0];
        insert swots;

        swots[0].CAJBP_Sort_Order__c = 1;

        System.assertNotEquals(
            swots[0].CAJBP_Sort_Order__c,
            [SELECT CAJBP_Sort_Order__c FROM CAJBP_SWOT__c WHERE Id = :swots[0].Id].CAJBP_Sort_Order__c
        );

        Test.startTest();
            System.assertEquals(false, CAJBP_SwotController.getSwots(jbpDb.id).isEmpty());
            CAJBP_SwotController.updateSwots(JSON.serialize(swots));
        Test.stopTest();

        System.assertEquals(
            swots[0].CAJBP_Sort_Order__c,
            [SELECT CAJBP_Sort_Order__c FROM CAJBP_SWOT__c WHERE Id = :swots[0].Id].CAJBP_Sort_Order__c
        );
    }

    @isTest
    static void itShouldNotUpdateSwotOrder() {
        CAJBP_Joint_Business_Plan__c jbpDb = CAJBP_TestFactory.createJointBusinessPlan();

        List<CAJBP_SWOT__c> swots = CAJBP_TestFactory.createJbpSwot(jbpDb.id).values()[0];
        swots[0].CAJBP_Sort_Order__c = -1;
        insert swots;

        swots[0].CAJBP_Sort_Order__c = 1;
        swots[0].Name = 'AAAA'.repeat(1000);

        System.assertNotEquals(
            swots[0].CAJBP_Sort_Order__c,
            [SELECT CAJBP_Sort_Order__c FROM CAJBP_SWOT__c WHERE Id = :swots[0].Id].CAJBP_Sort_Order__c
        );

        Test.startTest();
            try {
                CAJBP_SwotController.updateSwots(JSON.serialize(swots));
                System.assert(false, 'it should not hve updated swot');
            } catch(System.AuraHandledException ex) {
                System.assert(true, 'it should have been caught by aura exception');
            }
        Test.stopTest();

        System.assertEquals(
            -1,
            [SELECT CAJBP_Sort_Order__c FROM CAJBP_SWOT__c WHERE Id = :swots[0].Id].CAJBP_Sort_Order__c
        );
    }
}