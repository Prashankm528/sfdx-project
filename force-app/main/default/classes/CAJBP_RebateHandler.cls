/**
 * @author 			Venkatesh Muniyasamy
 * @date 			22/07/2019
 * @group			CAJBP
 * @description     Trigger Handler on CAJBP_Rebate__c object
 *
 * history
  * 22/07/2019	Venkatesh M			Created
 */
public with sharing class CAJBP_RebateHandler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       //system.debug('Before Insert Trigger Starts');
       //CAJBP_JbpRebateTriggerHandler handler = new CAJBP_JbpRebateTriggerHandler((List<CAJBP_Rebate__c>) newList, (List<CAJBP_Rebate__c>) oldList, (Map<Id, CAJBP_Rebate__c>) newMap, (Map<Id, CAJBP_Rebate__c>) oldMap);
       //handler.handleBeforeInsert();
    }
    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       //system.debug('Before Delete Trigger Starts');
       //CAJBP_JbpRebateTriggerHandler handler = new CAJBP_JbpRebateTriggerHandler((List<CAJBP_Rebate__c>) newList, (List<CAJBP_Rebate__c>) oldList, (Map<Id, CAJBP_Rebate__c>) newMap, (Map<Id, CAJBP_Rebate__c>) oldMap);
       //handler.handleBeforeDelete();
    }
}