/*****************************************************************************************
*   Date: 08/25/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  This is queable class which Clones Quote Line Items
*   Version 1.1 
****************************************************************************************/
public with Sharing class PCRM_BatchCloneQuoteLineItems implements Queueable
{
    private List<Quote> lstNewQuotes = new List<Quote>();
    private List<QuoteLineItem> lstNewQuoteLineItem = new List<QuoteLineItem>();
    private map<Id, Id> mapOldQuoteIdWithNewQuoteId = new map<Id, Id>();
    List<PCRM_Batch_Clone__mdt> lstQLICustomCloneField = new List<PCRM_Batch_Clone__mdt>();
    SET<ID> keys = new SET<ID>();
    //constructor
    public PCRM_BatchCloneQuoteLineItems(List<Quote> lstQuotes) {
        
        if (lstQuotes != null && lstQuotes.size() > 0){
            this.lstNewQuotes = lstQuotes;
            for(Quote objQuote:lstNewQuotes){
                mapOldQuoteIdWithNewQuoteId.put(objQuote.PCRM_Quote_Cloned_From__c,objQuote.Id);
                keys.add(objQuote.PCRM_Quote_Cloned_From__c);           
            }  
            lstQLICustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('QuoteLineItem');
        }
        
    }
    
    //execute method to process records
    public void execute(QueueableContext context) 
    {        
        if(lstNewQuotes != null && lstNewQuotes.size() > 0){
            PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();        
            String strQuery1 = 'SELECT ';        
        	for (PCRM_Batch_Clone__mdt BC : lstQLICustomCloneField){
           		strQuery1 += BC.PCRM_TargetField__c + ',';
            }
            strQuery1 += 'Id From QuoteLineItem Where QuoteId IN: keys';
            
            for (QuoteLineItem objQuoteLineItem: Database.query(strQuery1)){
               
                QuoteLineItem objNewQuoteLineItem = new QuoteLineItem();
                
            	for(PCRM_Batch_Clone__mdt BatchClone:lstQLICustomCloneField){
                	objNewQuoteLineItem.put(BatchClone.PCRM_TargetField__c ,objQuoteLineItem.get(BatchClone.PCRM_SourceField__c)); 
            	}  
                objNewQuoteLineItem.QuoteId = mapOldQuoteIdWithNewQuoteId.get(objQuoteLineItem.QuoteId);
                objNewQuoteLineItem.PCRM_Previous_Period_Amount__c = objQuoteLineItem.UnitPrice;
                objNewQuoteLineItem.PCRM_isCreatedFromCloning__c = true;
                lstNewQuoteLineItem.add(objNewQuoteLineItem);
        	} //for  
            
            try{
                if(lstNewQuoteLineItem != null && (!lstNewQuoteLineItem.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewQuoteLineItem,'insert');  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'QuoteLineItem','PCRM_BatchCloneQuoteLineItems','Scheduled','PCRM_IT_Support');
            	 
                    insert lstNewQuoteLineItem;                 
                    system.debug('Batch successfully Finished!!!!'); 
                }                
            }catch(Exception Ex){
                  PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'QuoteLineItem','PCRM_BatchCloneQuoteLineItems','Scheduled','PCRM_IT_Support');
			}   
        }  //if
    }
}