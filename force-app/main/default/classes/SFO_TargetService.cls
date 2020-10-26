/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    Target object service for business logic 
****************************************************************************************/
public with sharing class SFO_TargetService
{
    /*
    * Set target keys 
    */     
    public void setTargetKey(List<SFO_Target__c> targetList)
    {
        for(SFO_Target__c target : targetList)
        {
            target.SFO_Key__c = target.SFO_Account__c + '#' + target.SFO_Year__c + '#' + target.SFO_Quarter__c; 
        }
    }

    /*
    * Set target for the opportunity after target insert  
    */  
    public void processOpportunityOnTargetAfterInsert(List<SFO_Target__c> targetListTriggerNew)
    {
        Map<string, Id> accountTargetKeyMap = new Map<string, Id>();

        for(SFO_Target__c target : targetListTriggerNew)
        {
            accountTargetKeyMap.put(target.SFO_Key__c, target.Id);
        }

        List<Opportunity> opportunityList = new List<Opportunity>([SELECT Id, AccountId, CloseDate, SFO_Account_Year_Quarter_Key__c FROM Opportunity WHERE SFO_Account_Year_Quarter_Key__c IN :accountTargetKeyMap.keySet()]);

        if(opportunityList.size() > 0)
        {
            new SFO_OpportunityTargetService().setOpportunityTarget(opportunityList, accountTargetKeyMap, true);
        }
        
    }

    /*
    * Set target for the opportunity after target update  
    */  
    public void processOpportunityOnTargetAfterUpdate(List<SFO_Target__c> targetListTriggerNew, Map<Id, SFO_Target__c> triggerMapTriggerOldMap)
    {
        Map<string, Id> targetMapChangeKey = new Map<string, Id>();

        for(SFO_Target__c target : targetListTriggerNew)
        {
            if(!target.SFO_Key__c.equalsIgnoreCase(triggerMapTriggerOldMap.get(target.Id).SFO_Key__c))
            {
                targetMapChangeKey.put(target.SFO_Key__c, target.Id);
            }
        }

        List<Opportunity> opportunityList = new List<Opportunity>([SELECT Id, AccountId, CloseDate, SFO_Account_Year_Quarter_Key__c, CASFO_Target__c FROM Opportunity WHERE SFO_Account_Year_Quarter_Key__c IN : targetMapChangeKey.keySet() OR CASFO_Target__c IN :targetMapChangeKey.values()]);

        if(opportunityList.size() > 0)
        {
            new SFO_OpportunityTargetService().setOpportunityTarget(opportunityList, targetMapChangeKey, true);  
        }    
             
    }
}