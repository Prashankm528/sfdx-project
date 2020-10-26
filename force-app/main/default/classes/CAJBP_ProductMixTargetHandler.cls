/**
 * @author 			Venkatesh Muniyasamy
 * @date 			13/09/2019
 * @group			CAJBP
 * @description     Handler on CAJBP_Product_Mix_Target__c object
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 30/01/2020	Venkatesh Muniyasamy			Updated for JBP Currency
 */
public with sharing class CAJBP_ProductMixTargetHandler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       CAJBP_ProductMixTargetTriggerHandler handler = new CAJBP_ProductMixTargetTriggerHandler((List<CAJBP_Product_Mix_Target__c>) newList, (List<CAJBP_Product_Mix_Target__c>) oldList, (Map<Id, CAJBP_Product_Mix_Target__c>) newMap, (Map<Id, CAJBP_Product_Mix_Target__c>) oldMap);
       handler.handleBeforeDelete();
    }
     public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
       CAJBP_ProductMixTargetTriggerHandler handler = new CAJBP_ProductMixTargetTriggerHandler((List<CAJBP_Product_Mix_Target__c>)newList, (List<CAJBP_Product_Mix_Target__c>) oldList, (Map<Id,CAJBP_Product_Mix_Target__c>) newMap, (Map<Id,CAJBP_Product_Mix_Target__c>) oldMap); 
       handler.handleBeforeInsert();
    }
}