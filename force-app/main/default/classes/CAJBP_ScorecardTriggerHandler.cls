/**
 * @author 			Venkatesh Muniyasamy
 * @date 			30/01/2020
 * @group			CAJBP
 * @description     Trigger Handler on CAJBP_Scorecard__c object
 *
 * history
  * 30/01/2020   Venkatesh Muniyasamy    Created
 */
public with sharing class CAJBP_ScorecardTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    private List<CAJBP_Scorecard__c> newRecords;
	private List<CAJBP_Scorecard__c> oldRecords;
	private Map<Id,CAJBP_Scorecard__c> newMap;
	private Map<Id,CAJBP_Scorecard__c> oldMap;
    SObjectField jbpIdField =  Schema.CAJBP_Scorecard__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_Scorecard__c.Fields.CurrencyIsoCode;

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       	this.newRecords = (List<CAJBP_Scorecard__c>) newList;
		this.oldRecords = (List<CAJBP_Scorecard__c>)oldList;
		this.newMap = (Map<Id,CAJBP_Scorecard__c>) newMap;
		this.oldMap = (Map<Id,CAJBP_Scorecard__c>)oldMap;
       //CAJBP_ObjectiveTriggerHandler handler = new CAJBP_ObjectiveTriggerHandler((List<CAJBP_Scorecard__c>)newList, (List<CAJBP_Scorecard__c>) oldList, (Map<Id,CAJBP_Scorecard__c>) newMap, (Map<Id,CAJBP_Scorecard__c>) oldMap); 
       this.handleBeforeInsert();
    }
    public void handleBeforeInsert()
    {
        CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField, currencyField, this.newRecords);
    }
}