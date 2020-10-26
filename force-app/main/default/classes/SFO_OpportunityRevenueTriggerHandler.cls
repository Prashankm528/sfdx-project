/*****************************************************************************************
*	Date:		    23-Jul-2020
*   Author:         SFO Team
*   Description:    SFO Opportunity trigger handler 
****************************************************************************************/
public with sharing class SFO_OpportunityRevenueTriggerHandler extends BPG_Trigger_Handler_Utilities 
{
    /*
    * process opportunity records before insert  
    */     
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        system.debug('createDemandPlaningRecords >>> ');
        new SFO_OpportunityRevenueService().createDemandPlaningRecords((List<Revenue__c>) newList);
        new SFO_OpportunityRevenueService().revenueWithProductCode((List<Revenue__c>) newList);
    }
    
    /*
    * process opportunity records after update  
    */ 
    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_OpportunityRevenueService().updateDemandPlaningVolume((List<Revenue__c>) newList, (Map<Id, Revenue__c>) oldMap);
    }
}