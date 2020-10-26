/**
* @author: Gabriela Matos
* @date: 25/06/2020
* @group: BPCM
* @description: BPCM Hander class for BPCM_Automation_Setup__c trigger
* @name BPCM_AutomationSetupTriggerHandler.cls
*/

public with sharing class BPCM_AutomationSetupTriggerHandler extends BPG_Trigger_Handler_Utilities {
    
    /* 
    * method runs everytime BPCM_Automation_Setup__c BEFORE records are CREATED
    * process all before commiting in the Database. 
    */
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug){
        new BPCM_AutomationSetupService().runBeforeInsert( (List<BPCM_Automation_Setup__c>) newList);
    }

    /* 
    * method runs everytime BPCM_Automation_Setup__c BEFORE records are UPDATED
    * process all before commiting in the Database.
    */
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug){
        new BPCM_AutomationSetupService().runBeforeUpdate( (List<BPCM_Automation_Setup__c>) newList, ( Map<Id, BPCM_Automation_Setup__c> ) oldMap);
    }
}