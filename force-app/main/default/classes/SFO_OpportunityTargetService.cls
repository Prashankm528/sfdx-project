/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    SFO Opportunity Target service use for opportunity and target combined  
****************************************************************************************/
public with sharing class SFO_OpportunityTargetService 
{
    /*
    * filter opportunity that needs to set target to opportunity before insert  
    */         
    public void setOpportunityTargetOnBeforeInsert(List<Opportunity> opportunityListTriggerNew)
    {
        List<Opportunity> sfoOpportunityListSetTargetOnInsert = new List<Opportunity>();
        Set<string> accountTargetKeySetOnInsert = new Set<string>();

        for(Opportunity opportunity : opportunityListTriggerNew)
        {
            if(SFO_Constant.TargetEnabledOpportunityRecordType().containsKey(opportunity.RecordTypeId))
            {
                sfoOpportunityListSetTargetOnInsert.add(opportunity);
                accountTargetKeySetOnInsert.add(opportunity.SFO_Account_Year_Quarter_Key__c);
            }
        }
        
        if(sfoOpportunityListSetTargetOnInsert.size() > 0)
        {
            setOpportunityTarget(sfoOpportunityListSetTargetOnInsert, getTargetKeyMap(accountTargetKeySetOnInsert), false);
        }          
    }

    /*
    * filter opportunity that needs to set target to opportunity before update  
    */  
    public void setOpportunityTargetOnBeforeUpdate(List<Opportunity> opportunityListTriggerNew, Map<Id, Opportunity> opportunityMapTriggerOldMap)
    {
        List<Opportunity> sfoOpportunityListSetTargetOnUpdate = new List<Opportunity>();
        Set<string> accountTargetKeySetOnUpdate = new Set<string>();

        for(Opportunity opportunity : opportunityListTriggerNew)
        {
            string keyNew = '#';
            keyNew = opportunity.SFO_Account_Year_Quarter_Key__c;

            string keyOld = '#';
            keyOld = opportunityMapTriggerOldMap.get(opportunity.Id).SFO_Account_Year_Quarter_Key__c;

            if(SFO_Constant.TargetEnabledOpportunityRecordType().containsKey(opportunity.RecordTypeId) && !keyNew.equalsIgnoreCase(keyOld))
            {
                sfoOpportunityListSetTargetOnUpdate.add(opportunity);
                accountTargetKeySetOnUpdate.add(keyNew);
            }
        }
        
        if(sfoOpportunityListSetTargetOnUpdate.size() > 0)
        {
            setOpportunityTarget(sfoOpportunityListSetTargetOnUpdate, getTargetKeyMap(accountTargetKeySetOnUpdate), false);
        }         
    }

    /*
    * set target to opportunity  
    */  
    public void setOpportunityTarget(List<Opportunity> sfoOpportunityList, Map<string, Id> targetKeyMap, boolean isUpdate)
    {
        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();

        for(Opportunity opportunity : sfoOpportunityList)
        {
            if(targetKeyMap.get(opportunity.SFO_Account_Year_Quarter_Key__c) != null)
            {
                opportunity.CASFO_Target__c = targetKeyMap.get(opportunity.SFO_Account_Year_Quarter_Key__c);
            }
            else 
            {
                opportunity.CASFO_Target__c = null;
            }

            opportunityListToUpdate.add(opportunity);
        }

        if(isUpdate && opportunityListToUpdate.size() > 0)
        {
            Database.update(opportunityListToUpdate, false);
        }

    }

    /*
    * create target key to target id map    
    */  
    private Map<string, Id> getTargetKeyMap(Set<string> accountTargetKeySet)
    {   
        Map<string, Id> targetKeyMap = new Map<string, Id>();

        for(SFO_Target__c target : getTargets(accountTargetKeySet))
        {
            targetKeyMap.put(target.SFO_Key__c, target.Id);
        }

        return targetKeyMap;        
    }

    /*
    * retrieved the only eligible target that needs for processing opportunity   
    */  
    private List<SFO_Target__c> getTargets(Set<string> accountTargetKeySet)
    {
        return new List<SFO_Target__c>([SELECT Id, SFO_Account__c, SFO_Year__c, SFO_Quarter__c, SFO_Key__c FROM SFO_Target__c WHERE SFO_Key__c IN :accountTargetKeySet]);
    }
}