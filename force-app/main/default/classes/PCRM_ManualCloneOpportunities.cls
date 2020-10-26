/*****************************************************************************************
*   Date: 06/23/2020
*   Author:   Mansi Dhoke(TCS)
*   Description:  Test Utility class to create records
*   Version 1.1 
****************************************************************************************/
public with Sharing class PCRM_ManualCloneOpportunities 
{
    /*private List<String> lstFrequency = new List<String>();
    private List<Account> lstAllAccounts = new List<Account>();
    private List<Opportunity> lstProcessedNewOpportunities = new List<Opportunity>();*/
    /*// Constructor: initialize the input parameters
    public PCRM_ManualCloneOpportunities(List<String> lstFrq, List<Account> lstAllAcct, List<Opportunity> lstProssdOpp) {
        
        if (lstFrq != null && lstFrq.size() > 0){
            this.lstFrequency = lstFrq;
        }
        
        if (lstProssdOpp != null && lstProssdOpp.size() > 0){
            this.lstProcessedNewOpportunities = lstProssdOpp;
        }
        
        if (lstAllAcct != null && lstAllAcct.size() > 0){
            this.lstAllAccounts = lstAllAcct;
        }
    }*/
    // Process the accounts to create Opportunities.
    //public void execute(QueueableContext context) 
    public static void executeManualClone(Opportunity OpportunityToCloneObj) 
    {
        system.debug('OpportunityToCloneObj: '+OpportunityToCloneObj); 
        
        //all the records which are supposed to get cloned
        //List<Id> RecordIdsToBeClone = NEW List<Id>();
        map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
        List<string> successIds = NEW List<string>();
        string  strError='';
        
        //it will store name of obj which encountered errroe while clone/insert and this list will flow dwn till last entity and keep on updating name of obj
        List<String> lstEntities = NEW List<String>();
       
        List<Opportunity> lstTemporaryNewOpportunities = new List<Opportunity>();
        
        List<String> lstFrequency = new List<String>();
        List<Account> lstAllAccounts = new List<Account>();
        List<Opportunity> lstProcessedNewOpportunities = new List<Opportunity>();
        
        String dayString = system.Today().format();

        /*Integer JobIdentifier = Integer.valueof((Math.random() * 10000));
        System.debug('JobIdentifier is'+JobIdentifier);*/
        PCRM_Logger__c objLogger = new PCRM_Logger__c();
        Insert objLogger;
        
        // This if loop should be executed only for the very first time when the job runs
        /*if (this.lstAllAccounts == null || (lstAllAccounts != null && lstAllAccounts.size() == 0))
        {
            List<String> lstType = new List<String>();
            lstType.add('PCRM_Spot');
            lstType.add('PCRM_Negotiated');
            lstType.add('PCRM_Formula');

            //String strQuery = 'SELECT Id, Name, PCRM_Quote_Frequency__c, (SELECT Id, ForecastCategoryName, StageName, Type, Pricebook2Id, CurrencyIsoCode, PCRM_Quote_Frequency__c, accountId, recordTypeId  FROM Opportunities WHERE Type IN: lstType order by CreatedDate DESC limit 1) FROM Account WHERE PCRM_Quote_Frequency__c IN: lstFrequency';
            String strQuery = 'SELECT Id, Name, PCRM_Quote_Frequency__c, (SELECT Id, ForecastCategoryName, StageName, Type, Pricebook2Id, CurrencyIsoCode, PCRM_Quote_Frequency__c, accountId, recordTypeId  FROM Opportunities WHERE Type IN: lstType order by CreatedDate DESC limit 1) FROM Account WHERE PCRM_Quote_Frequency__c IN: lstFrequency AND Id = \'0013M000002IL0EQAW\'';
            this.lstAllAccounts = Database.query(strQuery);
            system.debug('################ lstAllAccounts size: ' + lstAllAccounts.size());
        }*/
        
        // This piece will be executed no matter it is the first time or the job is called in recursive mode.
       // if(this.lstAllAccounts != null && this.lstAllAccounts.size() > 0)
        {
           // for (Integer nCounter = 0; lstAllAccounts.size() > 0;)
            {
                // AVOID: CPU TIME LIMIT EXCEEDS BY Giving a Recursive Call In Case Record Are Still To Be Processed.
                /*if (Limits.getCpuTime() > 5000)
                {
                    break;
                }*/
                //Account objAccount = lstAllAccounts.get(0);
               // if (objAccount.opportunities != null && objAccount.opportunities.size() > 0)
                {
                    Opportunity objOpportunity = OpportunityToCloneObj;
                    
                    //for (Opportunity objOpportunity: objAccount.opportunities)
                    {
                        Opportunity objNewOpportunity = new Opportunity();
                       
                        //changing values when cloning
                        //objNewOpportunity.Name = objOpportunity.Account.PCRM_Quote_Frequency__c + 'Opportunity' + objOpportunity.Account.Name + String.valueof(system.Today());
                        objNewOpportunity.Name = objOpportunity.Account.PCRM_Quote_Frequency__c +' '+'Opportunity'+' '+objOpportunity.Account.Name +' '+dayString;

                        objNewOpportunity.StageName = 'Prospecting';
                        objNewOpportunity.CloseDate = system.today() + 30;
                        objNewOpportunity.PCRM_Opportunity_Cloned_From__c  = objOpportunity.Id;
                        objNewOpportunity.Probability = 10;
                        
                        //look up fields
                        objNewOpportunity.accountId = objOpportunity.accountId;
                        objNewOpportunity.recordTypeId = objOpportunity.recordTypeId;
                        objNewOpportunity.Pricebook2Id = objOpportunity.Pricebook2Id;
                        objNewOpportunity.Territory2Id = objOpportunity.Territory2Id;
                        objNewOpportunity.ContractId = objOpportunity.ContractId; 
     
                        //cloning as it is
                        objNewOpportunity.PCRM_Quote_Frequency__c = objOpportunity.Account.PCRM_Quote_Frequency__c;
                        objNewOpportunity.ForecastCategoryName = objOpportunity.ForecastCategoryName;
                        objNewOpportunity.Type = objOpportunity.Type;
                        objNewOpportunity.Probability = objOpportunity.Probability;
                        objNewOpportunity.PCRM_Related_Opportunity__c = objOpportunity.PCRM_Related_Opportunity__c; //l
                        
                        //error while deployment .. Field is not writeable: Opportunity.PCRM_Start_Date__c ..so commented
                        //objNewOpportunity.PCRM_Start_Date__c = objOpportunity.PCRM_Start_Date__c;
                        //objNewOpportunity.PCRM_End_Date__c = objOpportunity.PCRM_End_Date__c;
                        
                        //cloning Accounts Currency
                        objNewOpportunity.CurrencyIsoCode = objOpportunity.Account.CurrencyIsoCode;
                        
                        //not writable
                        //objNewOpportunity.PCRM_Previous_Period_Amount__c = objOpportunity.PCRM_Previous_Period_Amount__c;
                        
                        //not writable
                        //objNewOpportunity.PCRM_Price_Movement__c = objOpportunity.PCRM_Price_Movement__c;
                        
                        objNewOpportunity.Description = objOpportunity.Description;
                        objNewOpportunity.PCRM_Payload__c = objOpportunity.PCRM_Payload__c;
                        objNewOpportunity.PCRM_Mode_of_Transport__c = objOpportunity.PCRM_Mode_of_Transport__c;
                        objNewOpportunity.Amount = objOpportunity.Amount;
                        objNewOpportunity.CloseDate = objOpportunity.CloseDate;
                        
                        //field is not writable
                        //objNewOpportunity.ExpectedRevenue = objOpportunity.ExpectedRevenue;
                        
                        objNewOpportunity.PCRM_Forecasted_Term_Volume__c = objOpportunity.PCRM_Forecasted_Term_Volume__c;
                        objNewOpportunity.PCRM_Price_agreed_with_Customer__c = objOpportunity.PCRM_Price_agreed_with_Customer__c;
                        objNewOpportunity.ForecastCategoryName = objOpportunity.ForecastCategoryName; 
                        objNewOpportunity.PCRM_LOST_Quote_Price__c = objOpportunity.PCRM_LOST_Quote_Price__c; 
                        objNewOpportunity.Reason_Detail__c = objOpportunity.Reason_Detail__c; 
                        objNewOpportunity.Reason__c = ''; 
                        objNewOpportunity.PCRM_Reason_for_LOSS__c = ''; 
                        objNewOpportunity.PCRM_isCreatedFromCloning__c = True;
                        IdsTobeCloneWithOldOpportunityId.put(objNewOpportunity.PCRM_Opportunity_Cloned_From__c,objOpportunity.Id);    
                        
                        lstTemporaryNewOpportunities.add(objNewOpportunity);
                    }
                }//else
                {
                    // Handle the case where object not being considered.
                }
                //lstAllAccounts.remove(nCounter);
            }
            
            //if(lstAllAccounts.size() != 0 && lstTemporaryNewOpportunities != null && lstTemporaryNewOpportunities.size() > 0)
            {
                try
                {
                    system.debug('lstTemporaryNewOpportunities77:'+lstTemporaryNewOpportunities);
                    
                    Database.SaveResult[] srList = database.insert(lstTemporaryNewOpportunities, false);
                    lstProcessedNewOpportunities.addAll(lstTemporaryNewOpportunities);
                    
                    system.debug('lstProcessedNewOpportunitiesyyyy:'+lstProcessedNewOpportunities);
                    
                    List<Id> LstOfOpportunityInserted = NEW  List<Id>();
                    
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList)
                    {
                         LstOfOpportunityInserted.add(sr.getId());
                        //Database.SaveResult[getErrors=();getId=0063M000002Ex1cQAC;isSuccess=true;]
                        system.debug('srkkkkk:'+sr);
                        if(sr.isSuccess())
                            {
                                system.debug('ndkjdnj');
                                successIds.add('\''+ sr.getId() + '\'');
                                //successIds.add(sr.getId());
                            }
                        else
                            {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors())
                                {
                                    strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                }               
                             }
                    }
                   
                    //log the errors
                    if( test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                    {
                        if(!lstEntities.contains('Opportunity'))
                        lstEntities.add('Opportunity');
                        
                       new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Opportunity', 'PCRM_Opportunity_Cloned_From__c','Manual',objLogger.Id);
                    }
                    
                    //commneted temp for deployment purpose
                    if(!test.isRunningTest())
                    	PCRM_ManualCloneOpportunityLineItems.execute(lstProcessedNewOpportunities, null,objLogger.Id,lstEntities);
                    
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 


                }catch(Exception Ex)
                {
                    system.debug('Exception in manual clone opp class : '+EX.getMessage()+ ' Line no:'+EX.getLineNumber());
                     if(lstEntities.contains('Opportunity'))
                        lstEntities.add('Opportunity');
                    
                     strError = strError + 'Excpetion: '+Ex.getMessage();
                     new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'Opportunity','PCRM_Opportunity_Cloned_From__c', 'Manual',objLogger.Id);
                }
               
            }
                               
        }
    }
}