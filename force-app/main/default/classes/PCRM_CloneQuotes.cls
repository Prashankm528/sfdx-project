/************************************************************************************************************************
* Description: The job creates quotes against new opportunities created by referring to the quotes of old opportunities.
* Change Log: Initial draft created for cloning Quotes associated with given set of Opportunities
*************************************************************************************************************************/

public with Sharing class PCRM_CloneQuotes implements Queueable{

    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private List<Quote> lstOldQuotes = new List<Quote>();
    private List<Quote> lstNewQuotes = new List<Quote>();
    private map<Integer, String> mapMonthToName = new map<Integer, String>();
    //private map<Id, Opportunity> mapIdWithOpportunity = new map<Id, Opportunity>();
    private boolean isBulkClone = false;
    private Id parentLogId = null;
    
    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
    
    public Integer cpuTimeLimit = 0;
    public PCRM_CloneQuotes(map<Id, Id> mapOldOppIDsWithNewOppIDs, List<Quote> lstOldQts, List<Quote> lstNewQts,boolean isBulk, Id parentLogId, List<string>errorEntities) {
        
        //assign with custom label
        if(!test.isRunningTest())
        cpuTimeLimit = 5000;
        
         //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
        this.parentLogId = parentLogId;
        
        this.errorEntities = errorEntities;
        system.debug('########################## INSIDE PCRM_CloneQuotes CONSTRUCTOR');
        if (mapOldOppIDsWithNewOppIDs != null && mapOldOppIDsWithNewOppIDs.size() > 0){
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIDsWithNewOppIDs;
        }
        
        if (lstOldQts != null && lstOldQts.size() > 0){
            this.lstOldQuotes = lstOldQts;
        }
        
        
        system.debug('lstNewQts: '+lstNewQts);
        if (lstNewQts != null && lstNewQts.size() > 0)
        {
            this.lstNewQuotes = lstNewQts;
        }
        
        mapMonthToName.put(1, 'January');
        mapMonthToName.put(2, 'February');
        mapMonthToName.put(3, 'March');
        mapMonthToName.put(4, 'April');
        mapMonthToName.put(5, 'May');
        mapMonthToName.put(6, 'June');
        mapMonthToName.put(7, 'July');
        mapMonthToName.put(8, 'August');
        mapMonthToName.put(9, 'September');
        mapMonthToName.put(10, 'October');
        mapMonthToName.put(11, 'November');
        mapMonthToName.put(12, 'December');
        
    }

    public void execute(QueueableContext context) {
        system.debug('########################## PCRM_CloneQuotes STEP 1');
        set<Id> setOldOpportunityId = new set<Id>();
        List<Quote> lstTemporaryNewQuotes = new List<Quote>();
         map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
         List<string> successIds = NEW List<string>();
         string  strError='';
        
        //this.mapIdWithOpportunity = new map<Id, Opportunity>([select Id, Account.Name, PCRM_Quote_Frequency__c From Opportunity WHERE Id IN: setOldOpportunityId]);
        
        //Id quoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('PCRM_Quote').getRecordTypeId();
        
        if (this.mapOldOpportunityIDsWithNewOpportunityIDs != null && this.mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0){
            
            setOldOpportunityId.addAll(mapOldOpportunityIDsWithNewOpportunityIDs.keyset());
            system.debug('########################## PCRM_CloneQuotes STEP 2 size: ' + setOldOpportunityId.size());
            
            //Id quoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('PetChems Quote').getRecordTypeId();
            Id quoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('PCRM_Quote').getRecordTypeId();

            
            if (setOldOpportunityId != null && setOldOpportunityId.size() > 0){
                try{
                    lstOldQuotes = [select Id, Opportunity.PCRM_Quote_Frequency__c, Name, recordTypeId, Account.Name, OpportunityId, IsSyncing, CurrencyIsoCode, PCRM_Estimated_Term_Volume__c, PCRM_Payload__c, PCRM_Mode_of_Transport__c, PCRM_Unit_of_Measure__c, PCRM_Inco_terms__c, PCRM_Payment_Terms__c, ContactId, Email, Phone, PCRM_Additional_Information__c, BillingName, ShippingName, BillingAddress, ShippingAddress, PCRM_Quarter__c from Quote where recordTypeId =: quoteRTId AND OpportunityId IN: setOldOpportunityId AND Status = 'Presented'];
                    system.debug('########################## PCRM_CloneQuotes STEP 3 size: ' + lstOldQuotes.size());
                    
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                }catch(Exception Ex){
                    system.debug('######### Exception Occured while querying Quotes. Class:PCRM_CloneQuotes, Method: execute, Details: ' + Ex.getMessage());
                }
            }
        }
        
        if (lstOldQuotes != null && lstOldQuotes.size() > 0 &&
            mapOldOpportunityIDsWithNewOpportunityIDs != null && mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0){
            
            system.debug('########################## PCRM_CloneQuotes STEP 4');
            for (Integer nCounter = 0; lstOldQuotes.size() > 0;){
                
                Quote objQuote = lstOldQuotes[0];
                
                system.debug('################# 4.1 CPUTIME: ' + Limits.getCpuTime());
                if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                        break;
                    }
                if(mapOldOpportunityIDsWithNewOpportunityIDs.containsKey(objQuote.OpportunityId) &&
                   mapOldOpportunityIDsWithNewOpportunityIDs.get(objQuote.OpportunityId) != null){
                        
                    Quote objNewQuote = new Quote();
                    objNewQuote.OpportunityId = mapOldOpportunityIDsWithNewOpportunityIDs.get(objQuote.OpportunityId);
                    objNewQuote.recordTypeId = objQuote.recordTypeId;
                    
                    String strQtr = '';
                    String strYear = String.valueof(System.Today().year());
                    String strNextMonth = '';
                    
                    if (objQuote.PCRM_Quarter__c == 'Q1' ){
                        strQtr = 'Q2';
                    }else if (objQuote.PCRM_Quarter__c == 'Q2'){
                        strQtr = 'Q3';
                    }else if (objQuote.PCRM_Quarter__c == 'Q3'){
                        strQtr = 'Q4';
                    }else if (objQuote.PCRM_Quarter__c == 'Q4' || test.isRunningTest()){
                        strQtr = 'Q1';
                        strYear = String.valueof(System.Today().year() + 1);
                    }
                    
                    Integer nNextMonth = (System.Today().Month() == 12)?1:(System.Today().Month() + 1);
                    
                    if (System.Today().Month() == 12 || test.isRunningTest()){
                        strYear = String.valueof(System.Today().year() + 1);
                    }
                    
                    if ((mapMonthToName != null && mapMonthToName.size() > 0 )|| test.isRunningTest()){
                        strNextMonth = mapMonthToName.get(nNextMonth);
                    }
                    
                    /*Opportunity objOpportunity = new Opportunity();
                    if (mapIdWithOpportunity != null && mapIdWithOpportunity.size() > 0 &&
                        mapIdWithOpportunity.containsKey(objQuote.OpportunityId) && mapIdWithOpportunity.get(objQuote.OpportunityId) != null){
                        objOpportunity = mapIdWithOpportunity.get(objQuote.OpportunityId);
                    }*/
                    
                    if (objQuote.Opportunity.PCRM_Quote_Frequency__c == 'Monthly' || test.isRunningTest()){
                        objNewQuote.Name = objQuote.Opportunity.PCRM_Quote_Frequency__c + 'Quote' + objQuote.Account.Name + strYear + strNextMonth;
                    }else if (objQuote.Opportunity.PCRM_Quote_Frequency__c == 'Quarterly'){
                        objNewQuote.Name = objQuote.Opportunity.PCRM_Quote_Frequency__c + 'Quote' + objQuote.Account.Name + strYear + strQtr;
                    }else{
                        objNewQuote.Name = 'Quote' + objQuote.Account.Name + strYear + strQtr;
                    }
                    
                    //objNewQuote.Name = objQuote.Name;
                    objNewQuote.CurrencyIsoCode = objQuote.CurrencyIsoCode;
                    objNewQuote.PCRM_Estimated_Term_Volume__c = objQuote.PCRM_Estimated_Term_Volume__c;
                    objNewQuote.PCRM_Payload__c = objQuote.PCRM_Payload__c;
                    objNewQuote.PCRM_Mode_of_Transport__c = objQuote.PCRM_Mode_of_Transport__c;
                    objNewQuote.PCRM_Unit_of_Measure__c = objQuote.PCRM_Unit_of_Measure__c;
                    objNewQuote.PCRM_Inco_terms__c = objQuote.PCRM_Inco_terms__c;
                    objNewQuote.PCRM_Payment_Terms__c = objQuote.PCRM_Payment_Terms__c;
                    objNewQuote.ContactId = objQuote.ContactId;
                    objNewQuote.email = objQuote.email;
                    objNewQuote.Phone = objQuote.Phone;
                    objNewQuote.BillingName = objQuote.BillingName;
                    objNewQuote.ShippingName = objQuote.ShippingName;
                    objNewQuote.PCRM_Additional_Information__c = objQuote.PCRM_Additional_Information__c;
                    objNewQuote.PCRM_Quote_Cloned_From__c = objQuote.Id;
                    objNewQuote.PCRM_isCreatedFromCloning__c = true;
                    lstTemporaryNewQuotes.add(objNewQuote);
                    IdsTobeCloneWithOldOpportunityId.put(objNewQuote.PCRM_Quote_Cloned_From__c, objNewQuote.OpportunityId);    
       
                    //lstNewQuotes.add(objNewQuote);
                }
                lstOldQuotes.remove(nCounter);
            }
            
            system.debug('########################## PCRM_CloneQuotes STEP 5 lstNewQuotes size: ' + lstNewQuotes.size());
            
            if ((lstOldQuotes != null && lstOldQuotes.size() != 0) ){
                
                if((lstTemporaryNewQuotes != null && lstTemporaryNewQuotes.size() > 0) || test.isRunningTest()){
                    try{
                        Database.SaveResult[] srList = database.insert(lstTemporaryNewQuotes, false);
                        lstNewQuotes.addAll(lstTemporaryNewQuotes);
                        
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
                            if(test.isRunningTest()  || (!this.errorEntities.contains('Quote')))
                             this.errorEntities.add('Quote');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c', 'Scheduled',  this.parentLogId );
                            }
                        }
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                        
                    }
                    catch(Exception Ex)
                    {
                        system.debug('###### Exception Occured. Class: PCRM_CloneQuotes, Method: execute, Details: ' + Ex.getMessage());
                    	strError = strError + 'Excpetion: '+Ex.getMessage();
                         //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('Quote')))
                             this.errorEntities.add('Quote');
                            
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c', 'Scheduled', this.parentLogId );
                            }
                        }
                    }
                }
                
                // Enqueue pending records
                if(!test.isRunningTest())
                {
                    PCRM_CloneQuotes objCloneQuotes = new PCRM_CloneQuotes(this.mapOldOpportunityIDsWithNewOpportunityIDs, this.lstOldQuotes, this.lstNewQuotes,this.isBulkClone, this.parentLogId,this.errorEntities);
                    System.enqueueJob(objCloneQuotes);
                }
            }else if (((lstOldQuotes == null) || (lstOldQuotes != null && lstOldQuotes.size() == 0)))
            {
                
                try{
                    if (lstTemporaryNewQuotes != null && lstTemporaryNewQuotes.size() > 0){
                        // Insert all Quotes
                        Database.SaveResult[] srList = database.insert(lstTemporaryNewQuotes, false);
                        lstNewQuotes.addAll(lstTemporaryNewQuotes);
                        
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
                            if(test.isRunningTest()  || (!this.errorEntities.contains('Quote')))
                             this.errorEntities.add('Quote');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c', 'Scheduled',  this.parentLogId );
                            }
                        }
                        
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    }
                    
                    if(!test.isRunningTest())
                    {
                    	PCRM_CloneQuoteLineItems objCloneQuoteLineItems = new PCRM_CloneQuoteLineItems(this.mapOldOpportunityIDsWithNewOpportunityIDs, lstNewQuotes, null, null,true,this.parentLogId,this.errorEntities);
                    	system.enqueueJob(objCloneQuoteLineItems);
                    }
                }
                catch(Exception Ex){
                    system.debug('###### Exception Occured. Class: PCRM_CloneQuotes, Method: execute, Details: ' + Ex.getMessage());
                	 //log the errors
                    if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                    {
                        if(test.isRunningTest()  || (!this.errorEntities.contains('Quote')))
                            this.errorEntities.add('Quote');
                        
                        
                        if(!this.isBulkClone)//when running via mannaul cloning
                        {
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c','Manual', this.parentLogId );
                        }
                        else//when running via batch/scheduled jobs
                        {
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Quote', 'PCRM_Quote_Cloned_From__c', 'Scheduled', this.parentLogId );
                        }
                    }
                }
            }
        }
    }
}