/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_InStoreShareBrand_Ctrl
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_InStoreShareBrandTest {
    
    @testSetup
    static void testSetup(){ 
        Account brandAcc = CHCRM_TestSetup.createWorkshopAccount('BrandAccount');
        brandAcc.CHCRM_Key_Account_Flg__c = true;
        insert brandAcc;
        Id accountId = brandAcc.Id;
        CHCRM_Sub_Channel_Account__c subChannelAccouont
            = CHCRM_TestSetup.createSubChannelAccount(accountId , 
                                                      'BrandSubChannel', 
                                                      'SCA-TEST-0001');
        insert subChannelAccouont;
        insert CHCRM_TestSetup.createKap(subChannelAccouont.Id , '2020');
        Competitor__c c = CHCRM_TestSetup.createCompetitor(accountId , '嘉实多', true);
        insert c;
    }
    
    static testMethod void initInShoreShareBrandTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        for(CHCRM_KAP_InStoreShareBrand_Ctrl.WrapperItem item : CHCRM_KAP_InStoreShareBrand_Ctrl.initInShoreShareBrand(kap.Id).inStoreShareList){
            System.assertEquals('嘉实多', item.supplier);
        }
    }
    
    static testMethod void updateRecordsTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        List<CHCRM_KAP_InStoreShareBrand_Ctrl.WrapperItem> records = CHCRM_KAP_InStoreShareBrand_Ctrl.initInShoreShareBrand(kap.Id).inStoreShareList;
        for(CHCRM_KAP_InStoreShareBrand_Ctrl.WrapperItem item : records){
            item.shareOfWalletVol = 50;
            item.productCategory = 'Test';
            item.validityOfContract = 'Test';
        }
        CHCRM_KAP_InStoreShareBrand_Ctrl.updateRecords(records);
        CHCRM_KAP_In_Store_Share_Brand__c result = [SELECT Id , CHCRM_Share_of_wallet_VOL__c FROM CHCRM_KAP_In_Store_Share_Brand__c LIMIT 1];
        System.assertEquals(50 , result.CHCRM_Share_of_wallet_VOL__c);
    }

}