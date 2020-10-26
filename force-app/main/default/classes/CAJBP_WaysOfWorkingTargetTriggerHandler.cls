/**
 * @author 			Venkatesh Muniyasamy
 * @date 			31/10/2020
 * @group			CAJBP
 * @description     triggers on CAJBP_Ways_of_Working_Target__c object
 *
 * history
 * 31/10/2020	Venkatesh Muniyasamy			Created
 */
public with sharing class CAJBP_WaysOfWorkingTargetTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    SObjectField jbpIdField =  Schema.CAJBP_Ways_of_Working_Target__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_Ways_of_Working_Target__c.Fields.CurrencyIsoCode;

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {

        CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField,currencyField, newList);
    }
}