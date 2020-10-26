/***********************************************************************************************
* @author           WuTong
* @date             2020/08/25
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_Base_CMP
* @test class       CHCRM_KAP_BaseControllerTest
* history
* 2020/08/25  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_BaseController {
    
    @AuraEnabled
    public static Wrapper initStatus(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id  , CHCRM_Status__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId];
        wrapper.isDraftFlag = kap.CHCRM_Status__c == 'Draft'? true:false;
        return wrapper;
    }
    
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/25
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_Base_CMP Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public Boolean isDraftFlag{get;set;}
    }
    

}