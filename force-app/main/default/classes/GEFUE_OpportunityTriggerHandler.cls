/*****************************************************************************************
*   Date:           13FEB20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Opportunity Trigger Handler for updating number of open Site Opportunities on parent Site Account
*   Modifications:  
****************************************************************************************/
public with sharing class GEFUE_OpportunityTriggerHandler extends BPG_Trigger_Handler_Utilities {
    
    /* Called after an Opportunity record is inserted*/
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        collectSiteIdInsert(newList);
        checkPackageAndTerminalInsert(newList);
    }
    
    /* Called after an Opportunity record is updated*/
    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        collectSiteIdUpdate(oldList, newMap);
        checkPackageAndTerminalUpdate(newList, oldMap);
        takeSiteOpportunitiesForTerminal(newList, oldMap);
    }
    
    /* Called after an Opportunity record is deleted */
    public override void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        collectSiteIdUpdate(oldList, newMap);
    }
    
    /* Collects Site Opportunity Id on Insert */
    public void collectSiteIdInsert(List<SObject> newList) {
        Set<Id> setSiteId = new Set<Id>();
        for (Opportunity tempOpp : (List<Opportunity>) newList) {
            if (tempOpp.GEFUE_Site_Account__c != null) {
                setSiteId.add(tempOpp.GEFUE_Site_Account__c);
            }
        }
        if (setSiteId.size() > 0) {
            updateNumberofOpenOpportunities(setSiteId);
        }
    }
    
    /* Collects Site Opportunity Id on Update and Delete */
    public void collectSiteIdUpdate(List<SObject> oldList, Map<Id, SObject> newMap) {
        Set<Id> setSiteId = new Set<Id>();
        for (Opportunity tempOpp : (List<Opportunity>) oldList) {
            if (Trigger.isUpdate) {
                if (tempOpp.GEFUE_Site_Account__c != ((Opportunity)newMap.get(tempOpp.Id)).GEFUE_Site_Account__c ||
                    tempOpp.StageName != ((Opportunity)newMap.get(tempOpp.Id)).StageName) {
                        setSiteId.add(tempOpp.GEFUE_Site_Account__c);
                        setSiteId.add(((Opportunity)newMap.get(tempOpp.Id)).GEFUE_Site_Account__c);
                    }
            }
            if (Trigger.isDelete) {
                if (tempOpp.GEFUE_Site_Account__c != null) {
                    setSiteId.add(tempOpp.GEFUE_Site_Account__c);
                }
            }
    	}
        if (setSiteId.size() > 0) {
            updateNumberofOpenOpportunities(setSiteId);
        }
    }
    
    /* Updates number of Site Opportunities on Parent Site Account */
    public void updateNumberofOpenOpportunities(Set<Id> siteAccIds) {
        List<Account> accountToUpdate = new List<Account>();
        List<Account> lstSiteAccount = [
                                        SELECT
                                            Id,
                                            GEFUE_Number_of_Open_Opportunities__c,
                                            (
                                                SELECT
                                                    Id, 
                                                    Name,
                                                    GEFUE_Open_Opportunities__c
                                                FROM 
                                                	SiteOpportunities__r
                                                WHERE
                                                	IsClosed = FALSE
                                            )
                                        FROM
                                        	Account
                                        WHERE
                                        	Id IN :siteAccIds
        								];
        
        for (Account tempAcc : lstSiteAccount) {
            tempAcc.GEFUE_Number_of_Open_Opportunities__c = tempAcc.SiteOpportunities__r.size();
            accountToUpdate.add(tempAcc);
        }
        
        if (accountToUpdate.size() > 0) {
            update accountToUpdate;
        }
    }
    
    /* Checks Package and Terminal populated in new record being inserted */
    public void checkPackageAndTerminalInsert(List<SObject> newList) {
        Set<Id> setPackageId = new Set<Id>();
        Set<Id> setTerminalId = new Set<Id>();
        Map<Id, Id> mapTerminalPackageIds = new Map<Id, Id>();
        for (Opportunity tempOpp : (List<Opportunity>) newList) {
            if (tempOpp.GEFUE_Package__c != NULL && tempOpp.GEFUE_Terminal__c != NULL) {
                setPackageId.add(tempOpp.GEFUE_Package__c);
                setTerminalId.add(tempOpp.GEFUE_Terminal__c);
                mapTerminalPackageIds.put(tempOpp.GEFUE_Terminal__c, tempOpp.GEFUE_Package__c);
            }
        }
        if (setPackageId.size() > 0 && setTerminalId.size() > 0) {
            fetchPackageTerminal(setPackageId, setTerminalId, mapTerminalPackageIds);
        }
    }
    
    /* Checks package related Opportunity Terminals and inserts new if not present */
    public void fetchPackageTerminal(Set<Id> packageIds, Set<Id> terminalIds, Map<Id, Id> mapTerminalPackageIds) {
		List<GEFUE_Opportunity_Terminal__c> lstNewOpportunityTerminals = new List<GEFUE_Opportunity_Terminal__c>();
        List<GEFUE_Opportunity_Terminal__c> lstOppTerminals = [
                                                                    SELECT
                                                                        Id,
                                                                        Terminal__c,
                                                                        Opportunity__c
                                                                    FROM
                                                                        GEFUE_Opportunity_Terminal__c
                                                                    WHERE
                                                                        Opportunity__c IN :packageIds
																];
        Set<Id> currentTerminalId = new Set<Id>();
        for (GEFUE_Opportunity_Terminal__c oppTerm : lstOppTerminals) {
            currentTerminalId.add(oppTerm.Terminal__c);
        }
        for (Id tempTermId : mapTerminalPackageIds.keySet()) {
            if (!currentTerminalId.contains(tempTermId)) {
                GEFUE_Opportunity_Terminal__c oppTermJO = new GEFUE_Opportunity_Terminal__c();
                oppTermJO.Terminal__c = tempTermId;
                oppTermJO.Opportunity__c = mapTerminalPackageIds.get(tempTermId);
                lstNewOpportunityTerminals.add(oppTermJO);
            }
        }
        
        if (lstNewOpportunityTerminals.size() > 0) {
            upsert lstNewOpportunityTerminals;
        }
    }
    
    /* Checks Package and Terminal populated in new record being updated */
    public void checkPackageAndTerminalUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        Set<Id> setPackageId = new Set<Id>();
        Set<Id> setTerminalId = new Set<Id>();
        Set<Id> setOldTerminalId = new Set<Id>();
        Map<Id, Id> mapTerminalPackageIds = new Map<Id, Id>();
        Map<Id, Id> mapOldTerminalPackageIds = new Map<Id, Id>();
        for (Opportunity tempOpp : (List<Opportunity>) newList) {
            if (tempOpp.GEFUE_Terminal__c != NULL && 
                tempOpp.GEFUE_Package__c != NULL && 
                tempOpp.GEFUE_Terminal__c != ((Opportunity)oldMap.get(tempOpp.Id)).GEFUE_Terminal__c) {
                setPackageId.add(tempOpp.GEFUE_Package__c);
                setTerminalId.add(tempOpp.GEFUE_Terminal__c);
				setOldTerminalId.add(((Opportunity)oldMap.get(tempOpp.Id)).GEFUE_Terminal__c);
                mapTerminalPackageIds.put(tempOpp.GEFUE_Terminal__c, tempOpp.GEFUE_Package__c);
				mapOldTerminalPackageIds.put(((Opportunity)oldMap.get(tempOpp.Id)).GEFUE_Terminal__c, tempOpp.GEFUE_Package__c);
            }
        }
        fetchPackageTerminalUpdate(setPackageId, setTerminalId, setOldTerminalId, mapTerminalPackageIds, mapOldTerminalPackageIds);
    }
    
    /* Checks package related Opportunity Terminals and inserts new if not present, removes the ones not required */
    public void fetchPackageTerminalUpdate(Set<Id> packageIds, Set<Id> terminalIds, Set<Id> oldTerminalIds, Map<Id, Id> mapTerminalPackageIds, Map<Id, Id> mapOldTerminalPackageIds) {
		List<GEFUE_Opportunity_Terminal__c> lstNewOpportunityTerminals = new List<GEFUE_Opportunity_Terminal__c>();
        List<GEFUE_Opportunity_Terminal__c> lstOppTerminals = [
                                                                    SELECT
                                                                        Id,
                                                                        Terminal__c,
                                                                        Opportunity__c
                                                                    FROM
                                                                        GEFUE_Opportunity_Terminal__c
                                                                    WHERE
                                                                        Opportunity__c IN :packageIds
																];
        Set<Id> currentTerminalId = new Set<Id>();
        Set<Id> terminalIdDel = new Set<Id>();
        for (GEFUE_Opportunity_Terminal__c oppTerm : lstOppTerminals) {
            currentTerminalId.add(oppTerm.Terminal__c);
        }
        for (Id tempTermId : mapTerminalPackageIds.keySet()) {
            if (!currentTerminalId.contains(tempTermId)) {
                GEFUE_Opportunity_Terminal__c oppTermJO = new GEFUE_Opportunity_Terminal__c();
                oppTermJO.Terminal__c = tempTermId;
                oppTermJO.Opportunity__c = mapTerminalPackageIds.get(tempTermId);
                lstNewOpportunityTerminals.add(oppTermJO);
            }
        }
        
        if (lstNewOpportunityTerminals.size() > 0) {
            upsert lstNewOpportunityTerminals;
        }
        
        Map<Id, List<Opportunity>> mapOldTermOpp = new Map<Id, List<Opportunity>>();
        List<Opportunity> lstSiteOppWithOldTerm = [
            										SELECT
														Id,
            											GEFUE_Package__c,
            											GEFUE_Terminal__c
            										FROM
            											Opportunity
            										WHERE
            											GEFUE_Package__c IN :packageIds
        										];
        
        for (Opportunity oppTemp : lstSiteOppWithOldTerm) {
            if (!mapOldTermOpp.containsKey(oppTemp.GEFUE_Terminal__c)) {
				mapOldTermOpp.put(oppTemp.GEFUE_Terminal__c, new List<Opportunity>{oppTemp});
            } else {
                mapOldTermOpp.get(oppTemp.GEFUE_Terminal__c).add(oppTemp);
            }
        }
        
        Set<Id> setTerminalIdDel = new Set<Id>();
        Set<Id> setPackageIdDel = new Set<Id>();
        for (Id termOldId : oldTerminalIds) {
            List<Opportunity> tempOpp;
            if (mapOldTermOpp.get(termOldId) == null) {
                tempOpp = new List<Opportunity>();
            } else {
                tempOpp = mapOldTermOpp.get(termOldId);
            }
            if (tempOpp.size() == 0) {
                setTerminalIdDel.add(termOldId);
                setPackageIdDel.add(mapOldTerminalPackageIds.get(termOldId));
            }
        }
        
        List<GEFUE_Opportunity_Terminal__c> lstOppTerminalstoDelete = [
                                                                        SELECT
                                                                            Id,
                                                                            Terminal__c,
                                                                            Opportunity__c
                                                                        FROM
                                                                            GEFUE_Opportunity_Terminal__c
                                                                        WHERE
                                                                            Terminal__c IN :setTerminalIdDel
            															AND
            																Opportunity__c IN :setPackageIdDel
																	];
        if (lstOppTerminalstoDelete.size() > 0) {
            delete lstOppTerminalstoDelete;
        }
    }
    
    /* Updates the volumes of Gas and Diesel based on the stage of Site Opportunities in Terminals */
    public void takeSiteOpportunitiesForTerminal(List<SObject> newList, Map<Id, SObject> oldMap) {
        Set<Id> setPackageId = new Set<Id>();
        Set<Id> setTerminalId = new Set<Id>();
        for (Opportunity tempOpp : (List<Opportunity>) newList) {
            if (tempOpp.GEFUE_Terminal__c != NULL && tempOpp.GEFUE_Package__c != NULL) {
                setPackageId.add(tempOpp.GEFUE_Package__c);
                setTerminalId.add(tempOpp.GEFUE_Terminal__c);
                setTerminalId.add(((Opportunity)oldMap.get(tempOpp.Id)).GEFUE_Terminal__c);
            }
        }
        
        if (setPackageId.size() > 0 && setTerminalId.size() > 0) {
            List<GEFUE_Opportunity_Terminal__c> lstOppTerminals = [
                													SELECT
                														Id,
                														Terminal__c,
                														Opportunity__c,
                														Total_Volume__c
                													FROM
                														GEFUE_Opportunity_Terminal__c
                													WHERE
                														Opportunity__c IN :setPackageId
                													AND
                														Terminal__c IN :setTerminalId
            													];
            List<Opportunity> lstSiteOpportunities = [
                										SELECT
                											Id,
                											GEFUE_Package__c,
                											GEFUE_Terminal__c,
                											GEFUE_Total_Quantity__c,
                											StageName
                										FROM
                											Opportunity
                										WHERE
                											GEFUE_Package__c IN :setPackageId
            										];
            Map<Id, List<Opportunity>> mapTerminalSiteOpp = new Map<Id, List<Opportunity>>();
            for (Opportunity oppSite : lstSiteOpportunities) {
                if (!mapTerminalSiteOpp.containsKey(oppSite.GEFUE_Terminal__c)) {
                    mapTerminalSiteOpp.put(oppSite.GEFUE_Terminal__c, new List<Opportunity>{oppSite});
                } else {
                    mapTerminalSiteOpp.get(oppSite.GEFUE_Terminal__c).add(oppSite);
                }
            }
            
            for (GEFUE_Opportunity_Terminal__c oppTermTemp : lstOppTerminals) {
                Decimal sumVolumeTemp = 0;
                for (Opportunity oppTemp : mapTerminalSiteOpp.get(oppTermTemp.Terminal__c)) {
                    if(oppTemp.StageName != 'Closed - Lost'){
                    	sumVolumeTemp += oppTemp.GEFUE_Total_Quantity__c;
                    }
                }
                oppTermTemp.Total_Volume__c = sumVolumeTemp;
            }
            if (lstOppTerminals.size() > 0) {
                update lstOppTerminals;
            }
        }
    }
}