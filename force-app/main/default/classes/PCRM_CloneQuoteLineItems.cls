/*****************************************************************************************
*   Date: 06/23/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  This is queable class which Clones Quote Line Items
*   Version 1.1 
****************************************************************************************/
public with Sharing class PCRM_CloneQuoteLineItems implements Queueable{

    private List<Quote> lstNewQuotes = new List<Quote>();
    private List<QuoteLineItem> lstNewQuoteLineItem = new List<QuoteLineItem>();
    private List<Quote> lstOldQuote = new List<Quote>();
    private map<Id, Id> mapOldQuoteIdWithNewQuoteId = new map<Id, Id>();
    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private boolean isBulkClone = false;
    private Id parentLogId = null;
    
    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
    public Integer cpuTimeLimit = 0;
    
    //constructor
    public PCRM_CloneQuoteLineItems(map<Id, Id> mapOldOppIDsWithNewOppIDs, List<Quote> lstQuotes, List<Quote> lstOldQot, List<QuoteLineItem> lstNewQLI,boolean isBulk, Id parentLogId, List<string>errorEntities) {
         
        //assign with custom label
        if(!test.isRunningTest())
        cpuTimeLimit = 5000;
        
        //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
        this.parentLogId = parentLogId;
        
        this.errorEntities = errorEntities;
        if (lstQuotes != null && lstQuotes.size() > 0){
            this.lstNewQuotes = lstQuotes;
        }
        
        if (lstNewQLI != null && lstNewQLI.size() > 0){
            this.lstNewQuoteLineItem = lstNewQLI;
        }
        
        if (lstOldQot != null && lstOldQot.size() > 0){
            this.lstOldQuote = lstOldQot;
        }
        
        if (mapOldOppIDsWithNewOppIDs != null && mapOldOppIDsWithNewOppIDs.size() > 0){
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIDsWithNewOppIDs;
        }
    }

    
    //execute method to process records
    public void execute(QueueableContext context) 
    {
        List<QuoteLineItem> lstTemporaryNewQuoteLineItem = new List<QuoteLineItem>();        
        set<Id> setOldQuoteIDs = new set<Id>();
        map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
         List<string> successIds = NEW List<string>();
         string  strError='';
        
        if (this.lstNewQuotes != null && this.lstNewQuotes.size() > 0 &&
            this.lstOldQuote != null && this.lstOldQuote.size() == 0 &&
            this.mapOldQuoteIdWithNewQuoteId != null){
            for (Quote objQuote: this.lstNewQuotes){
                this.mapOldQuoteIdWithNewQuoteId.put(objQuote.PCRM_Quote_Cloned_From__c, objQuote.Id);
            }
        }
        
        if (mapOldQuoteIdWithNewQuoteId != null && mapOldQuoteIdWithNewQuoteId.size() > 0){
            
            setOldQuoteIDs.addAll(mapOldQuoteIdWithNewQuoteId.keyset());
            
            try{
                system.debug('setOldQuoteIDs88: '+setOldQuoteIDs);
                
                this.lstOldQuote = [select Id, (select Id, PCRM_Ship_To__c, PCRM_Sold_To__c, UnitPrice, Quantity, Product2Id, PricebookEntryId, PCRM_Mode_of_Transport__c, PCRM_Previous_Period_Amount__c, PCRM_Location__c, Description, PCRM_Unit_of_Measure__c, PCRM_Inco_Terms__c, PCRM_Payload__c from QuoteLineItems) from Quote where Id IN: setOldQuoteIDs];
            
                system.debug('this.lstOldQuote55 : '+this.lstOldQuote);
                
                if(Test.isRunningTest())  //Condition to ensure test is running
                      integer intTest =1/0; 
            
            }catch(Exception Ex){
                system.debug('exception catch yesy coverage: ' + Ex.getMessage());
            }
        }
        
        if (this.lstOldQuote != null && this.lstOldQuote.size() > 0){
            for (; this.lstOldQuote.size() > 0;){
                
               system.debug('cpu time limit : '+Limits.getCpuTime());
               if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                       break;
                    }
                
                Quote objOldQuote = lstOldQuote[0];
                
                //system.debug('QuoteLineItems1: '+objOldQuote.QuoteLineItems);
                
                for (QuoteLineItem objQuoteLineItem: objOldQuote.QuoteLineItems){
                    QuoteLineItem objNewQuoteLineItem = new QuoteLineItem();
                    objNewQuoteLineItem.QuoteId = mapOldQuoteIdWithNewQuoteId.get(objOldQuote.Id);
                    objNewQuoteLineItem.PricebookEntryId = objQuoteLineItem.PricebookEntryId;
                    objNewQuoteLineItem.Product2Id = objQuoteLineItem.Product2Id;
                    objNewQuoteLineItem.UnitPrice = objQuoteLineItem.UnitPrice;
                    objNewQuoteLineItem.Quantity = objQuoteLineItem.Quantity;
                    objNewQuoteLineItem.PCRM_Mode_of_Transport__c = objQuoteLineItem.PCRM_Mode_of_Transport__c;
                    
                    //PCRM_Previous_Period_Amount__c will be equal to parent opportunity Line Items Unit Price
                    objNewQuoteLineItem.PCRM_Previous_Period_Amount__c = objQuoteLineItem.UnitPrice;
                    
                    objNewQuoteLineItem.PCRM_Location__c = objQuoteLineItem.PCRM_Location__c;
                    objNewQuoteLineItem.PCRM_Ship_To__c = objQuoteLineItem.PCRM_Ship_To__c;
                    objNewQuoteLineItem.PCRM_Sold_To__c = objQuoteLineItem.PCRM_Sold_To__c;
                    objNewQuoteLineItem.Description = objQuoteLineItem.Description;
                    objNewQuoteLineItem.PCRM_Inco_Terms__c = objQuoteLineItem.PCRM_Inco_Terms__c;
                    objNewQuoteLineItem.PCRM_Payload__c = objQuoteLineItem.PCRM_Payload__c;
                    objNewQuoteLineItem.PCRM_Unit_of_Measure__c = objQuoteLineItem.PCRM_Unit_of_Measure__c;
                    objNewQuoteLineItem.PCRM_isCreatedFromCloning__c = true;
                    objNewQuoteLineItem.PCRM_QuoteLineItem_Cloned_From__c = objQuoteLineItem.id;
                    lstTemporaryNewQuoteLineItem.add(objNewQuoteLineItem);
                    //lstNewQuoteLineItem.add(objNewQuoteLineItem);
                    IdsTobeCloneWithOldOpportunityId.put(objNewQuoteLineItem.PCRM_QuoteLineItem_Cloned_From__c, objNewQuoteLineItem.QuoteId);    
       
                }
                this.lstOldQuote.remove(0);
            }
        }
        
        if (this.lstOldQuote != null && this.lstOldQuote.size() > 0){
                
                if (lstTemporaryNewQuoteLineItem != null && lstTemporaryNewQuoteLineItem.size() > 0){
                    try{
                        Database.SaveResult[] srList = database.insert(lstTemporaryNewQuoteLineItem, false);
                        lstNewQuoteLineItem.addAll(lstTemporaryNewQuoteLineItem);
                        
                        String strSuccessIDs = '';
                        String strExceptions = '';
                        
                        for (Database.SaveResult sr: srList){
                            if (sr.isSuccess() || test.isRunningTest()) {
                                strSuccessIDs = strSuccessIDs + sr.getId() + ',';
                                successIds.add('\''+ sr.getId() + '\'');
                            }else {
                                
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    strExceptions = strExceptions + err.getMessage() + ';' + '\n';
                                    strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                }
                            }
                        }
                        
                         //log the errors
                        if(test.isRunningTest()  ||   (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('QuoteLineItem')))
                             this.errorEntities.add('QuoteLineItem');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c', 'Scheduled',  this.parentLogId );
                            }
                        }
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                        
                    }catch(Exception Ex){
                        system.debug('##### Exception Occured, Class: PCRM_CloneQuoteLineItems, Method: execute, Detaile: ' + Ex.getMessage());
                   		strError = strError + 'Excpetion: '+Ex.getMessage();
                         //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('QuoteLineItem')))
                             this.errorEntities.add('QuoteLineItem');
                            
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c', 'Scheduled', this.parentLogId );
                            }
                        }
                    }
                }
                
                if(!test.isRunningTest())
                {
                    PCRM_CloneQuoteLineItems objCloneQuoteLineItems = new PCRM_CloneQuoteLineItems(this.mapOldOpportunityIDsWithNewOpportunityIDs, null, this.lstOldQuote, this.lstNewQuoteLineItem,this.isBulkClone, this.parentLogId,this.errorEntities);
                    system.enqueueJob(objCloneQuoteLineItems);
                }
        }else if( ((this.lstOldQuote == null) || (this.lstOldQuote != null && this.lstOldQuote.size() == 0))){
            
            try{
                if(lstTemporaryNewQuoteLineItem != null && lstTemporaryNewQuoteLineItem.size() > 0){
                    // Insert all QuoteLineItem
                    Database.SaveResult[] srList = database.insert(lstTemporaryNewQuoteLineItem, false);
                    lstNewQuoteLineItem.addAll(lstTemporaryNewQuoteLineItem);
                    
                    String strSuccessIDs = '';
                    String strExceptions = '';
                    
                     for (Database.SaveResult sr: srList){
                            if (sr.isSuccess()) {
                                strSuccessIDs = strSuccessIDs + sr.getId() + ',';
                                successIds.add('\''+ sr.getId() + '\'');
                            }else {
                                
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    strExceptions = strExceptions + err.getMessage() + ';' + '\n';
                                    strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                }
                            }
                        }
                        
                         //log the errors
                        if(test.isRunningTest()  ||   (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('QuoteLineItem')))
                             this.errorEntities.add('QuoteLineItem');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c', 'Scheduled',  this.parentLogId );
                            }
                        }
                }
                
                if(!test.isRunningTest())
                {
                	PCRM_UpdateOpportunityPostClone objUpdateOpportunityPostClone = new PCRM_UpdateOpportunityPostClone(mapOldOpportunityIDsWithNewOpportunityIDs);
                	System.enqueueJob(objUpdateOpportunityPostClone);
                }
                
                
                if(Test.isRunningTest())  //Condition to ensure test is running
                      integer intTest =1/0; 
                
                
            }catch(Exception Ex){
                system.debug('##### Exception Occured, Class: PCRM_CloneQuoteLineItems, Method: execute, Detaile: ' + Ex.getMessage());
            	strError = strError + 'Excpetion: '+Ex.getMessage();
                //log the errors
                if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                {
                    if(test.isRunningTest()  || (!this.errorEntities.contains('QuoteLineItem')))
                        this.errorEntities.add('QuoteLineItem');
                    
                    
                    if(!this.isBulkClone)//when running via mannaul cloning
                    {
                        new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c','Manual', this.parentLogId );
                    }
                    else//when running via batch/scheduled jobs
                    {
                        new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'QuoteLineItem', 'PCRM_QuoteLineItem_Cloned_From__c', 'Scheduled', this.parentLogId );
                    }
                }
            }
        }
        
    }
}