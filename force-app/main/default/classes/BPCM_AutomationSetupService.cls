/**
* @author: Gabriela Matos
* @date: 25/06/2020
* @group: BPCM
* @description: BPCM service class for BPCM_Automation_Setup__c object
* @name BPCM_AutomationSetupService.cls
*/

public with sharing class BPCM_AutomationSetupService {

    /** 
     * @description: method to run before insert and centralise all logics
     * 1. generate the unique key value and check if there is an existing record.
     * (done via code to customise the error message)
     * @author Gabriela Matos | 25/06/2020
     * @param: List of new BPCM_Automation_Setup__c records
     * @return void
     * */
    public void runBeforeInsert(List<BPCM_Automation_Setup__c> newRecords){

        Set<String> keyAutoSet = new Set<String>();
        for(BPCM_Automation_Setup__c aSetup : newRecords){
            keyAutoSet.add(BPCM_AutomationSetupService.generateKey(aSetup));
        }

        if(!keyAutoSet.isEmpty()){
            BPCM_AutomationSetupService.checkDuplication(newRecords,keyAutoSet);
        }
    }

    /** 
     * @description: method to run before update and centralise all logics
     * 1. check if either recordTypeId OR ProcessOrder OR Status has changed (key)
     * 2. generate the unique key value and check if there is an existing record.
     * (done via code to customise the error message)
     * @author Gabriela Matos | 25/06/2020
     * @param: List of new BPCM_Automation_Setup__c records
     * @param: Map of old BPCM_Automation_Setup__c records
     * @return void
     * */
    public void runBeforeUpdate(List<BPCM_Automation_Setup__c> newRecords, Map<Id, BPCM_Automation_Setup__c> oldRecMap){
        
        Set<String> keyAutoSet = new Set<String>();
        for(BPCM_Automation_Setup__c aSetup : newRecords){
            BPCM_Automation_Setup__c oldAutoSet = oldRecMap.get(aSetup.Id);

            //key will change based on the values
            if(aSetup.RecordTypeId != oldAutoSet.RecordTypeId
            || aSetup.BPCM_Process_Order__c != oldAutoSet.BPCM_Process_Order__c
            || aSetup.BPCM_Status__c != oldAutoSet.BPCM_Status__c){
                keyAutoSet.add(BPCM_AutomationSetupService.generateKey(aSetup));
            }
        }

        if(!keyAutoSet.isEmpty()){
            BPCM_AutomationSetupService.checkDuplication(newRecords,keyAutoSet);
        }
        
    }

    /** 
     * @description: method to generate and update the record with the unique KEY value
     * (Key = Process Order + Status + RecordTypeDeveloperName)
     * @author Gabriela Matos | 25/06/2020
     * @param: BPCM_Automation_Setup__c record
     * @return Key (String)
     * */
    public static String generateKey(BPCM_Automation_Setup__c aSetup){
        String recName = Schema.SObjectType.BPCM_Automation_Setup__c.getRecordTypeInfosById().get(aSetup.RecordTypeId).getDeveloperName();
        return String.valueOf(aSetup.BPCM_Process_Order__c) + aSetup.BPCM_Status__c + recName;
    }

    /** 
     * @description: method to check duplication from existing values in the data base with the values being added
     * or updated and will throw an error message.
     * @author Gabriela Matos | 25/06/2020
     * @param: List of new BPCM_Automation_Setup__c record
     * @param: Set of String (Keys)
     * @return void
     * */
    public static void checkDuplication(List<BPCM_Automation_Setup__c> newRecords, Set<String> keyAutoSet){

        Map<String, BPCM_Automation_Setup__c> existingAutoSetupMap = getAutoSettingRecords(keyAutoSet);
        for(String key : keyAutoSet){
            for(BPCM_Automation_Setup__c aSetup : newRecords){
                if(!existingAutoSetupMap.isEmpty() && existingAutoSetupMap.containsKey(key)){
                    aSetup.addError(System.Label.BPCM_Duplicate_Msg_Automation_Setup);
                } else {
                    aSetup.BPCM_Order_Key__c = key;
                }
            }
        }
    }

    /** 
     * @description: method to get existing records in the database based on the key value (index)
     * @author Gabriela Matos | 25/06/2020
     * @param: Set of String (Keys)
     * @return Map of BPCM_Automation_Setup__c by BPCM_Order_Key__c
     * */
    public static Map<String, BPCM_Automation_Setup__c> getAutoSettingRecords(Set<String> keyAutoSet){
        
        Map<String, BPCM_Automation_Setup__c> keyAutoSetMap = new Map<String, BPCM_Automation_Setup__c>();
        for(BPCM_Automation_Setup__c autoSet : [SELECT Id, BPCM_Order_Key__c 
                                                  FROM BPCM_Automation_Setup__c 
                                                 WHERE BPCM_Order_Key__c IN :keyAutoSet
                                                 LIMIT :Limits.getLimitQueryRows()]){
            keyAutoSetMap.put(autoSet.BPCM_Order_Key__c, autoSet);
        }
        return keyAutoSetMap;
    }
}