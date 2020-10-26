/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_KAPSovController
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAPSovControllerTest {
    
    @testSetup
    static void testSetup(){ 
        Account sovAcc = 
            CHCRM_TestSetup.createWorkshopAccount('TestSOVAccount');
        sovAcc.CHCRM_Key_Account_Flg__c = true;
        insert sovAcc;
        CHCRM_Sub_Channel_Account__c subChannelSov = 
            CHCRM_TestSetup.createSubChannelAccount(sovAcc.Id , 
                                                    'SOVSubChannel', 'SCA-TEST-0001');
        insert subChannelSov;
        CHCRM_Sub_Channel_Sub_Account__c subChannelSubSov = 
            CHCRM_TestSetup.createSubChannelSubAccount(subChannelSov.Id , 
                                                       'SOVSubChannelSub' ,
                                                       'SCSA-TEST-0001','102201');
        insert subChannelSubSov;
        insert CHCRM_TestSetup.createKap(subChannelSov.Id , '2020');
        insert CHCRM_TestSetup.createBusinessVolumeAc(subChannelSov.Id , '2017');
        insert CHCRM_TestSetup.createBusinessVolumeAc(subChannelSov.Id , '2018');
        insert CHCRM_TestSetup.createBusinessVolumeAc(subChannelSov.Id , '2019');
    }
    
    static testMethod void createSOVTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPSovController.createSOV(kap.Id);
        for(CHCRM_KAP_Sov_AUTO_Title__c title : [SELECT Id , CHCRM_Key_Account_Plan__c FROM CHCRM_KAP_Sov_AUTO_Title__c]){
            System.assertEquals(kap.Id, title.CHCRM_Key_Account_Plan__c);
        }
    }
    
    static testMethod void initDataTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPSovController.createSOV(kap.Id);
        CHCRM_KAPSovController.Wrapper wrapper = CHCRM_KAPSovController.initData(kap.Id);
        Id titleId = wrapper.wrapperItemList[0].sovTitleId;
        insert CHCRM_TestSetup.createSovProjectInfo(titleId);
        CHCRM_KAPSovController.refreshProject(titleId);
        for(CHCRM_KAPSovController.WrapperItem  item: CHCRM_KAPSovController.initData(kap.Id).wrapperItemList){
            System.assertEquals(titleId, item.sovTitleId);
        }        
    }
    
    static testMethod void saveSOVFinanceTest(){
        List<String> yearStrList = new List<String>{'2017','2018','2019','2020','2021','2022'};
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPSovController.createSOV(kap.Id);
        CHCRM_KAPSovController.Wrapper wrapper = CHCRM_KAPSovController.initData(kap.Id);
        Id titleId = wrapper.wrapperItemList[0].sovTitleId;
        String result = '5000';
        for(CHCRM_KAPSovController.WrapperItem  item: wrapper.wrapperItemList){
            for(CHCRM_KAPSovController.Finance finance : item.financeList){
                finance.lastYear3 = result;
                finance.lastYear2 = result;
                finance.lastYear = result;
                finance.curYear = result;
                finance.nextYear = result;
                finance.nextYear2 = result;
                CHCRM_KAPSovController.saveSOVFinance(finance, titleId, yearStrList);
            }
        }
        for(CHCRM_KAP_Sov_AUTO_Business_Volume__c bv : [SELECT Id,CHCRM_KAP_Sov_AUTO_Title__c,CHCRM_GM_RMB__c,CHCRM_GP_RMB__c,CHCRM_Return_On_Investment__c,
                                                        CHCRM_Turnover_RMB__c,CHCRM_Volume_L__c,CHCRM_Year__c FROM CHCRM_KAP_Sov_AUTO_Business_Volume__c Order by CHCRM_Year__c DESC]){
                                                            System.assertEquals(titleId, bv.CHCRM_KAP_Sov_AUTO_Title__c);
                                                            System.assertEquals(Decimal.valueOf(result), bv.CHCRM_Volume_L__c);
                                                                }
    }
    
    static testMethod void initStatusTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAPSovController.Wrapper wrapper = CHCRM_KAPSovController.initStatus(kap.Id);
        System.assertEquals('true', wrapper.isDraftFlag+'');
    }


}