/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_KAPBgBusinessChanceController
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAPBgBusinessChanceControllerTest {
    
    @testSetup
    static void testSetup(){ 
        Account bgAccount;
        bgAccount = CHCRM_TestSetup.createWorkshopAccount('TestBgAccount');
        insert bgAccount;
        CHCRM_Sub_Channel_Account__c subChannelBg 
            = CHCRM_TestSetup.createSubChannelAccount(bgAccount.Id , 
                                                      'TestBgSubChannel', 'SCA-TEST-0001');
        insert subChannelBg;
        CHCRM_Sub_Channel_Sub_Account__c subChannelSubBg 
            = CHCRM_TestSetup.createSubChannelSubAccount(subChannelBg.Id , 'TestBgSubChannelSub' ,'SCSA-TEST-0001','102201');
        insert subChannelSubBg;
        insert CHCRM_TestSetup.createKap(subChannelBg.Id , '2020');     
        CHCRM_KAP_Business_Volume_Actual__c aclastYear3 = CHCRM_TestSetup.createBusinessVolumeAc(subChannelBg.Id , '2017');
        CHCRM_KAP_Business_Volume_Actual__c aclastYear2 = CHCRM_TestSetup.createBusinessVolumeAc(subChannelBg.Id , '2018');
        CHCRM_KAP_Business_Volume_Actual__c aclastYear = CHCRM_TestSetup.createBusinessVolumeAc(subChannelBg.Id , '2019');
        List<CHCRM_KAP_Business_Volume_Actual__c> acList = new List<CHCRM_KAP_Business_Volume_Actual__c>{aclastYear3 , aclastYear2 , aclastYear};
        insert acList;
    }
    
    static testMethod void getKAPInformationByIdTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPBgBusinessChanceController.getKAPInformationById(kap.Id);
        for(CHCRM_KAP_Business_Volume__c bv : [SELECT Id , Key_Account_Plan__c , CHCRM_Year__c FROM CHCRM_KAP_Business_Volume__c Order By CHCRM_Year__c DESC]){
            System.assertEquals(kap.Id , bv.Key_Account_Plan__c);
        }
    }
    
    static testMethod void saveTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPBgBusinessChanceController.Wrapper wrapper = CHCRM_KAPBgBusinessChanceController.getKAPInformationById(kap.Id);
        for(CHCRM_KAPBgBusinessChanceController.CaltrolTableData row : wrapper.dataList){
            row.lastYear3 = '50';
            row.lastYear2 = '50';
            row.lastYear = '50';
            row.curYear = '50';
            row.nextYear = '50';
            row.nextYear2 = '50';
            CHCRM_KAPBgBusinessChanceController.save(row);
        }
        for(CHCRM_KAP_Business_Volume__c bv : [SELECT Id , CHCRM_GM_RMB__c , Turnover_RMB__c , CHCRM_Coverage_Percent__c , CHCRM_In_Store_Share_Percent__c , 
                                               CHCRM_GP_RMB__c,CHCRM_Volume_L__c,
                                               CHCRM_Year__c , LastModifiedDate
                                               FROM CHCRM_KAP_Business_Volume__c Order By CHCRM_Year__c DESC]){
                                                   System.assertEquals(50 , bv.CHCRM_GM_RMB__c);
                                                   System.assertEquals(50 , bv.Turnover_RMB__c);
                                                   System.assertEquals(50 , bv.CHCRM_Coverage_Percent__c);
                                                   System.assertEquals(50 , bv.CHCRM_In_Store_Share_Percent__c);
                                                   System.assertEquals(50 , bv.CHCRM_GP_RMB__c);
                                                   System.assertEquals(50 , bv.CHCRM_Volume_L__c);
                                               }
    }
    
    static testMethod void initStatusTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPBgBusinessChanceController.Wrapper wrapper = CHCRM_KAPBgBusinessChanceController.initStatus(kap.Id);
        System.assertEquals('true', wrapper.isDraftFlag+'');
    }

}