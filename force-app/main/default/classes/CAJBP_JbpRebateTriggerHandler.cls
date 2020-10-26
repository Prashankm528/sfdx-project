/**
 * @author			Venkatesh Muniyasamy
 * @date			22/07/2019
 * @group			CAJBP
 * @description		handle triggers on CAJBP_Rebate__c
 *
 * history
 * 22/07/2019		Venkatesh Muniyasamy		Created
 * 30/01/2020	    Venkatesh Muniyasamy			Updated for JBP Currency
 */
public with sharing class CAJBP_JbpRebateTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    SObjectField jbpIdField =  Schema.CAJBP_Rebate__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_Rebate__c.Fields.CurrencyIsoCode;

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {       
        this.assignJointBusinessPlan(newList);
        CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField,currencyField, newList);
    }
    
    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {       
        SObjectField jbpIdField =  Schema.CAJBP_Rebate__c.fields.CAJBP_Joint_Business_Plan__c;
        CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(jbpIdField, oldList);
    }
        
    Public void assignJointBusinessPlan(List<CAJBP_Rebate__c> newRecords)
    {
        Set<Id> scorecardId = new Set<Id>();
        Map<Id,Id> scoreToJBP = new Map<Id,Id>();
        for(CAJBP_Rebate__c rebate: newRecords)
        {
            scorecardId.add(rebate.CAJBP_Scorecard__c);
        }
        for(CAJBP_Scorecard__c scorecard : [SELECT id,name,CAJBP_Joint_Business_Plan__c
                                             from CAJBP_Scorecard__c where Id IN:scorecardId ])
        {
            scoreToJBP.put(scorecard.Id,scorecard.CAJBP_Joint_Business_Plan__c);
        }
        for(CAJBP_Rebate__c rebate: newRecords)
        {
            rebate.CAJBP_Joint_Business_Plan__c = scoreToJBP.get(rebate.CAJBP_Scorecard__c);
        }
        
    }

}