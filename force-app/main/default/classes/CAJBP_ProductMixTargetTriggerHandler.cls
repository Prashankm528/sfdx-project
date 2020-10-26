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
public with sharing class CAJBP_ProductMixTargetTriggerHandler
{
    private final List<CAJBP_Product_Mix_Target__c> newRecords;
	private final List<CAJBP_Product_Mix_Target__c> oldRecords;
	private final Map<Id,CAJBP_Product_Mix_Target__c> newMap;
	private final Map<Id,CAJBP_Product_Mix_Target__c> oldMap;
    SObjectField jbpIdField =  Schema.CAJBP_Product_Mix_Target__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_Product_Mix_Target__c.Fields.CurrencyIsoCode;

    public CAJBP_ProductMixTargetTriggerHandler(List<CAJBP_Product_Mix_Target__c> newRecords, List<CAJBP_Product_Mix_Target__c> oldRecords, Map<Id,CAJBP_Product_Mix_Target__c> newMap, Map<Id,CAJBP_Product_Mix_Target__c> oldMap)
    {
        this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
    }
    public void handleBeforeDelete()
    {
        CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(jbpIdField, (List<sObject>) this.oldRecords);
    }

    public void handleBeforeInsert()
    {
        CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField,currencyField, this.newRecords);
    }
}