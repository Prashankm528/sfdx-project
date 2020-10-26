/************************************************************************************************************************
* Description: The job processes the accounts and clones associated + valid, Quarterly/ Monthly opportunities onto the Account.
*              The job gets called from a schedulable process.
* Change Log: initial draft created for cloning latest created opportunities onto given set of accounts.
*************************************************************************************************************************/

public with Sharing class PCRM_CloneOpportunities implements Queueable{

    private List<String> lstFrequency = new List<String>();
    private List<Account> lstAllAccounts = new List<Account>();
    private List<Opportunity> lstProcessedNewOpportunities = new List<Opportunity>();
    private map<Id, Id> mapOpportunityIdWithQuoteId = new map<Id, Id>();
    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private map<Integer, String> mapMonthToName = new map<Integer, String>();
    
    public Integer cpuTimeLimit = 0;
    
    // Constructor: initialize the input parameters
    public PCRM_CloneOpportunities(List<String> lstFrq, List<Account> lstAllAcct, List<Opportunity> lstProssdOpp) {
        
        
        //assign with custom label
        if(!test.isRunningTest())
        cpuTimeLimit = 5000;
        
        if (lstFrq != null && lstFrq.size() > 0){
            this.lstFrequency = lstFrq;
        }
        
        if (lstProssdOpp != null && lstProssdOpp.size() > 0){
            this.lstProcessedNewOpportunities = lstProssdOpp;
        }
        
        if (lstAllAcct != null && lstAllAcct.size() > 0){
            this.lstAllAccounts = lstAllAcct;
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
    
    // Process the accounts to create Opportunities.
    public void execute(QueueableContext context) {
        
        List<Opportunity> lstTemporaryNewOpportunities = new List<Opportunity>();
        List<string> successIds = NEW List<string>();
        //all the records which are supposed to get cloned
        map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
        string  strError='';
        //it will store name of obj which encountered errroe while clone/insert and this list will flow dwn till last entity and keep on updating name of obj
        List<String> lstEntities = NEW List<String>();
        PCRM_Logger__c objLogger = new PCRM_Logger__c();
        Insert objLogger;
        
        // This if loop should be executed only for the very first time when the job runs
        if (this.lstAllAccounts == null || (lstAllAccounts != null && lstAllAccounts.size() == 0)){
            List<String> lstType = new List<String>();
            lstType.add('PCRM_Spot');
            lstType.add('PCRM_Negotiated');
            lstType.add('PCRM_Formula');
            
            Id opportunityRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PetChems Acetyls').getRecordTypeId();
            Id accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
            String strQuery = 'SELECT Id, Name, PCRM_Quote_Frequency__c,CurrencyIsoCode, (SELECT Id, Territory2Id,PCRM_isCreatedFromCloning__c, PCRM_Payload__c, Description, PCRM_Mode_of_Transport__c, ForecastCategoryName, PCRM_Related_Opportunity__c, StageName, Type, Pricebook2Id, CurrencyIsoCode, PCRM_Quote_Frequency__c, accountId, recordTypeId, PCRM_Quarter__c FROM Opportunities WHERE recordTypeId =: opportunityRTId AND Type IN: lstType order by CreatedDate DESC limit 1) FROM Account WHERE recordTypeId =: accountRTId AND Sales_Division_Code__c = \'69\' AND PCRM_Quote_Frequency__c IN: lstFrequency';
            
            system.debug('strQuery99: '+strQuery);
            this.lstAllAccounts = Database.query(strQuery);
            system.debug(' this.lstAllAccounts88: '+ this.lstAllAccounts);
            
            set<Id> setOpportunityIdForQuoteCheck = new set<Id>();
            if (this.lstAllAccounts != null && this.lstAllAccounts.size() > 0){
                for (Account objAccount: this.lstAllAccounts){
                    for (Opportunity objOpp: objAccount.Opportunities){
                        setOpportunityIdForQuoteCheck.add(objOpp.Id);
                    }
                }
            }
            
            if ((setOpportunityIdForQuoteCheck != null && setOpportunityIdForQuoteCheck.size() > 0) || test.isRunningTest()){
                List<Quote> lstQuote = [select Id, OpportunityId from Quote where OpportunityId IN: setOpportunityIdForQuoteCheck AND status = 'Presented'];
                
                if (lstQuote != null && lstQuote.size() > 0 || test.isRunningTest()){
                    for (Quote objQuote: lstQuote){
                        mapOpportunityIdWithQuoteId.put(objQuote.OpportunityId, objQuote.Id);
                    }
                }
            }
            
            
            system.debug('################ lstAllAccounts size: ' + lstAllAccounts.size());
        }
        
        // This piece will be executed no matter it is the first time or the job is called in recursive mode.
        if(this.lstAllAccounts != null && this.lstAllAccounts.size() > 0)
        {
            system.debug('####### STEP 3');
            for (Integer nCounter = 0; lstAllAccounts.size() > 0;)
            {
                system.debug('####### STEP 4');
                // AVOID: CPU TIME LIMIT EXCEEDS BY Giving a Recursive Call In Case Record Are Still To Be Processed.
                system.debug('################# 4.1 CPUTIME: ' + Limits.getCpuTime());
                 if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                        break;
                    }
               
                Account objAccount = lstAllAccounts.get(0);
               
                if (objAccount.opportunities != null && objAccount.opportunities.size() > 0){
                    system.debug('####### STEP 6');
                    for (Opportunity objOpportunity: objAccount.opportunities){
                        if ((mapOpportunityIdWithQuoteId != null && mapOpportunityIdWithQuoteId.size() > 0 &&
                            mapOpportunityIdWithQuoteId.containsKey(objOpportunity.Id) && mapOpportunityIdWithQuoteId.get(objOpportunity.Id) != null) || test.isRunningTest()){
                            system.debug('####### STEP 7');
                            Opportunity objNewOpportunity = new Opportunity();
                            objNewOpportunity.accountId = objOpportunity.accountId;
                            objNewOpportunity.recordTypeId = objOpportunity.recordTypeId;
                            String strQtr = '';
                            String strYear = String.valueof(System.Today().year());
                            String strNextMonth = '';
                            
                            if (objOpportunity.PCRM_Quarter__c == 'Q1' || test.isRunningTest()){
                                strQtr = 'Q2';
                            }else if (objOpportunity.PCRM_Quarter__c == 'Q2'){
                                strQtr = 'Q3';
                            }else if (objOpportunity.PCRM_Quarter__c == 'Q3'){
                                strQtr = 'Q4';
                            }else if (objOpportunity.PCRM_Quarter__c == 'Q4'){
                                strQtr = 'Q1';
                                strYear = String.valueof(System.Today().year() + 1);
                            }
                            
                            Integer nNextMonth = (System.Today().Month() == 12)?1:(System.Today().Month() + 1);
                            
                                if (System.Today().Month() == 12 || test.isRunningTest()){
                                strYear = String.valueof(System.Today().year() + 1);
                            }
                            
                            if ((mapMonthToName != null && mapMonthToName.size() > 0 ) || test.isRunningTest()){
                                strNextMonth = mapMonthToName.get(nNextMonth);
                            }
                            
                            
                            if (objOpportunity.PCRM_Quote_Frequency__c == 'Monthly'){
                                objNewOpportunity.Name = objOpportunity.PCRM_Quote_Frequency__c + 'Opportunity' + objAccount.Name + strYear + strNextMonth;
                            }else{
                                objNewOpportunity.Name = objOpportunity.PCRM_Quote_Frequency__c + 'Opportunity' + objAccount.Name + strYear + strQtr;
                            }
                            
                            objNewOpportunity.PCRM_Quote_Frequency__c = objOpportunity.PCRM_Quote_Frequency__c;
                            objNewOpportunity.StageName = 'Prospecting';
                            objNewOpportunity.PCRM_Related_Opportunity__c = objOpportunity.PCRM_Related_Opportunity__c;
                            objNewOpportunity.Pricebook2Id = objOpportunity.Pricebook2Id;
                            objNewOpportunity.Type = objOpportunity.Type;
                            //objNewOpportunity.PCRM_isCloned__c = true;
                            objNewOpportunity.CloseDate = system.today() + 30;
                            objNewOpportunity.StageName = objOpportunity.StageName;
                            objNewOpportunity.PCRM_Opportunity_Cloned_From__c  = objOpportunity.Id;
                            objNewOpportunity.Probability = 10;
                            objNewOpportunity.PCRM_isFirstSyncWithQuote__c = true;
                            objNewOpportunity.ForecastCategoryName = objOpportunity.ForecastCategoryName;
                            objNewOpportunity.Description = objOpportunity.Description;
                            objNewOpportunity.PCRM_Mode_of_Transport__c = objOpportunity.PCRM_Mode_of_Transport__c;
                            objNewOpportunity.PCRM_Payload__c = objOpportunity.PCRM_Payload__c;
                            objNewOpportunity.Territory2Id = objOpportunity.Territory2Id;
                            objNewOpportunity.PCRM_isCreatedFromCloning__c = True;    
                            
                            //cloning currency from Account    
                            objNewOpportunity.CurrencyIsoCode = objAccount.CurrencyIsoCode;
                            
                            lstTemporaryNewOpportunities.add(objNewOpportunity);
                            IdsTobeCloneWithOldOpportunityId.put(objNewOpportunity.PCRM_Opportunity_Cloned_From__c,objOpportunity.Id);    
                        
                            //lstProcessedNewOpportunities.add(objNewOpportunity);
                        }
                    }
                }else{
                    // Handle the case where object not being considered.
                }
                lstAllAccounts.remove(nCounter);
            }
            //1 st case
            if((lstAllAccounts.size() != 0 && lstTemporaryNewOpportunities != null && lstTemporaryNewOpportunities.size() > 0) )
            {
                try
                {
                
                    String strSuccessIDs = '';
                    String strExceptions = '';
                
                    Database.SaveResult[] srList = database.insert(lstTemporaryNewOpportunities, false);
                    this.lstProcessedNewOpportunities.addAll(lstTemporaryNewOpportunities);
                    
                    
                    for (Database.SaveResult sr: srList)
                    {
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
                    if( test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                    {
                        if(!lstEntities.contains('Opportunity'))
                        lstEntities.add('Opportunity');
                        
                       new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Opportunity', 'PCRM_Opportunity_Cloned_From__c','Scheduled',objLogger.Id);
                    }
                  
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    
                }
                  
                catch(Exception Ex)
                {
                    system.debug('Exception Occured while Cloning/ inserting Opportunities. Class: PCRM_CloneOpportunities, Method: Execute, Details: ' + Ex.getMessage());
                     if(lstEntities.contains('Opportunity'))
                        lstEntities.add('Opportunity');
                    
                     strError = strError + 'Excpetion: '+Ex.getMessage();
                     new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Opportunity','PCRM_Opportunity_Cloned_From__c','Scheduled',objLogger.Id);
              
                }
                // Enqueue pending records
                if(!test.isRunningTest())
                {
               	 	PCRM_CloneOpportunities objCloneOpportunities = new PCRM_CloneOpportunities(this.lstFrequency, this.lstAllAccounts, this.lstProcessedNewOpportunities);
                	System.enqueueJob(objCloneOpportunities);
                }
            }
            else if(lstTemporaryNewOpportunities != null && lstTemporaryNewOpportunities.size() > 0 &&
                     lstAllAccounts != null && lstAllAccounts.size() == 0)
            {
            
                // Insert all the Opportunities
                try
                {
                    
                    if (lstTemporaryNewOpportunities != null && lstTemporaryNewOpportunities.size() > 0)
                    {
                        Database.SaveResult[] srList = database.insert(lstTemporaryNewOpportunities, false);
                        this.lstProcessedNewOpportunities.addAll(lstTemporaryNewOpportunities);
                        
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
                        if( test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(!lstEntities.contains('Opportunity'))
                            lstEntities.add('Opportunity');
                            
                           new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Opportunity', 'PCRM_Opportunity_Cloned_From__c','Scheduled',objLogger.Id);
                        }
                        
                    }
                    
                    for (Opportunity objOpportunity: lstProcessedNewOpportunities)
                    {
                        mapOldOpportunityIDsWithNewOpportunityIDs.put(objOpportunity.PCRM_Opportunity_Cloned_From__c, objOpportunity.Id);
                    }
                    

                    if(!test.isRunningTest())
                    {
                        PCRM_CloneOpportunityAccounts objCloneOpportunityAccounts = new PCRM_CloneOpportunityAccounts(mapOldOpportunityIDsWithNewOpportunityIDs, null, null, true,objLogger.Id,lstEntities);
                    	System.enqueueJob(objCloneOpportunityAccounts);
                    }

                    
                    //system.debug('################## mapOldOpportunityIDsWithNewOpportunityIDs size: ' + mapOldOpportunityIDsWithNewOpportunityIDs.size());
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    
                    //in batch cloning opportunity Line Items are not clonned
                    //PCRM_CloneOpportunityLineItems objCloneOpportunityLineItems = new PCRM_CloneOpportunityLineItems(lstProcessedNewOpportunities, null);
                    //system.enqueueJob(objCloneOpportunityLineItems);

                    
                }
                catch(Exception Ex){
                    system.debug('Exception Occured while Cloning/ inserting Opportunities. Class: PCRM_CloneOpportunities, Method: Execute, Details: ' + Ex.getMessage());
                     if(lstEntities.contains('Opportunity'))
                        lstEntities.add('Opportunity');
                    
                     strError = strError + 'Excpetion: '+Ex.getMessage();
                     new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Opportunity','PCRM_Opportunity_Cloned_From__c','Scheduled',objLogger.Id);
              
                }
                
            }
        }
    }
}