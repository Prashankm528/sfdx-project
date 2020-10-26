/**
 * @author 			Venkatesh Muniyasamy
 * @date 			13/09/2019
 * @group			CAJBP
 * @description     Handler on CAJBP_SWOT__c object
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 31/01/2020   Venkatesh Muniyasamy            Updated for JBP Currency
 */
public with sharing class CAJBP_SwotHandler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpSwotTriggerHandler handler = new CAJBP_JbpSwotTriggerHandler((List<CAJBP_SWOT__c>) newList, (List<CAJBP_SWOT__c>) oldList, (Map<Id, CAJBP_SWOT__c>) newMap, (Map<Id, CAJBP_SWOT__c>) oldMap);
       handler.handleBeforeDelete();
    }

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_JbpSwotTriggerHandler handler = new CAJBP_JbpSwotTriggerHandler((List<CAJBP_SWOT__c>) newList, (List<CAJBP_SWOT__c>) oldList, (Map<Id, CAJBP_SWOT__c>) newMap, (Map<Id, CAJBP_SWOT__c>) oldMap);
       handler.handleBeforeInsert();
    }
}