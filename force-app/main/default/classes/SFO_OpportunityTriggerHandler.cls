/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    SFO Opportunity trigger handler 
****************************************************************************************/
public with sharing class SFO_OpportunityTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    /*
    * process opportunity records before insert  
    */     
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_OpportunityTargetService().setOpportunityTargetOnBeforeInsert((List<Opportunity>) newList);
    }

    /*
    * process opportunity records before update  
    */   
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_OpportunityTargetService().setOpportunityTargetOnBeforeUpdate((List<Opportunity>) newList, (Map<Id, Opportunity>) oldMap);
            
        SFO_ProbabilityOverrideTriggerHandler.syncProbability((List<Opportunity>) newList, (Map<Id, Opportunity>) oldMap);
    }

    /*
    * process opportunity records after update  
    */ 
    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        CASFO_InactiveProductTrigerHandler.sendChatter( (Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        new SFO_OpportunityRevenueService().updateDemandPlaningMonth((List<Opportunity>) newList,(Map<Id, Opportunity>) oldMap);
    }
}