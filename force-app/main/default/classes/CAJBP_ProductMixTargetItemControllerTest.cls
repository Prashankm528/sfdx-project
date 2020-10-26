/**
 * @author			Venkatesh Muniyasamy
 * @date			13/08/2020
 * @group			CAJBP
 * @description		Test class for Product Mix Target Item Controller.
 *
 * history
 * 13/08/2020	Venkatesh Muniyasamy			Created
*/
@isTest(seeAllData=false)
public with sharing class CAJBP_ProductMixTargetItemControllerTest {
    static integer dataSize = 1;
    static string accountType;
    static string jbpState = 'Draft';
    static CAJBP_Joint_Business_Plan__c jbp;
    static List<CAJBP_Product_Mix_Target__c> pmt;
    static id jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;
    static string productMixTargetRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Product_Mix_Target__c' and name ='Annual Sell-In PPL Rebate' and isactive=true limit 1].Id;
    static Schema.DescribeFieldResult fieldResult = CAJBP_Product_Mix_Target_Item__c.CAJBP_Product_Brand__c.getDescribe();
    static List<Schema.PicklistEntry> productBrandList = fieldResult.getPicklistValues();

    @isTest
    public static void testGetProductBrandOptions()
    {
        Id productMixTargetId = [select Id,name from CAJBP_Product_Mix_Target__c Limit 1].Id;
        Test.startTest();
            Map<string,List<CAJBP_ProductMixTargetItemController.Option>> productBrandOptions = new Map<string,List<CAJBP_ProductMixTargetItemController.Option>>(CAJBP_ProductMixTargetItemController.getProductBrandOptions(productMixTargetId));
        Test.stopTest();
        system.assertEquals(productBrandList.size(), productBrandOptions.get('Options').size(), 'Product Brand is not retrieved Correctly');
    }

    @isTest
    public static void testSaveProductBrands()
    {
        Id productMixTargetId = [select Id,name from CAJBP_Product_Mix_Target__c Limit 1].Id;
        List<string> selected = new List<String>();
        selected.add('Alusol');
        selected.add('CRB');
        Test.startTest();
            CAJBP_ProductMixTargetItemController.saveProductBrands(productMixTargetId, selected);
            List<CAJBP_Product_Mix_Target_Item__c> pmtItem = [SELECT Id, CAJBP_Product_Brand__c FROM CAJBP_Product_Mix_Target_Item__c
                                                         WHERE CAJBP_Product_Mix_Target__c =: productMixTargetId];
        Test.stopTest();

        system.assertEquals(2, pmtItem.size(), 'Product Brand is not saved succesfully');

    }

    @TestSetup
    public static void createTestData()
    {
        CAJBP_Joint_Business_Plan__c jbpId = CAJBP_TestFactory.createJointBusinessPlan();
        pmt = CAJBP_TestFactory.createProductMixTarget(jbpId,dataSize);
        CAJBP_TestFactory.createProductMixTargetItem(pmt[0]);
    }
}