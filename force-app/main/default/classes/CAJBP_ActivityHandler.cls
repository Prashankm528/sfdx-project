/**
 * @author 			Venkatesh Muniyasamy
 * @date 			18/07/2019
 * @group			CAJBP
 * @description     Trigger Handler on CAJBP_JBP_Activity__c object
 *
 * history
  * 18/07/2019	Venkatesh M			Created for code refactoring
  * 22/10/2019   Venkatesh Muniyasamy    Updated for JAF Rollup
 */
public with sharing class CAJBP_ActivityHandler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler((List<CAJBP_JBP_Activity__c>) newList, (List<CAJBP_JBP_Activity__c>) oldList, (Map<Id, CAJBP_JBP_Activity__c>) newMap, (Map<Id, CAJBP_JBP_Activity__c>) oldMap);
       handler.handleBeforeInsert();
    }
     public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler((List<CAJBP_JBP_Activity__c>) newList, (List<CAJBP_JBP_Activity__c>) oldList, (Map<Id, CAJBP_JBP_Activity__c>) newMap, (Map<Id, CAJBP_JBP_Activity__c>) oldMap);
       handler.handleBeforeUpdate();
    }
   public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler((List<CAJBP_JBP_Activity__c>) newList, (List<CAJBP_JBP_Activity__c>) oldList, (Map<Id, CAJBP_JBP_Activity__c>) newMap, (Map<Id, CAJBP_JBP_Activity__c>) oldMap);
       handler.handleAfterInsert();
    }
   public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler((List<CAJBP_JBP_Activity__c>) newList, (List<CAJBP_JBP_Activity__c>) oldList, (Map<Id, CAJBP_JBP_Activity__c>) newMap, (Map<Id, CAJBP_JBP_Activity__c>) oldMap);
       handler.handleAfterUpdate();
    }
	
	public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler((List<CAJBP_JBP_Activity__c>) newList, (List<CAJBP_JBP_Activity__c>) oldList, (Map<Id, CAJBP_JBP_Activity__c>) newMap, (Map<Id, CAJBP_JBP_Activity__c>) oldMap);
        handler.handleBeforeDelete();
    }
   public override void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpActivityTriggerHandler handler = new CAJBP_JbpActivityTriggerHandler((List<CAJBP_JBP_Activity__c>) newList, (List<CAJBP_JBP_Activity__c>) oldList, (Map<Id, CAJBP_JBP_Activity__c>) newMap, (Map<Id, CAJBP_JBP_Activity__c>) oldMap);
       handler.handleAfterDelete();
    }
}