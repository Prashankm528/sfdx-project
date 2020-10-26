/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_KAPPowerMapController
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAPPowerMapControllerTest {
    
    @testSetup
    static void testSetup(){ 
        Account powerMapAccount = CHCRM_TestSetup.createWorkshopAccount('PowerMapAccount');
        powerMapAccount.CHCRM_Key_Account_Flg__c = true;
        insert powerMapAccount;
        CHCRM_Sub_Channel_Account__c subChannelAccouont1 
            = CHCRM_TestSetup.createSubChannelAccount(powerMapAccount.Id , 'PowerSubChannel', 'SCA-TEST-0001');
        insert subChannelAccouont1;
        //insert powerMap        
        insert CHCRM_TestSetup.createPowerMap(subChannelAccouont1.Id);
        //insert kap
        insert CHCRM_TestSetup.createKap(subChannelAccouont1.Id , '2020');
    }
    
    static testMethod void initDataListTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c Limit 1];
        CHCRM_KAPPowerMapController.Wrapper wrapper = CHCRM_KAPPowerMapController.initDataList(kap.Id);
        System.assertEquals('PowerSubChannel', wrapper.powerMapDataList[0].accountName);    
    }

}