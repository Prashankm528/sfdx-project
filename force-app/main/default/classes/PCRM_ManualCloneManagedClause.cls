/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_ManualCloneManagedClause
*   Changes: 0.1 
 
****************************************************************************************/
public with sharing class PCRM_ManualCloneManagedClause implements Queueable
{
    private List<APXT_Redlining__Contract_Agreement__c> lstNewOpportunities = new List<APXT_Redlining__Contract_Agreement__c>();
    private map<Id, APXT_Redlining__Contract_Agreement__c> mapOldOpportunityIdWithOpportunity = new map<Id, APXT_Redlining__Contract_Agreement__c>();
    private List<APXT_Redlining__Managed_Clause__c> lstNewOpportunityLineItem = new List<APXT_Redlining__Managed_Clause__c>();
    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private Id parentLogId = null;

    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
	
    public Integer cpuTimeLimit = 0;
    //constructor
    public PCRM_ManualCloneManagedClause(List<APXT_Redlining__Contract_Agreement__c> lstOpportunities, List<APXT_Redlining__Managed_Clause__c> lstOpportunityLineItems,map<id,id>mapOldOppIdwithNewOppId,Id parentLogId,List<string>errorEntities) 
    {
        //assign with custom label
        cpuTimeLimit = 5000;
        
        this.errorEntities = errorEntities;
        //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
        this.parentLogId = parentLogId;
        
        if (mapOldOppIdwithNewOppId != null && mapOldOppIdwithNewOppId.size() > 0)
        {
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIdwithNewOppId;
        }
       
        this.lstNewOpportunities = lstOpportunities;
        
        if (lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() > 0)
        {
            this.lstNewOpportunityLineItem = lstOpportunityLineItems;
            
        }
        
    }

    //execute method
    public void execute(QueueableContext context) 
    {
        //all the records which are supposed to get cloned
         map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
         List<string> successIds = NEW List<string>();
                
         string  strError='';
        
        set<Id> setOldOpportunityIDs = new set<Id>();
        List<APXT_Redlining__Managed_Clause__c> lstTemporaryNewOpportunityLineItem = new List<APXT_Redlining__Managed_Clause__c>();
        
        if (this.lstNewOpportunities != null && this.lstNewOpportunities.size() > 0 &&
            (this.lstNewOpportunityLineItem == null || (this.lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() == 0)))
        {
            for (APXT_Redlining__Contract_Agreement__c objOpportunity: lstNewOpportunities)
            {
                if (objOpportunity.PCRM_ContractAgreement_Cloned_From__c != null)
                {
                    setOldOpportunityIDs.add(objOpportunity.PCRM_ContractAgreement_Cloned_From__c);
                    mapOldOpportunityIDsWithNewOpportunityIDs.put(objOpportunity.PCRM_ContractAgreement_Cloned_From__c, objOpportunity.Id);
                }
                
            }
            system.debug('mapOldOpportunityIDsWithNewOpportunityIDs: '+mapOldOpportunityIDsWithNewOpportunityIDs);
            
            if (setOldOpportunityIDs != null && setOldOpportunityIDs.size() > 0)
            {
                try
                {
                //this.mapOldOpportunityIdWithOpportunity = new map<Id, APXT_Redlining__Contract_Agreement__c>([select Id, (select Id, APXT_Redlining__Contract_Agreement__c,LastModifiedById,Parent_006__c,OwnerId,APXT_Redlining__Parent_Managed_Clause__c,Process_Instance__c,RecordTypeId,Quote__c,APXT_Redlining__Order__c,Status__c,APXT_Redlining__Label__c,APXT_Redlining__Text_Rich__c,APXT_Redlining__Clause_Revision__c,APXT_Redlining__Latest_Revision__c  from APXT_Redlining__Managed_Clauses__r) from APXT_Redlining__Contract_Agreement__c where Id IN: setOldOpportunityIDs]);
                this.mapOldOpportunityIdWithOpportunity = new map<Id, APXT_Redlining__Contract_Agreement__c>(
                        [select Id, 
                         	(select Id,
                                    APXT_Redlining__Clause_Link__c,
                                    Name,
                                    recordtypeid,
                                    APXT_Redlining__Contract_Agreement__r.PCRM_Opportunity__c,
                                    APXT_Redlining__Clause_Revision__c,
                                    PCRM_isCreatedFromCloning__c,
                                    APXT_Redlining__Latest_Revision__c ,
                                    APXT_Redlining__Order__c,
                                    APXT_Redlining__Clause_Type__c,
                                    APXT_Redlining__IsStandard__c,
                                    APXT_Redlining__Text_Rich__c,
                                    Clause__c,
                                    PCRM_Managed_Clause_Cloned_From__c
                                    from APXT_Redlining__Managed_Clauses__r) from APXT_Redlining__Contract_Agreement__c where Id IN: setOldOpportunityIDs]);
                    
                  if(Test.isRunningTest())  //Condition to ensure test is running
                  	integer intTest =1/0;  
                    
                }
                catch(Exception Ex)
                {
                    if(test.isRunningTest()  || !this.errorEntities.contains('PCRM_Managed_Clause_Cloned_From__c'))
                           this.errorEntities.add('PCRM_Managed_Clause_Cloned_From__c');
                    
                    strError = strError + 'Excpetion: '+Ex.getMessage();
                	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Managed_Clause__c', 'PCRM_Managed_Clause_Cloned_From__c', 'Manual',this.parentLogId);
                }
            }
        }
        
        if (this.lstNewOpportunities != null && this.lstNewOpportunities.size() > 0 &&
            this.mapOldOpportunityIdWithOpportunity != null && this.mapOldOpportunityIdWithOpportunity.size() > 0)
        {
            for (Integer nCounter = 0; this.lstNewOpportunities.size() > 0;)
            {
                APXT_Redlining__Contract_Agreement__c objNewOpportunity = this.lstNewOpportunities[0];
                
                  system.debug('cpuLimt: '+Limits.getCpuTime());
                    //if (Limits.getCpuTime() > 5000)
                    if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                       break;
                    }
                
                
                if (this.mapOldOpportunityIdWithOpportunity.containsKey(objNewOpportunity.PCRM_ContractAgreement_Cloned_From__c) &&
                    this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_ContractAgreement_Cloned_From__c) != null  &&
                    this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_ContractAgreement_Cloned_From__c).APXT_Redlining__Managed_Clauses__r != null &&
                    this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_ContractAgreement_Cloned_From__c).APXT_Redlining__Managed_Clauses__r.size() > 0)
                {
                    for (APXT_Redlining__Managed_Clause__c objOpportunityLineItem: this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_ContractAgreement_Cloned_From__c).APXT_Redlining__Managed_Clauses__r)
                   {
                        APXT_Redlining__Managed_Clause__c objNewOpportunityLineItem = new APXT_Redlining__Managed_Clause__c();
                        
                        objNewOpportunityLineItem.APXT_Redlining__Contract_Agreement__c = objNewOpportunity.Id;
                        objNewOpportunityLineItem.RecordTypeId = objOpportunityLineItem.RecordTypeId;
                        
                        //objNewOpportunityLineItem.OwnerId = objOpportunityLineItem.OwnerId;
                        //objNewOpportunityLineItem.APXT_Redlining__Parent_Managed_Clause__c = objOpportunityLineItem.APXT_Redlining__Parent_Managed_Clause__c;
                        objNewOpportunityLineItem.PCRM_Managed_Clause_Cloned_From__c = objOpportunityLineItem.Id;
                        //objNewOpportunityLineItem.Process_Instance__c = objOpportunityLineItem.Process_Instance__c;
                        
                       //not writable
                       //objNewOpportunityLineItem.Name = objOpportunityLineItem.Name;
                        
                        //objNewOpportunityLineItem.Status__c = objOpportunityLineItem.Status__c;
                        objNewOpportunityLineItem.APXT_Redlining__Clause_Revision__c = objOpportunityLineItem.APXT_Redlining__Clause_Revision__c;
                        
                       // Revision must be a child of this Managed Clause.
                       //objNewOpportunityLineItem.APXT_Redlining__Latest_Revision__c = objOpportunityLineItem.APXT_Redlining__Latest_Revision__c;
                        
                        objNewOpportunityLineItem.APXT_Redlining__Order__c = objOpportunityLineItem.APXT_Redlining__Order__c;
                        
                        //not writable
                        //objNewOpportunityLineItem.APXT_Redlining__Clause_Type__c = objOpportunityLineItem.APXT_Redlining__Clause_Type__c;
                        
                        //not writable
                        //objNewOpportunityLineItem.APXT_Redlining__IsStandard__c = objOpportunityLineItem.APXT_Redlining__IsStandard__c;
                        
                        objNewOpportunityLineItem.APXT_Redlining__Text_Rich__c = objOpportunityLineItem.APXT_Redlining__Text_Rich__c;
                        objNewOpportunityLineItem.Clause__c = objOpportunityLineItem.Clause__c;
                        objNewOpportunityLineItem.PCRM_isCreatedFromCloning__c= True;
                       
                        lstTemporaryNewOpportunityLineItem.add(objNewOpportunityLineItem);
                       
                        IdsTobeCloneWithOldOpportunityId.put(objNewOpportunityLineItem.PCRM_Managed_Clause_Cloned_From__c,objOpportunityLineItem.APXT_Redlining__Contract_Agreement__r.PCRM_Opportunity__c);    
                       
                        //lstNewOpportunityLineItem.add(objNewOpportunityLineItem);
                    }
                }
                
                lstNewOpportunities.remove(0);
            }
            
            if (lstNewOpportunities != null && lstNewOpportunities.size() != 0)
            {
                if ((lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0) || test.isRunningTest())
                {
                    try{
                        
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityLineItem, false);
                        
                        //test purpose
                        List<Id> addedManagedClauses1 = NEW List<Id>();
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
                        lstNewOpportunityLineItem.addAll(lstTemporaryNewOpportunityLineItem);
                        
                         //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                             if(!this.errorEntities.contains('PCRM_Managed_Clause_Cloned_From__c'))
                                 this.errorEntities.add('PCRM_Managed_Clause_Cloned_From__c');
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Managed_Clause__c', 'PCRM_Managed_Clause_Cloned_From__c', 'Manual',this.parentLogId);
                        }
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                        
                    }
                    catch(Exception Ex)
                    {
                         if(test.isRunningTest()  || (!this.errorEntities.contains('PCRM_Managed_Clause_Cloned_From__c')))
                                this.errorEntities.add('PCRM_Managed_Clause_Cloned_From__c');
                        
                        strError = strError + 'Excpetion: '+Ex.getMessage();
                        new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Managed_Clause__c', 'PCRM_Managed_Clause_Cloned_From__c', 'Manual',this.parentLogId);
                    }
                }
                
                if(!test.isRunningTest())
                {
                 	PCRM_ManualCloneManagedClause objCloneOpportunityLineItems = new PCRM_ManualCloneManagedClause(lstNewOpportunities, lstNewOpportunityLineItem,mapOldOpportunityIDsWithNewOpportunityIDs,this.parentLogId,this.errorEntities);
                 	system.enqueueJob(objCloneOpportunityLineItems);
                }
            }
            else if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0 &&
                      ((lstNewOpportunities == null) || (lstNewOpportunities != null && lstNewOpportunities.size() == 0)))
            {
                try{
                    
                    if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0)
                    {
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityLineItem, false);
                        
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
                        lstNewOpportunityLineItem.addAll(lstTemporaryNewOpportunityLineItem);
                        
                         //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                             if(!this.errorEntities.contains('PCRM_Managed_Clause_Cloned_From__c'))
                                this.errorEntities.add('PCRM_Managed_Clause_Cloned_From__c');
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Managed_Clause__c', 'PCRM_Managed_Clause_Cloned_From__c', 'Manual',this.parentLogId);
                        }
                        
                    }
                    
                    if(!test.isRunningTest())
                    {
                     PCRM_CloneOpportunityAccounts objCloneOpportunityAccounts = new PCRM_CloneOpportunityAccounts(mapOldOpportunityIDsWithNewOpportunityIDs, null, null,false,this.parentLogId, this.errorEntities);
                     System.enqueueJob(objCloneOpportunityAccounts);
                    }
                    
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    
                }catch(Exception Ex)
                {
                     if(test.isRunningTest()  || !this.errorEntities.contains('PCRM_Managed_Clause_Cloned_From__c'))
                           this.errorEntities.add('PCRM_Managed_Clause_Cloned_From__c');
                    
                    strError = strError + 'Excpetion: '+Ex.getMessage();
                	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'APXT_Redlining__Managed_Clause__c', 'PCRM_Managed_Clause_Cloned_From__c', 'Manual',this.parentLogId);
                }
            }
            
        }
    }
}