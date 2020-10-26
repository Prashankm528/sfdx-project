/***********************************************************************************************
* @author           WuTong
* @date             2020/08/14
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_Power_Map
* @test class       CHCRM_KAPPowerMapControllerTest
* history
* 2020/08/14  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAPPowerMapController {
    
    
   @AuraEnabled
    public static Wrapper initDataList(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id , CHCRM_Sub_Channel_Account__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId limit 1];
        List<CHCRM_KAP_Power_Map__c> powerMapList = [SELECT ID ,CHCRM_Sub_Channel_Account__c, CHCRM_Sub_Channel_Account__r.Name, CHCRM_Castrol_Owner__c , CHCRM_Castrol_Owner__r.Name,
                                                 CHCRM_Castrol_Position__c , CHCRM_Contact_Information__c , CHCRM_Contact_Name__c , CHCRM_Current_Relationship__c,
                                                 CHCRM_Decision_Fatigue__c , CHCRM_Improve_Relationship_Way__c , CHCRM_Position__c , CHCRM_Power_Map_Remark__c ,
                                                 CHCRM_Power_Map_Role__c ,CHCRM_Target_Relationship__c                                                 
                                                 FROM CHCRM_KAP_Power_Map__c WHERE CHCRM_Sub_Channel_Account__c =:kap.CHCRM_Sub_Channel_Account__c];
        if(!powerMapList.isEmpty()){
            List<PowerMapData> powerMapDataList = new List<PowerMapData>();
            for(CHCRM_KAP_Power_Map__c power : powerMapList){
                PowerMapData powerData = new PowerMapData();
                powerData.Id = power.Id;
                powerData.accountName = power.CHCRM_Sub_Channel_Account__c == null? '':power.CHCRM_Sub_Channel_Account__r.Name;
                powerData.accountId = power.CHCRM_Sub_Channel_Account__c;
                powerData.accountUrl = '/'+power.CHCRM_Sub_Channel_Account__c;
                powerData.position = power.CHCRM_Position__c;
                powerData.role = power.CHCRM_Power_Map_Role__c;
                powerData.contact = power.CHCRM_Contact_Name__c;
                powerData.contactWay = power.CHCRM_Contact_Information__c;
                powerData.decisionFatigue = power.CHCRM_Decision_Fatigue__c;
                powerData.relationship = power.CHCRM_Current_Relationship__c;
                powerData.improveRelationship = power.CHCRM_Improve_Relationship_Way__c;
                powerData.castrolPosition = power.CHCRM_Castrol_Position__c;
                powerData.castrolOwner = power.CHCRM_Castrol_Owner__c == null ? '' : power.CHCRM_Castrol_Owner__r.Name;
                powerData.castrolOwnerId = power.CHCRM_Castrol_Owner__c;
                powerData.remark = power.CHCRM_Power_Map_Remark__c;
                powerData.targetRelationship = power.CHCRM_Target_Relationship__c;
                powerMapDataList.add(powerData);
            }
            wrapper.powerMapDataList = powerMapDataList;
        }         
        return wrapper;
    }
    
    
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/14
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_Power_Map Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<PowerMapData> powerMapDataList { get; set; }
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/14
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_Power_Map Reture
    ************************************************************************************************/
    public with sharing class PowerMapData{
        
        @AuraEnabled
        public String id{ get; set; }
        @AuraEnabled
        public String accountName{ get; set; }
        @AuraEnabled
        public String accountId{ get; set; }
        @AuraEnabled
        public String accountUrl{ get; set; }
        @AuraEnabled
        public String channel{ get; set; }
        @AuraEnabled
        public String position{ get; set; }
        @AuraEnabled
        public String role{ get; set; }
        @AuraEnabled
        public String contact{ get; set; }
        @AuraEnabled
        public String contactWay{ get; set; }
        @AuraEnabled
        public String decisionFatigue{ get; set; }
        @AuraEnabled
        public String targetRelationship{ get; set; }
        @AuraEnabled
        public String relationship{ get; set; }
        @AuraEnabled
        public String improveRelationship{ get; set; }
        @AuraEnabled
        public String castrolPosition{ get; set; }
        @AuraEnabled
        public String castrolOwner{ get; set; }
        @AuraEnabled
        public String castrolOwnerId{ get; set; }
        @AuraEnabled
        public String remark{ get; set; }
        
    }
}