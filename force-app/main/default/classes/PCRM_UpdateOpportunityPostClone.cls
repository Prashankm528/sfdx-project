/*****************************************************************************************
*   Date: 06/23/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  
*   Version 1.1 
****************************************************************************************/
public with Sharing class PCRM_UpdateOpportunityPostClone implements Queueable{

    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();

    //contructor
    public PCRM_UpdateOpportunityPostClone(map<Id, Id> mapOldOppIDsWithNewOppIDs)
    {    
        if (mapOldOppIDsWithNewOppIDs != null && mapOldOppIDsWithNewOppIDs.size() > 0)
        {
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIDsWithNewOppIDs;
        }
    }

    //execute method
    public void execute(QueueableContext context) {
        
        if (mapOldOpportunityIDsWithNewOpportunityIDs != null && mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0){
            
            set<Id> setNewOpportunityId = new set<Id>();
            setNewOpportunityId.addAll(mapOldOpportunityIDsWithNewOpportunityIDs.values());
            
            if (setNewOpportunityId != null && setNewOpportunityId.size() > 0){
                List<Opportunity> lstOpportunity = [select Id, PCRM_isFirstSyncWithQuote__c from Opportunity WHERE Id IN: setNewOpportunityId AND PCRM_isFirstSyncWithQuote__c = true];
                
                if (lstOpportunity != null && lstOpportunity.size() > 0){
                    for (Opportunity objOpportunity: lstOpportunity){
                        objOpportunity.PCRM_isFirstSyncWithQuote__c = false;
                    }
                }
                
                update lstOpportunity;
            }
            
        }
    }
}