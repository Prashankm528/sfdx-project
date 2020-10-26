public inherited sharing class CAJBP_RiskTriggerHandler extends BPG_Trigger_Handler_Utilities 
{
    SObjectField jbpIdField =  Schema.CAJBP_Risk__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_Risk__c.Fields.CurrencyIsoCode;

    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) 
    {

        //Cannot delete risks if JBP is "In Progress".
        CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
            Schema.CAJBP_Risk__c.fields.CAJBP_Joint_Business_Plan__c,
            oldList
        );
    }

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {

        CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField,currencyField, newList);
    }

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {

        CAJBP_JbpSharing jbpShare = new CAJBP_JbpSharing(); 
        jbpShare.grantAccessToRelatedRecords(newList);
        jbpShare.shareRisksToJBPOwner(newList);
    }
}