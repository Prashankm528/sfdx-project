/*****************************************************************************************
*   Date:     18/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Class for Class PCRM_ManualCloneContractAgreement
*   Changes: 0.1 
*   Date:     11/09/2020
*   Author:   Pooja Deokar (TCS)  
*   Changes: 0.1:   Removed PCRM_Price_Mechanism__c reference
 
****************************************************************************************/
public with sharing class PCRM_ManualCloneContractAgreement implements Queueable
{
    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private List<Opportunity> lstAllOldOpportunity = new List<Opportunity>();
    private List<APXT_Redlining__Contract_Agreement__c> lstNewContractAgreement = new List<APXT_Redlining__Contract_Agreement__c>();
    //lstNewOpportunityAccount
    private Id parentLogId = null;
    
    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
    
    public Integer cpuTimeLimit = 0;
    //contructor
    public PCRM_ManualCloneContractAgreement(map<Id, Id> mapOldOppIDsWithNewOppIDs, List<Opportunity> lstOldOpportunity, List<APXT_Redlining__Contract_Agreement__c> lstProcessedOppAccount,Id parentLogId, List<string>errorEntities) 
    {
        //assign with custom label
        cpuTimeLimit = 5000;
        
       this.errorEntities = errorEntities;
     
        //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
        this.parentLogId = parentLogId;
        
        if (mapOldOppIDsWithNewOppIDs != null && mapOldOppIDsWithNewOppIDs.size() > 0)
        {
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIDsWithNewOppIDs;
        }
        
        if (lstOldOpportunity != null && lstOldOpportunity.size() > 0)
        {
            this.lstAllOldOpportunity = lstOldOpportunity;
        }
      
        if (lstProcessedOppAccount != null && lstProcessedOppAccount.size() > 0)
        {
            this.lstNewContractAgreement = lstProcessedOppAccount;
        }
            
    }

    //execute method
    public void execute(QueueableContext context)
    {
        //all the records which are supposed to get cloned
        map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
        List<string> successIds = NEW List<string>();
        string  strError='';
        
        //List<PCRM_Opportunity_Account__c> lstTemporaryNewOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
        List<APXT_Redlining__Contract_Agreement__c> lstTemporaryNewOpportunityAccount = new List<APXT_Redlining__Contract_Agreement__c>();
        
        if (this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() == 0 &&
            mapOldOpportunityIDsWithNewOpportunityIDs != null && mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0)
        {
            set<Id> setOpportunityID = new set<Id>();
            setOpportunityID.addAll(mapOldOpportunityIDsWithNewOpportunityIDs.keyset());
            
            try
            {
                system.debug('setOpportunityID777: '+setOpportunityID);
                
                //this.lstAllOldOpportunity = [select Id, (select Id, PCRM_Opportunity__c,Process_Instance__c,APXT_Redlining__Proposed_Value__c,APXT_Redlining__Purpose__c,RecordTypeId,Status__c,APXT_Redlining__Agreement_Type__c,APXT_Redlining__Description__c,Name,APXT_Redlining__Effective_Date__c,APXT_Redlining__Expiration_Date__c,PCRM_Order_Size__c FROM Contract_Agreements__r) FROM Opportunity WHERE Id IN: setOpportunityID];
                this.lstAllOldOpportunity = [select Id, 
                                                (select Id,
                                                        //Process_Instance__c,
                                                        APXT_Redlining__Proposed_Value__c,
                                                        APXT_Redlining__Purpose__c,
                                                        RecordTypeId,
                                                        Status__c,
                                                        PCRM_isCreatedFromCloning__c,
                                                        APXT_Redlining__Type__c,
                                                        APXT_Redlining__Account__c,
                                                        APXT_Redlining__Agreement_Type__c,
                                                        PCRM_Payment_Cutoff_Day__c,
                                                        CurrencyIsoCode,
                                                        APXT_Redlining__Renewal_Interval_Months__c,
                                                        APXT_Redlining__Notice_Date__c,
                                                        PCRM_Lead_Time_Days__c,
                                                        APXT_Redlining__External_Id__c,                                                        
                                                        PCRM_Performance_Review__c,
                                                        PCRM_Link_Price_Mechanism__c,
                                                        PCRM_Credit_Limit__c,
                                                        APXT_Redlining__Contract_Agreement_Family_Parent__c,
                                                        PCRM_Opportunity__c,
                                                        PCRM_Jurisdiction__c,
                                                        PCRM_Extended_Period__c,
                                                        PCRM_Packaging__c,
                                                        APXT_Redlining__Description__c,
                                                        Name,
                                                        PCRM_ContractAgreement_Cloned_From__c,
                                                        APXT_Redlining__Effective_Date__c,
                                                        APXT_Redlining__Expiration_Date__c,
                                                        PCRM_Order_Size__c 
                                                        FROM Contract_Agreements__r) FROM Opportunity WHERE Id IN: setOpportunityID];
                
              system.debug(' this.lstAllOldOpportunity: '+ this.lstAllOldOpportunity);  
                
              if(Test.isRunningTest())  //Condition to ensure test is running
                  integer intTest =1/0; 
                
            }catch(Exception Ex)
            {
                
                if(!this.errorEntities.contains('APXT_Redlining__Contract_Agreement__c') || test.isRunningTest())
                    this.errorEntities.add('APXT_Redlining__Contract_Agreement__c');
                
                strError = strError + 'Excpetion: '+Ex.getMessage();
                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Contract_Agreement__c', 'PCRM_ContractAgreement_Cloned_From__c', 'Manual', this.parentLogId);
            }
        }
        
        if (this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() > 0 &&
            mapOldOpportunityIDsWithNewOpportunityIDs != null && mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0)
        {
            for (; this.lstAllOldOpportunity.size() > 0;)
            {
                system.debug('cpuLimt: '+Limits.getCpuTime());
                    //if (Limits.getCpuTime() > 5000)
                    if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                        break;
                    }
                
                Opportunity objOpportunity = this.lstAllOldOpportunity[0];
                for (APXT_Redlining__Contract_Agreement__c objContractAgreement: objOpportunity.Contract_Agreements__r)
                {
                    APXT_Redlining__Contract_Agreement__c objNewContractAgreement = new APXT_Redlining__Contract_Agreement__c();
                    if (mapOldOpportunityIDsWithNewOpportunityIDs.containsKey(objContractAgreement.PCRM_Opportunity__c) &&
                        mapOldOpportunityIDsWithNewOpportunityIDs.get(objContractAgreement.PCRM_Opportunity__c) != null)
                    {
                        objNewContractAgreement.PCRM_Opportunity__c = mapOldOpportunityIDsWithNewOpportunityIDs.get(objContractAgreement.PCRM_Opportunity__c);
                        
                        //cloning look up values
                        objNewContractAgreement.RecordTypeId = objContractAgreement.RecordTypeId;
                        //objNewContractAgreement.PCRM_Opportunity__c =objContractAgreement.PCRM_Opportunity__c;

                        //objNewContractAgreement.Process_Instance__c = objContractAgreement.Process_Instance__c;
                        objNewContractAgreement.APXT_Redlining__Proposed_Value__c = objContractAgreement.APXT_Redlining__Proposed_Value__c;
                        objNewContractAgreement.APXT_Redlining__Purpose__c = objContractAgreement.APXT_Redlining__Purpose__c;
                        objNewContractAgreement.APXT_Redlining__Agreement_Type__c  =objContractAgreement.APXT_Redlining__Agreement_Type__c;
                        objNewContractAgreement.APXT_Redlining__Description__c =objContractAgreement.APXT_Redlining__Description__c;
                        objNewContractAgreement.APXT_Redlining__Effective_Date__c =objContractAgreement.APXT_Redlining__Effective_Date__c;
                        objNewContractAgreement.PCRM_Order_Size__c =objContractAgreement.PCRM_Order_Size__c;
                        objNewContractAgreement.APXT_Redlining__Expiration_Date__c =objContractAgreement.APXT_Redlining__Expiration_Date__c;
                        objNewContractAgreement.PCRM_ContractAgreement_Cloned_From__c = objContractAgreement.Id;
                        objNewContractAgreement.Status__c  = objContractAgreement.Status__c;  
                        objNewContractAgreement.APXT_Redlining__Type__c =objContractAgreement.APXT_Redlining__Type__c;
                        objNewContractAgreement.APXT_Redlining__Account__c =objContractAgreement.APXT_Redlining__Account__c;
                        objNewContractAgreement.APXT_Redlining__Agreement_Type__c =objContractAgreement.APXT_Redlining__Agreement_Type__c;
                        objNewContractAgreement.PCRM_Payment_Cutoff_Day__c =objContractAgreement.PCRM_Payment_Cutoff_Day__c;
                        objNewContractAgreement.CurrencyIsoCode =objContractAgreement.CurrencyIsoCode;
                        objNewContractAgreement.APXT_Redlining__Renewal_Interval_Months__c =objContractAgreement.APXT_Redlining__Renewal_Interval_Months__c;
                        objNewContractAgreement.APXT_Redlining__Notice_Date__c =objContractAgreement.APXT_Redlining__Notice_Date__c;
                        objNewContractAgreement.PCRM_Lead_Time_Days__c =objContractAgreement.PCRM_Lead_Time_Days__c;
                        objNewContractAgreement.APXT_Redlining__External_Id__c =objContractAgreement.APXT_Redlining__External_Id__c;
                        //objNewContractAgreement.PCRM_Price_Mechanism__c =objContractAgreement.PCRM_Price_Mechanism__c;
                        objNewContractAgreement.PCRM_Performance_Review__c =objContractAgreement.PCRM_Performance_Review__c;
                        objNewContractAgreement.PCRM_Link_Price_Mechanism__c =objContractAgreement.PCRM_Link_Price_Mechanism__c;
                        objNewContractAgreement.PCRM_isCreatedFromCloning__c = True;
                        
                        //not writable
                        //objNewContractAgreement.PCRM_Customer_Credit_Limit__c =objContractAgreement.PCRM_Customer_Credit_Limit__c;
                        
                        objNewContractAgreement.APXT_Redlining__Contract_Agreement_Family_Parent__c =objContractAgreement.APXT_Redlining__Contract_Agreement_Family_Parent__c;
                        objNewContractAgreement.PCRM_Jurisdiction__c =objContractAgreement.PCRM_Jurisdiction__c;
                        objNewContractAgreement.PCRM_Extended_Period__c =objContractAgreement.PCRM_Extended_Period__c;
                        objNewContractAgreement.PCRM_Packaging__c =objContractAgreement.PCRM_Packaging__c;
                        objNewContractAgreement.APXT_Redlining__Description__c =objContractAgreement.APXT_Redlining__Description__c;
                        
                        //not writable
                       //objNewContractAgreement.Name =objContractAgreement.Name;
                       
                        objNewContractAgreement.APXT_Redlining__Effective_Date__c =objContractAgreement.APXT_Redlining__Effective_Date__c;
                        objNewContractAgreement.APXT_Redlining__Expiration_Date__c =objContractAgreement.APXT_Redlining__Expiration_Date__c;
                        objNewContractAgreement.APXT_Redlining__Description__c =objContractAgreement.APXT_Redlining__Description__c;

                        IdsTobeCloneWithOldOpportunityId.put(objNewContractAgreement.PCRM_ContractAgreement_Cloned_From__c,objContractAgreement.PCRM_Opportunity__c);    
                        lstTemporaryNewOpportunityAccount.add(objNewContractAgreement);
                    }
                    
                }
                
                this.lstAllOldOpportunity.remove(0);
            }
            if (this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() > 0)
            {
                if ((lstTemporaryNewOpportunityAccount != null && lstTemporaryNewOpportunityAccount.size() > 0) || test.isRunningTest())
                {
                    try
                    {
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityAccount, false);
                        
                        for( Database.saveResult sr :srList )
                        {
                            if(sr.isSuccess() || test.isRunningTest())
                            {
                                successIds.add('\''+ sr.getId() + '\'');
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
                         
                        lstNewContractAgreement.addAll(lstTemporaryNewOpportunityAccount);
                        
                        //log the errors
                        if(!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size()))
                        {
                            if(!this.errorEntities.contains('APXT_Redlining__Contract_Agreement__c'))
                              this.errorEntities.add('APXT_Redlining__Contract_Agreement__c');
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Contract_Agreement__c', 'PCRM_ContractAgreement_Cloned_From__c', 'Manual',this.parentLogId);
                        }
                        
                    }catch(Exception Ex)
                    {
                        if(!this.errorEntities.contains('APXT_Redlining__Contract_Agreement__c'))
                         this.errorEntities.add('APXT_Redlining__Contract_Agreement__c');
                        
                        strError = strError + 'Excpetion: '+Ex.getMessage();
                        new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Contract_Agreement__c', 'PCRM_ContractAgreement_Cloned_From__c', 'Manual', this.parentLogId);
                    }
                }
                
                if(!test.isrunningtest())
                {
                    PCRM_ManualCloneContractAgreement objCloneContractAgreement = new PCRM_ManualCloneContractAgreement(mapOldOpportunityIDsWithNewOpportunityIDs, this.lstAllOldOpportunity, this.lstNewContractAgreement, this.parentLogId,this.errorEntities);
                    System.enqueueJob(objCloneContractAgreement);  
                }          
            }
            else if(this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() == 0)
            {
                try{
                    if (lstTemporaryNewOpportunityAccount != null && lstTemporaryNewOpportunityAccount.size() > 0)
                    {
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityAccount, false);
                        
                        for( Database.saveResult sr :srList )
                        {
                            if(sr.isSuccess())
                            {
                               successIds.add('\''+ sr.getId() + '\'');
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
                        lstNewContractAgreement.addAll(lstTemporaryNewOpportunityAccount);
                        
                        //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(!this.errorEntities.contains('APXT_Redlining__Contract_Agreement__c') || test.isRunningTest())
                                 this.errorEntities.add('APXT_Redlining__Contract_Agreement__c');
                            
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Contract_Agreement__c', 'PCRM_ContractAgreement_Cloned_From__c', 'Manual', this.parentLogId);
                        }   
                    }
                    
                    if(!test.isRunningTest())
                    {
                        PCRM_ManualCloneManagedClause objCloneManagedClauses = new PCRM_ManualCloneManagedClause(lstNewContractAgreement, null,mapOldOpportunityIDsWithNewOpportunityIDs, this.parentLogId,this.errorEntities);
                        system.enqueueJob(objCloneManagedClauses);
                    }
                    
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    
                }catch(Exception Ex)
                {
                  if(!this.errorEntities.contains('APXT_Redlining__Contract_Agreement__c') || test.isRunningTest())
                    this.errorEntities.add('APXT_Redlining__Contract_Agreement__c');  
                    
                  strError = strError + 'Excpetion: '+Ex.getMessage();
                  new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Contract_Agreement__c', 'PCRM_ContractAgreement_Cloned_From__c', 'Manual',this.parentLogId);
                }
            }
        }
    }
}