/**
 * @author 			Venkatesh Muniyasamy
 * @date 			19/07/2019
 * @group			CAJBP
 * @description     Trigger Handler on CAJBP_Objective__c object
 *
 * history
  * 19/07/2019	 Venkatesh Muniyasamy		Created for code refactoring
  * 28/01/2020   Venkatesh Muniyasamy    Updated for Objective Currency as JBPs
 */
public with sharing class CAJBP_ObjectiveHandler extends BPG_Trigger_Handler_Utilities {

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
       //CAJBP_ObjectiveTriggerHandler handler = new CAJBP_ObjectiveTriggerHandler((List<CAJBP_Objective__c>)newList, (List<CAJBP_Objective__c>) oldList, (Map<Id,CAJBP_Objective__c>) newMap, (Map<Id,CAJBP_Objective__c>) oldMap); 
       //handler.handleAfterInsert();
    }

    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
       // CAJBP_ObjectiveTriggerHandler handler = new CAJBP_ObjectiveTriggerHandler((List<CAJBP_Objective__c>)newList, (List<CAJBP_Objective__c>) oldList, (Map<Id,CAJBP_Objective__c>) newMap, (Map<Id,CAJBP_Objective__c>) oldMap);
        //handler.handleBeforeDelete();
    }

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
       //CAJBP_ObjectiveTriggerHandler handler = new CAJBP_ObjectiveTriggerHandler((List<CAJBP_Objective__c>)newList, (List<CAJBP_Objective__c>) oldList, (Map<Id,CAJBP_Objective__c>) newMap, (Map<Id,CAJBP_Objective__c>) oldMap); 
      // handler.handleBeforeInsert();
    }
}