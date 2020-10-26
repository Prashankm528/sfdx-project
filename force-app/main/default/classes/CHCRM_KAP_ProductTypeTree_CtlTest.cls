/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_ProductTypeTree_Ctl
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_ProductTypeTree_CtlTest {
    
    @testSetup
    static void testSetup(){         
        CHCRM_Product_Structure__c level1 
            = CHCRM_TestSetup.createProductStructure('level1Structure'
                                                     , null);
        insert level1;
        CHCRM_Product_Structure__c level2 = CHCRM_TestSetup.createProductStructure('level2Structure' 
                                                                                   , level1.Id);
        insert level2;
        insert CHCRM_TestSetup.createSKU(level2.Id ,'TestSKU');
    }
    
    static testMethod void initDataTest(){
        CHCRM_KAP_ProductTypeTree_Ctl.Wrapper wrapper = CHCRM_KAP_ProductTypeTree_Ctl.initData();
        for(CHCRM_Product_Structure__c stu : [SELECT Id , Name FROM CHCRM_Product_Structure__c]){
            System.assertEquals(stu.Name, wrapper.mapping.get(stu.Id));
        }
    }
    
    static testMethod void findSKUByProductIdTest(){
        CHCRM_Product_Structure__c level2 = [SELECT Id FROM CHCRM_Product_Structure__c WHERE Name = 'level2Structure' Limit 1];
        CHCRM_KAP_ProductTypeTree_Ctl.Wrapper wrapper = CHCRM_KAP_ProductTypeTree_Ctl.findSKUByProductId(level2.Id);
        System.assertEquals('TestSKU', wrapper.skuList[0].label);
    }

}