/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_PBVTree_Ctl
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_PBVTree_CtlTest {
    
    @testSetup
    static void testSetup(){
        CHCRM_PBV_Detail__c parentPBV = CHCRM_TestSetup.createPBV('parentPBV1',null);
        insert parentPBV;
        CHCRM_PBV_Detail__c childPBV 
            = CHCRM_TestSetup.createPBV('childPBV1',parentPBV.Id);
        insert childPBV;
    }
    
    static testMethod void initDataTest(){
        CHCRM_KAP_PBVTree_Ctl.Wrapper wrapper = CHCRM_KAP_PBVTree_Ctl.initData();
        CHCRM_PBV_Detail__c pbv = [SELECT Id , Name FROM CHCRM_PBV_Detail__c WHERE Name = 'parentPBV1' limit 1];
        System.assertEquals(pbv.Name, wrapper.mapping.get(pbv.Id));
    }
    
    static testMethod void findPBVByPBCodeTest(){
        CHCRM_PBV_Detail__c parentPBV = [SELECT Id FROM CHCRM_PBV_Detail__c WHERE Name = 'parentPBV1' Limit 1];
        CHCRM_KAP_PBVTree_Ctl.Wrapper wrapper = CHCRM_KAP_PBVTree_Ctl.findPBVByPBCode(parentPBV.Id);
        System.assertEquals('childPBV1', wrapper.items[0].label);
    }
    
}