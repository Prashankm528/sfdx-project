/**
 * @author 			Venkatesh Muniyasamy
 * @date 			17/07/2019
 * @group			CAJBP
 * @description     Trigger Handler on CAJBP_Joint_Business_Plan__c object
 *
 * history
  * 17/07/2019	Venkatesh Muniyasamy		Created for code refactoring
  * 13/09/2019	Venkatesh Muniyasamy		Updated for deletion
  * 27/01/2020  Abhinit Kohar               Updated for afterUpdate
 */
public with sharing class CAJBP_JointBusinessPlanHandler extends BPG_Trigger_Handler_Utilities
 {
       
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
       CAJBP_JbpTriggerHandler handler = new CAJBP_JbpTriggerHandler((List<CAJBP_Joint_Business_Plan__c>)newList, (List<CAJBP_Joint_Business_Plan__c>) oldList, (Map<Id,CAJBP_Joint_Business_Plan__c>) newMap, (Map<Id,CAJBP_Joint_Business_Plan__c>) oldMap); 
       handler.handleBeforeUpsert();
    }
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CAJBP_JbpTriggerHandler handler = new CAJBP_JbpTriggerHandler((List<CAJBP_Joint_Business_Plan__c>)newList, (List<CAJBP_Joint_Business_Plan__c>) oldList, (Map<Id,CAJBP_Joint_Business_Plan__c>) newMap, (Map<Id,CAJBP_Joint_Business_Plan__c>) oldMap); 
        handler.handleBeforeUpsert();
    }

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)    
    {
        CAJBP_JbpTriggerHandler handler = new CAJBP_JbpTriggerHandler((List<CAJBP_Joint_Business_Plan__c>)newList, (List<CAJBP_Joint_Business_Plan__c>) oldList, (Map<Id,CAJBP_Joint_Business_Plan__c>) newMap, (Map<Id,CAJBP_Joint_Business_Plan__c>) oldMap); 
        handler.handleAfterInsert();
    }

    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)    
    {
        CAJBP_JbpTriggerHandler handler = new CAJBP_JbpTriggerHandler((List<CAJBP_Joint_Business_Plan__c>)newList, (List<CAJBP_Joint_Business_Plan__c>) oldList, (Map<Id,CAJBP_Joint_Business_Plan__c>) newMap, (Map<Id,CAJBP_Joint_Business_Plan__c>) oldMap); 
        handler.handleBeforeDelete();
    }

     public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
     {
         CAJBP_JbpTriggerHandler handler = new CAJBP_JbpTriggerHandler((List<CAJBP_Joint_Business_Plan__c>)newList, (List<CAJBP_Joint_Business_Plan__c>) oldList, (Map<Id,CAJBP_Joint_Business_Plan__c>) newMap, (Map<Id,CAJBP_Joint_Business_Plan__c>) oldMap);
         handler.handleAfterUpdate();
     }
 }