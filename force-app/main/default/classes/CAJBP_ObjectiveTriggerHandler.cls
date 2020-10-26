/**
 * @author			Jan Majling
 * @date			03/10/2018
 * @group			CAJBP
 * @description		handles triggers of CAJBP_Objective__c object
 *
 * history
 * 03/10/2018	Jan Majling			Created
 * 29/01/2020	Venkatesh Muniyasamy    Updated for JBP Currency
 * 11/02/2020   Abhinit Kohar			Refactored it to use BPG_Trigger_Handler_Utilities (new trigger framework)
 */
public with sharing class CAJBP_ObjectiveTriggerHandler extends BPG_Trigger_Handler_Utilities {
    SObjectField jbpIdField =  Schema.CAJBP_Objective__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_Objective__c.Fields.CurrencyIsoCode;

	public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
		new CAJBP_ObjectiveHelper().shareObjectivesWithTeamMembers(newList);
	}

	public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
		CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c, oldList);
	}

	public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
		CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField,currencyField, newList);
	}
}