/*****************************************************************************************
*   Date:     11/07/2020
*   Author:   Pooja Deokar(TCS)  
*   Description:   Class is used to sync quoteline item custom field with OLI fields
*   Changes: 0.1 
 
****************************************************************************************/
Public with sharing class PCRM_QuoteLineItemHelper{
	
    // Method is used to populate oli custom field into qli custom fiels
    public void qliBeforeInsertCustomFieldSync(List<QuoteLineItem> listQLI ){      
  		Map<String, String> quoteLineFieldMap = new Map<String, String>();
		Set<Id> oLIIds = new Set<Id>();    
		Set<Id> quoteIds = new Set<Id>(); 
		for (QuoteLineItem qli : listQLI) {		
			if (qli.QuoteId  != null) {
				quoteIds.add(qli.QuoteId );
			}
		}       
        for (quote qt : [SELECT OpportunityId FROM quote where id in :quoteIds]) {
			if (qt.OpportunityId  != null) {
				oLIIds.add(qt.OpportunityId );
			}
		}
        Map<String, QuoteLineSyncField__c> quoteLineFields = QuoteLineSyncField__c.getAll();
        for (String quoteLineField : quoteLineFields.keySet()) {
            QuoteLineSyncField__c quoteLineSyncField = QuoteLineSyncField__c.getInstance(quoteLineField);
            //FIXME - uppercase value cause NPE           
            quoteLineFieldMap.put(quoteLineField, quoteLineSyncField.OppLineSyncField__c);            
        }
        
		String query = 'Select Id,';
        for (String fieldName : quoteLineFieldMap.values()){
        	query += fieldName + ',';
        }
        query = query.removeEnd(',');
        query += ' FROM OpportunityLineItem where OpportunityId in :oLIIds';
       
		Map<Id, OpportunityLineItem> oLIEntries = new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(query));
		
		for (QuoteLineItem qli : listQLI) {
			OpportunityLineItem olis = oLIEntries.get(qli.Description );			
			if (olis != null) {                
                for (String fieldName : quoteLineFieldMap.keySet()){
					qli.put(fieldName,olis.get(quoteLineFieldMap.get(fieldName)));
                }               
			}
		}	    
        return;   
    }
}