/**
 * @author			Abhinit Kohar
 * @date			01/07/2020
 * @group			CAJBP
 * @description		test class for CAJBP_Product_Mix_Target_Item__c trigger
 */

@IsTest
private class CAJBP_ProductMixTargeItemTrigHandlerTest {
    static CAJBP_Joint_Business_Plan__c jbp;
    static string productMixTargetRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Product_Mix_Target__c' and name ='Annual Sell-In PPL Rebate' and isactive=true limit 1].Id;

    @isTest
    Public static void testProductMixTargetItemCreation()
    {
        jbp = [select Id,name,(select id from CAJBP_Scorecards__r Limit 1)  from CAJBP_Joint_Business_Plan__c Limit 1];

        CAJBP_Product_Mix_Target__c productMixTarget = [select Id from CAJBP_Product_Mix_Target__c where CAJBP_Joint_Business_Plan__c = :jbp.Id limit 1];
        CAJBP_Product_Mix_Target_Item__c productMixTargetItem = new CAJBP_Product_Mix_Target_Item__c(CAJBP_Product_Brand__c = 'Enduron', CAJBP_Product_Mix_Target__c = productMixTarget.Id);

        test.startTest();
        insert productMixTargetItem;
        test.stopTest();

        productMixTargetItem = [select Id, CAJBP_Joint_Business_Plan__c from CAJBP_Product_Mix_Target_Item__c where Id = :productMixTargetItem.Id];
        system.assertEquals(jbp.Id, productMixTargetItem.CAJBP_Joint_Business_Plan__c, 'Correct JBP is not assigned to Product Mix Target Item');

        update productMixTargetItem;
    }

    @TestSetup
    static void makeData() {
        jbp = CAJBP_TestFactory.createJointBusinessPlan();

        List<CAJBP_Product_Mix_Target__c> productMixTarget = new List<CAJBP_Product_Mix_Target__c>();

        jbp = [select Id,name,(select id from CAJBP_Scorecards__r Limit 1)  from CAJBP_Joint_Business_Plan__c Limit 1];

        productMixTarget.add(new CAJBP_Product_Mix_Target__c (CAJBP_Joint_Business_Plan__c=jbp.Id,
                CAJBP_Product_Mix_Target_Name__c = 'EDGE', CAJBP_Price_Per_Litre_Rebate__c=100.00,
                CAJBP_Volume_Target__c=10000, recordtypeid = productMixTargetRecordType,
                CAJBP_Scorecard__c = jbp.CAJBP_Scorecards__r.get(0).Id));

        insert productMixTarget;
    }
}