/************************************************************************************************************************
*   Date: 08/25/2020
*   Author:   Pooja Deokar(TCS)
* 	Description: The job creates quotes against new opportunities created by referring to the quotes of old opportunities.
* 	Change Log: Initial draft created for cloning Quotes associated with given set of Opportunities
*************************************************************************************************************************/

public with Sharing class PCRM_BatchCloneQuotes implements Queueable
{
    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private List<Quote> lstNewQuotes = new List<Quote>();
    List<Opportunity> lstOpportunityUpdate = new List<Opportunity>();
    List<PCRM_Batch_Clone__mdt> lstquoteCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
    PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
    SET<ID> keys = new SET<ID>();
    
    public PCRM_BatchCloneQuotes(map<Id, Id> mapOldOppIDsWithNewOppIDs) {    
        if (mapOldOppIDsWithNewOppIDs != null && mapOldOppIDsWithNewOppIDs.size() > 0){
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIDsWithNewOppIDs;
        }   
        keys.addAll(mapOldOpportunityIDsWithNewOpportunityIDs.keySet());
        lstquoteCustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('Quote');
	}

    public void execute(QueueableContext context) 
    {             
    	Id quoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('PCRM_Quote').getRecordTypeId();
	    String strQuery1 = 'SELECT ';        
        for (PCRM_Batch_Clone__mdt BC : lstquoteCustomCloneField){
            strQuery1 += BC.PCRM_TargetField__c + ',';
        }  
        strQuery1 += 'Id,Opportunity.PCRM_Quote_Frequency__c,Account.Name From Quote Where recordTypeId =: quoteRTId AND IsSyncing = true AND OpportunityId IN: keys AND (status = \'Presented\' OR Status = \'Accepted\' )';
		
        for(Quote objQuote:Database.query(strQuery1)){
            
        	Quote objNewQuote = new Quote();
            
            for(PCRM_Batch_Clone__mdt BatchClone:lstquoteCustomCloneField){
                objNewQuote.put(BatchClone.PCRM_TargetField__c ,objQuote.get(BatchClone.PCRM_SourceField__c)); 
            }  
            objNewQuote.OpportunityId = mapOldOpportunityIDsWithNewOpportunityIDs.get(objQuote.OpportunityId);
			objNewQuote.PCRM_isCreatedFromCloning__c = true;
            objNewQuote.PCRM_Quote_Cloned_From__c = objQuote.Id;
            objNewQuote.Status ='Draft';
            
            if (objQuote.Opportunity.PCRM_Quote_Frequency__c == 'Quarterly'){
                objNewQuote.Name = objQuote.Opportunity.PCRM_Quote_Frequency__c + 'Quote-' + objQuote.Account.Name +'-'+ PCRM_BatchCloneUtil.getYear('Quarterly') +'-'+ PCRM_BatchCloneUtil.getQuarter();
            } 
            else{                   
               objNewQuote.Name = objQuote.Opportunity.PCRM_Quote_Frequency__c + 'Quote-' + objQuote.Account.Name +'-'+ PCRM_BatchCloneUtil.getYear('Monthly') +'-'+ PCRM_BatchCloneUtil.getMonth();
            }
            
            lstNewQuotes.add(objNewQuote); 
		}//for   
		
		try{
			if(lstNewQuotes != null && (!lstNewQuotes.isEmpty())) {
                result = PCRM_BatchCloneUtil.insertRecords(lstNewQuotes,'insert');  
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Quote','PCRM_BatchCloneQuotes','Scheduled','PCRM_IT_Support');
            	 
				//Sync newly created quote with opportunity
				syncQuoteWithOpportunity(lstNewQuotes);
			  
				PCRM_BatchCloneQuoteLineItems objCloneQLI = new PCRM_BatchCloneQuoteLineItems(lstNewQuotes);
				system.enqueueJob(objCloneQLI);
			}                
		}catch(Exception Ex){
			PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Quote','PCRM_BatchCloneQuotes','Scheduled','PCRM_IT_Support');
		}   
        
    }//execute
    
    //Method is used to sync the newly created quote with opportunity.
    public void syncQuoteWithOpportunity(List<Quote> lstNewQuotes){
        result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
        if(lstNewQuotes != NULL && lstNewQuotes.size() > 0){
            for(Quote quot:lstNewQuotes){
                Opportunity opty = new Opportunity();
                opty.PCRM_isFirstSyncWithQuote__c = false;
                opty.ID = quot.OpportunityId;
                opty.SyncedQuoteID = quot.id;
            	lstOpportunityUpdate.add(opty);
            }
            try{
                if(lstOpportunityUpdate != null && (!lstOpportunityUpdate.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstOpportunityUpdate,'update');  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Opportunity','PCRM_BatchCloneQuotes.syncQuoteWithOpportunity','Scheduled','PCRM_IT_Support');
            	 
                    update lstOpportunityUpdate;                    
             }           	                
            }catch(Exception Ex){
                 PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Opportunity','PCRM_BatchCloneQuotes.syncQuoteWithOpportunity','Scheduled','PCRM_IT_Support');
			}  
        }
	}
}