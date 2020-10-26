/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_Key_Account_Plan_TriggerHandler
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_Key_Account_Plan_TriggerTest {
    
    @testSetup
    static void testSetup(){ 
        Account acc = 
            CHCRM_TestSetup.createWorkshopAccount('TestTriggerAccount');
        acc.CHCRM_Key_Account_Flg__c 
            = true;
        insert acc;
        CHCRM_Sub_Channel_Account__c sca = CHCRM_TestSetup.createSubChannelAccount(acc.Id , 'TestTriggerSubChannel', 'SCA-TEST-0001');
        insert sca;
        CHCRM_Sub_Channel_Sub_Account__c scsa;
        scsa = CHCRM_TestSetup.createSubChannelSubAccount(sca.Id , 'TestTriggerSubChannelSub' ,'SCSA-TEST-0001','102201');
        insert scsa;
        CHCRM_Product_Structure__c stru;
        stru = CHCRM_TestSetup.createProductStructure('TestStructure',
                                                      null);
        insert stru;
        CHCRM_SKU_Detail__c sku = CHCRM_TestSetup.createSKU(stru.Id ,
                                                            'TestSKU');
        insert sku;
        CHCRM_PBV_Detail__c pbv = CHCRM_TestSetup.createPBV('TestPBV',
                                                            null);
        insert pbv;
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(sca.Id ,
                                                                  '2020');
        insert kap;
        CHCRM_KAP_Sales_Target__c pbvSalesTarget = CHCRM_TestSetup.createSalesTarget(sca.Id, 
                                                                                     kap.Id,
                                                                                     scsa.Id, 
                                                                                     pbv.Id,
                                                                                     null,
                                                                                     'PBV',
                                                                                     '2020');
        insert pbvSalesTarget;
        CHCRM_KAP_Sales_Target__c st = CHCRM_TestSetup.createSalesTarget(sca.Id, 
                                                                                     kap.Id,
                                                                                     scsa.Id, null, 
                                                                                     sku.Id, 'SKU', '2020');
        insert st;
        CHCRM_KAP_Sales_Target__c pbvST2 = CHCRM_TestSetup.createSalesTarget(sca.Id, null ,
                                                                                      scsa.Id , pbv.Id ,
                                                                                      null , 'PBV' ,'2021');
        insert pbvST2;
        CHCRM_KAP_Sales_Target__c skuST2 = CHCRM_TestSetup.createSalesTarget(sca.Id, null ,
                                                                             scsa.Id , null , 
                                                                             sku.Id , 'SKU' ,
                                                                             '2021');
        insert skuST2;
    }
    
    static testMethod void checkKAPIsUniqueneTest(){
        CHCRM_Sub_Channel_Account__c subChannelAccouont = [SELECT Id FROM CHCRM_Sub_Channel_Account__c LIMIT 1];
        try{
            INSERT CHCRM_TestSetup.createKap(subChannelAccouont.Id , '2020');
        }catch(Exception e){
            System.assert(e.getMessage().contains('添加Key Account Plan失败， 因为当前Sub Channel Account已存在2020年的Key Account Plan'));
        }
        for(CHCRM_Key_Account_Plan__c kap : [SELECT Id , CHCRM_Year__c FROM CHCRM_Key_Account_Plan__c]){
            System.assertEquals('2020', kap.CHCRM_Year__c);
        }
    }
    
    static testMethod void bindleSalesTargetTest(){
        CHCRM_Sub_Channel_Account__c subChannelAccouont = [SELECT Id FROM CHCRM_Sub_Channel_Account__c LIMIT 1];
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(subChannelAccouont.Id , '2021');
        insert kap;
        List<CHCRM_KAP_Sales_Target__c> salesTargetList = [SELECT Id , CHCRM_Key_Account_Plan__c FROM CHCRM_KAP_Sales_Target__c WHERE CHCRM_Year__c = '2021'];
        for(CHCRM_KAP_Sales_Target__c salesTarget : salesTargetList){
            System.assertEquals(kap.Id, salesTarget.CHCRM_Key_Account_Plan__c);
        }
    }

}