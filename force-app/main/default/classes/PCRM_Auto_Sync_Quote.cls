/*****************************************************************************************
*   Date: 06/06/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Class is used to sync the newly created quote.
*   Version 1.1 
****************************************************************************************/
public with sharing class PCRM_Auto_Sync_Quote {
    @InvocableMethod(label='PCRM Sync Quote Automatically' description='When quote record are created sync it with opportunity.')
    public static void syncQuote(List<Id> listUserNames) {
        syncQuoteAuto(listUserNames);
    }
    //called future method to sync quote because we need that quote line items should be created first 
    //then populate the quoteId on opportunity.
    @future
    public static void syncQuoteAuto(List<Id> listUserNames) {
         List<Opportunity> opps = new List<Opportunity>();
        // Boolean checkQuoteLineItems = false;
        // Loops through the List of Quotes and gets the OpportunityId.
        for (Quote q : [SELECT Name,id, Opportunity.PCRM_isCreatedFromCloning__c, OpportunityId FROM Quote WHERE Id in :listUserNames]) {
          
            if (string.isNotEmpty(q.OpportunityId)) {
                Opportunity opp = new Opportunity(Id = q.OpportunityId);
                opp.SyncedQuoteId  = q.Id;
                if (q.Opportunity.PCRM_isCreatedFromCloning__c){
                    opp.PCRM_isFirstSyncWithQuote__c = true;                       
                }
                opps.add(opp);
            }
        }
        system.debug('listUserNames==='+listUserNames.size());
        //Called sleep method to give time to create QLI
        if(listUserNames!= null && listUserNames.size() == 1){
            sleep();
        }  
        system.debug('opps===='+opps);
        //update the opportunity with quoteID
        if(!opps.isEmpty()) {                      
            update opps;
        }      
    }
    // Method is used to create delay.
    public static void sleep(){
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 9000) {
            //sleep for 3s
            finishTime = DateTime.now().getTime();
        }        
    }
}