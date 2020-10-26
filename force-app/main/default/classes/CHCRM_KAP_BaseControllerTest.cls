/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_KAP_BaseController
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_BaseControllerTest {
    
    @testSetup
    static void testSetup(){ 
        Account baseAccount = CHCRM_TestSetup.createWorkshopAccount('BaseAccount');
        insert baseAccount;
        CHCRM_Sub_Channel_Account__c subChannelBase = 
            CHCRM_TestSetup.createSubChannelAccount(baseAccount.Id , 
                                                    'BaseSubChannel', 
                                                    'SCA-TEST1-00001');
        insert subChannelBase;
        CHCRM_Sub_Channel_Sub_Account__c subChannelSubBase = CHCRM_TestSetup.createSubChannelSubAccount(subChannelBase.Id 
                                                                                                           , 'BaseSubChannelSub' 
                                                                                                           ,'SCSA-TEST1-00001','102201');
        insert subChannelSubBase;
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(subChannelBase.Id , '2020');
        insert kap;
    }
    
    static testMethod void initStatusTest(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        CHCRM_KAP_BaseController.Wrapper wrapper = CHCRM_KAP_BaseController.initStatus(kap.Id);
        System.assertEquals('true', wrapper.isDraftFlag+'');
    }

}