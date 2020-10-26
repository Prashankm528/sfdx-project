/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_InStoreShareProduct_Ctrl
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_InStoreShareProductTest {
    
    @testSetup
    static void testSetup(){ 
        Account prdAccount
            = CHCRM_TestSetup.createWorkshopAccount('PrdAccount');
        insert prdAccount;
        CHCRM_Sub_Channel_Account__c sub1
            = CHCRM_TestSetup.createSubChannelAccount(prdAccount.Id , 
                                                      'PrdSubChannel', 'SCA1-TEST1-00011');
        insert sub1;
        Id subId = sub1.Id;
        CHCRM_Sub_Channel_Sub_Account__c subChannelSubAccount = CHCRM_TestSetup.createSubChannelSubAccount(subId , 'PrdSubChannelSub' ,'SCSA1-TEST1-00011','102201');
        insert subChannelSubAccount;
        //create kap
        insert CHCRM_TestSetup.createKap(subId , '2020');
        //insert Competitor
        insert CHCRM_TestSetup.createCompetitor(prdAccount.Id , '嘉实多', true);
    }
    
    static testMethod void initInShoreShareProductsTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        for(CHCRM_KAP_InStoreShareProduct_Ctrl.WrapperItem item : CHCRM_KAP_InStoreShareProduct_Ctrl.initInShoreShareProducts(kap.Id).inStoreShareList){
            System.assertEquals('嘉实多', item.supplier);
        }
    }
    
    static testMethod void updateRecordsTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        List<CHCRM_KAP_InStoreShareProduct_Ctrl.WrapperItem> records = CHCRM_KAP_InStoreShareProduct_Ctrl.initInShoreShareProducts(kap.Id).inStoreShareList;
        for(CHCRM_KAP_InStoreShareProduct_Ctrl.WrapperItem item : records){
            item.shareOfWalletVol = 50;
            item.productCategory = 'Test';
        }
        CHCRM_KAP_InStoreShareProduct_Ctrl.updateRecords(records);
        CHCRM_KAP_In_Store_Share_Product__c result = [SELECT Id , CHCRM_Share_of_wallet_VOL__c FROM CHCRM_KAP_In_Store_Share_Product__c LIMIT 1];
        System.assertEquals(50 , result.CHCRM_Share_of_wallet_VOL__c);
    }

}