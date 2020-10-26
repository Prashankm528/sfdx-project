/**
 * @author 			Venkatesh Muniyasamy
 * @date 			13/09/2019
 * @group			CAJBP
 * @description     Handler on CAJBP_Distributor_Joint_Activity_Fund__c object
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 30/01/2020	Venkatesh Muniyasamy			Updated for JBP Currency
 * 07/02/2020   Abhinit Kohar                   Done the refactoring to get rid of CAJBP_JbpJafTriggerHandler and use CAJBP_JafCommons
 */
public with sharing class CAJBP_JbpJafHandler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        SObjectField jbpIdField =  Schema.CAJBP_Distributor_Joint_Activity_Fund__c.Fields.CAJBP_Joint_Business_Plan__c;
        CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(jbpIdField, (List<sObject>) oldList);

    }

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        CAJBP_JafCommons.populateJafFields(newList);
    }
}