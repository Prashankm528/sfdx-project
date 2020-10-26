/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_KAPSalesTargetController
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAPSalesTargetControllerTest {
    
    @testSetup
    static void testSetup(){ 
        Account salesAcc 
            = CHCRM_TestSetup.createWorkshopAccount('SalesAccount');
        insert salesAcc;
        CHCRM_Sub_Channel_Account__c subChannel 
            = CHCRM_TestSetup.createSubChannelAccount(salesAcc.Id , 'SalesSubChannel', 'SCA-TEST-0001');
        insert subChannel;
        CHCRM_Sub_Channel_Sub_Account__c subChannelSub 
            = CHCRM_TestSetup.createSubChannelSubAccount(subChannel.Id , 'SalesSubChannelSub' ,'SCSA-TEST-0001','102201');
        insert subChannelSub;
        CHCRM_Product_Structure__c structure = CHCRM_TestSetup.createProductStructure('TestStructure',null);
        insert structure;
        CHCRM_SKU_Detail__c sku = CHCRM_TestSetup.createSKU(structure.Id ,'TestSKU');
        insert sku;
        CHCRM_PBV_Detail__c pbv = CHCRM_TestSetup.createPBV('TestPBV',null);
        insert pbv;
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(subChannel.Id , '2020');
        insert kap;
        CHCRM_KAP_Sales_Target__c pbvSalesTarget = CHCRM_TestSetup.createSalesTarget(subChannel.Id,
                                                                                     kap.Id ,
                                                                                     subChannelSub.Id ,
                                                                                     pbv.Id ,
                                                                                     null , 'PBV' ,'2020' );
        CHCRM_KAP_Sales_Target__c skuSalesTarget = CHCRM_TestSetup.createSalesTarget(subChannel.Id, kap.Id ,
                                                                                     subChannelSub.Id , null , 
                                                                                     sku.Id , 'SKU' , '2020');
        insert pbvSalesTarget;
        insert skuSalesTarget;
    }
    
    static testMethod void initDataTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPSalesTargetController.Wrapper wrapper = CHCRM_KAPSalesTargetController.initData(kap.Id);
        System.assertEquals('TestPBV', wrapper.targetSetList[0].productName);
        System.assertEquals('TestSKU', wrapper.otherSetList[0].skuCode);
    }
    
    static testMethod void deleteRecordTest(){
        CHCRM_KAP_Sales_Target__c salesTarget = [SELECT Id FROM CHCRM_KAP_Sales_Target__c WHERE CHCRM_Category__c = 'PBV'];
        CHCRM_KAPSalesTargetController.deleteRecord(salesTarget.Id);
        CHCRM_KAP_Sales_Target__c result = [SELECT Id , CHCRM_Category__c FROM CHCRM_KAP_Sales_Target__c LIMIT 1];
        System.assertEquals('SKU', result.CHCRM_Category__c);
    }
    
    static testMethod void initStatusTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPSalesTargetController.Wrapper wrapper = CHCRM_KAPSalesTargetController.initStatus(kap.Id);
        System.assertEquals('true', wrapper.isDraftFlag+'');
    }

}