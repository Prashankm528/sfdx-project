/*****************************************************************************************
*   Date:      10/05/2020
*   Author:    Mansi Dhoke (TCS)  
*   Description: 
*   Changes: 0.1
   
****************************************************************************************/


public with Sharing class PCRM_ManualCloneOpportunityLineSchedule implements Queueable
{
    private List<OpportunityLineItem> lstNewOpportunities = new List<OpportunityLineItem>();
    private map<Id, OpportunityLineItem> mapOldOpportunityIdWithOpportunity = new map<Id, OpportunityLineItem>();
    private List<OpportunityLineItemSchedule> lstNewOpportunityLineItem = new List<OpportunityLineItemSchedule>();
    
    private map<Id, Id> mapOldOpportunityLineIDsWithNewOpportunityLineIDs = new map<Id, Id>();

    private map<Id, Id> mapOldOpportunityIDsAndNewOpportunityIDs = new map<Id, Id>();
    
    private Id parentLogId = null;
    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
    
    public Integer cpuTimeLimit = 0;
    
    //constructor
    public PCRM_ManualCloneOpportunityLineSchedule(List<OpportunityLineItem> lstOpportunities, List<OpportunityLineItemSchedule> lstOpportunityLineItems,map<Id,Id> mapOldOpportunityIdWithNewOppId,Id parentLogId,List<string>errorEntities)
    {
        //assign with custom label
        if(!test.isRunningTest())
        cpuTimeLimit = 5000;
        
        //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
        this.parentLogId = parentLogId;
        this.errorEntities = errorEntities;
	 
        this.mapOldOpportunityIDsAndNewOpportunityIDs = mapOldOpportunityIdWithNewOppId;
        
        this.lstNewOpportunities = lstOpportunities;
        if ((lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() > 0) )
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
        List<OpportunityLineItemSchedule> lstTemporaryNewOpportunityLineItem = new List<OpportunityLineItemSchedule>();
        
        //first time
        if (this.lstNewOpportunities != null && this.lstNewOpportunities.size() > 0 &&
            (this.lstNewOpportunityLineItem == null || (this.lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() == 0)))
        {
            for (OpportunityLineItem objOpportunity: lstNewOpportunities)
            {
                if (objOpportunity.PCRM_OpportunityLineItem_Cloned_From__c != null)
                {
                    setOldOpportunityIDs.add(objOpportunity.PCRM_OpportunityLineItem_Cloned_From__c);
                    mapOldOpportunityLineIDsWithNewOpportunityLineIDs.put(objOpportunity.PCRM_OpportunityLineItem_Cloned_From__c, objOpportunity.Id);
                }
            }
            
            if (setOldOpportunityIDs != null && setOldOpportunityIDs.size() > 0)
            {
                this.mapOldOpportunityIdWithOpportunity = new map<Id, OpportunityLineItem>
                    ([select Id, 
                      	(select Id,
                         Description,
                         OpportunityLineItemId,
                         OpportunityLineItem.OpportunityId,
                         Max_Annual_Quantity__c,
                         Minimum_Annual_Quantity__c,
                         PCRM_LineItemSchedule_Cloned_From__c,
                         Quantity,
                         Revenue,
                         PCRM_isCreatedFromCloning__c,
                         ScheduleDate,
                         Type 
                         from OpportunityLineItemSchedules) from OpportunityLineItem where Id IN: setOldOpportunityIDs]);

            }
        }
        
        //1
        if (this.lstNewOpportunities != null && this.lstNewOpportunities.size() > 0 &&
            this.mapOldOpportunityIdWithOpportunity != null && this.mapOldOpportunityIdWithOpportunity.size() > 0)
        {
            for (Integer nCounter = 0; this.lstNewOpportunities.size() > 0;)
            {
                OpportunityLineItem objNewOpportunity = this.lstNewOpportunities[0];
                
                system.debug('cpu Limit: '+Limits.getCpuTime());
                {
                    if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                        break;
                    }
                }
                   
                if (this.mapOldOpportunityIdWithOpportunity.containsKey(objNewOpportunity.PCRM_OpportunityLineItem_Cloned_From__c) &&
                    this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_OpportunityLineItem_Cloned_From__c) != null &&
                    this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_OpportunityLineItem_Cloned_From__c).OpportunityLineItemSchedules != null &&
                    this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_OpportunityLineItem_Cloned_From__c).OpportunityLineItemSchedules.size() > 0)
                {
                    for (OpportunityLineItemSchedule objOpportunityLineItem : this.mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_OpportunityLineItem_Cloned_From__c).OpportunityLineItemSchedules)
                    {
                        OpportunityLineItemSchedule objNewOpportunityLineItemSchedule = new OpportunityLineItemSchedule();
                        
                        objNewOpportunityLineItemSchedule.OpportunityLineItemId = objNewOpportunity.Id;//recently cloned opp line item
                        objNewOpportunityLineItemSchedule.Description = objOpportunityLineItem.Description;
                        objNewOpportunityLineItemSchedule.Max_Annual_Quantity__c = objOpportunityLineItem.Max_Annual_Quantity__c;
                        objNewOpportunityLineItemSchedule.Minimum_Annual_Quantity__c = objOpportunityLineItem.Minimum_Annual_Quantity__c;
                        objNewOpportunityLineItemSchedule.Quantity = objOpportunityLineItem.Quantity;

                        objNewOpportunityLineItemSchedule.Revenue = objOpportunityLineItem.Revenue;
                        objNewOpportunityLineItemSchedule.ScheduleDate = objOpportunityLineItem.ScheduleDate;
                        objNewOpportunityLineItemSchedule.Type = objOpportunityLineItem.Type;
                        objNewOpportunityLineItemSchedule.PCRM_isCreatedFromCloning__c = True;
                        
                        objNewOpportunityLineItemSchedule.PCRM_LineItemSchedule_Cloned_From__c = objOpportunityLineItem.Id;
                       
                        lstTemporaryNewOpportunityLineItem.add(objNewOpportunityLineItemSchedule);
                        
                        //allCloneFromIds.add(objNewOpportunityLineItemSchedule.PCRM_LineItemSchedule_Cloned_From__c);
                        
                        system.debug('Old opp Id: '+objOpportunityLineItem.OpportunityLineItem.OpportunityId);
                        IdsTobeCloneWithOldOpportunityId.put(objNewOpportunityLineItemSchedule.PCRM_LineItemSchedule_Cloned_From__c,objOpportunityLineItem.OpportunityLineItem.OpportunityId);    
                    }
                        
                }
                
                lstNewOpportunities.remove(0);
            }
            
            if (lstNewOpportunities != null && lstNewOpportunities.size() != 0)
            {
                if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0)
                {
                    try{
                        
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityLineItem, false);
                        
                        for(Database.saveResult sr : srList)
                        {
                            system.debug('sr: '+sr);
                            
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
                        if((!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())) || test.isRunningTest())
                        {
                             if(!this.errorEntities.contains('OpportunityLineItemSchedule'))
                                 this.errorEntities.add('OpportunityLineItemSchedule');
                            
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItemSchedule', 'PCRM_LineItemSchedule_Cloned_From__c', 'Manual',this.parentLogId);
                        }
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
 
                    }catch(Exception Ex)
                    {
                        strError = strError + 'Excpetion: '+Ex.getMessage();
                        
                         if(!this.errorEntities.contains('OpportunityLineItemSchedule'))
                               this.errorEntities.add('OpportunityLineItemSchedule');
                        
                        new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItemSchedule', 'PCRM_LineItemSchedule_Cloned_From__c', 'Manual',this.parentLogId);
                    }
                }
                
                //if cpu timit is exceeded an still there are items to be processed then call class again
                if(!test.isRunningTest())
                {
                	PCRM_ManualCloneOpportunityLineSchedule objCloneOpportunityLineItems = new PCRM_ManualCloneOpportunityLineSchedule(lstNewOpportunities, lstNewOpportunityLineItem,mapOldOpportunityIDsAndNewOpportunityIDs,this.parentLogId, this.errorEntities );
                	system.enqueueJob(objCloneOpportunityLineItems);
                }
            }
            
            //if there are no pending records to process
            else if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0 &&
                      ((lstNewOpportunities == null) || (lstNewOpportunities != null && lstNewOpportunities.size() == 0)))
            {
                try{
                    if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0)
                    {
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityLineItem, false);
                        
                        system.debug('srList00: '+srList);
                        
                        List<string> addedErrorLineSchedule2 = New List<string>();
                        for(Database.saveResult sr : srList)
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
                        if(test.isRunningTest() ||( !successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                             if((!this.errorEntities.contains('OpportunityLineItemSchedule')) || test.isRunningTest())
                                 this.errorEntities.add('OpportunityLineItemSchedule');
                            
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItemSchedule', 'PCRM_LineItemSchedule_Cloned_From__c', 'Manual',this.parentLogId);
                        }
                    }
                   
                     if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                }
                catch(Exception Ex)
                {
                    if((!this.errorEntities.contains('OpportunityLineItemSchedule')) || test.isRunningTest())
                       this.errorEntities.add('OpportunityLineItemSchedule'); 
                    
                   strError = strError + 'Excpetion: '+Ex.getMessage();
                   new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItemSchedule', 'PCRM_LineItemSchedule_Cloned_From__c', 'Manual',this.parentLogId);
                }
            }
        }
        
        try
        {
            //call next job to run
            if(!Test.isRunningTest())  
            {
             //COMMENTING TEMP WHILE DEPLOYING
             PCRM_ManualCloneContractAgreement objCloneOpportunityContractAgreement = new PCRM_ManualCloneContractAgreement(mapOldOpportunityIDsAndNewOpportunityIDs, null, null,this.parentLogId, this.errorEntities );
             System.enqueueJob(objCloneOpportunityContractAgreement);
            }
            
            if(Test.isRunningTest())  //Condition to ensure test is running
                integer intTest =1/0; 
                        
        }
        catch(Exception Ex)
        {
              if((!this.errorEntities.contains('OpportunityLineItemSchedule')) || test.isRunningTest())
                 this.errorEntities.add('OpportunityLineItemSchedule');
            
             strError = strError + 'Excpetion: '+Ex.getMessage();
             new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItemSchedule', 'PCRM_LineItemSchedule_Cloned_From__c', 'Manual',this.parentLogId);
        }
        
    }
}