/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    Target object trigger handler
****************************************************************************************/
public class SFO_TargetTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    /*
    * process target records before insert  
    */      
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_TargetService().setTargetKey( (List<SFO_Target__c>) newList );
    }

    /*
    * process target records before update  
    */   
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_TargetService().setTargetKey( (List<SFO_Target__c>) newList );
    }  

    /*
    * process target records after insert  
    */  
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_TargetService().processOpportunityOnTargetAfterInsert( (List<SFO_Target__c>) newList );
    }

    /*
    * process target records after update  
    */  
    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_TargetService().processOpportunityOnTargetAfterUpdate( (List<SFO_Target__c>) newList, (Map<Id, SFO_Target__c>) oldMap );
    }

}