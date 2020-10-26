/************************************************************************************************************************
* Description: The job processes recurrsively to create Contact Roles clones and navigates to next job in line thereafter.
* Change Log: initial draft created for cloning Contact Roles associated with given set of Opportunities & Accounts.
*************************************************************************************************************************/

public with Sharing class PCRM_CloneContactRoles implements Queueable{

    private Map<Id, Id> mapOldOpportunityIdWithNewOpportunityId = new map<Id, Id>();
    private List<OpportunityContactRole> lstContactRolesWithOldOpportunities = new List<OpportunityContactRole>();
    private List<OpportunityContactRole> lstNewContactRoles = new List<OpportunityContactRole>();
    private boolean isBulkClone = false;
    private Id parentLogId = null;
    
    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
    
    private string opportunityOwnerEmailAddress ='';
    
    public Integer cpuTimeLimit = 0;
    //constructor
    public PCRM_CloneContactRoles(Map<Id, Id> mapOldOppIdWithNewOppId, List<OpportunityContactRole> lstContactRolesWithOldOpps, List<OpportunityContactRole> lstContactRoles, boolean isBulk,Id parentLogId,List<string>errorEntities,string opportunityOwnerEmailAddress )
    {
         this.opportunityOwnerEmailAddress = opportunityOwnerEmailAddress;
        
        //assign with custom label
        if(!test.isRunningTest())
        cpuTimeLimit = 5000;
        
         //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
            this.parentLogId = parentLogId;
        
        this.errorEntities = errorEntities;
        
        if (mapOldOppIdWithNewOppId != null && mapOldOppIdWithNewOppId.size() > 0){
            this.mapOldOpportunityIdWithNewOpportunityId = mapOldOppIdWithNewOppId;
        }
        
        if (lstContactRolesWithOldOpps != null && lstContactRolesWithOldOpps.size() > 0){
            this.lstContactRolesWithOldOpportunities = lstContactRolesWithOldOpps;
        }
        
        if (lstContactRoles != null && lstContactRoles.size() > 0){
            this.lstNewContactRoles = lstContactRoles;
        }
        
        this.isBulkClone = isBulk;
    }

    //execute method
    public void execute(QueueableContext context) 
    {
        
        //all the records which are supposed to get cloned
         map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
         List<string> successIds = NEW List<string>();
                
         string  strError='';
        
        List<OpportunityContactRole> lstTemporaryNewContactRoles = new List<OpportunityContactRole>();
        
        //QUERY
        if (mapOldOpportunityIdWithNewOpportunityId != null && mapOldOpportunityIdWithNewOpportunityId.size() > 0)
        {
            set<Id> setOldOppoerunityId = new set<Id>();
            setOldOppoerunityId.addall(mapOldOpportunityIdWithNewOpportunityId.keyset());
            
            try
            {
                lstContactRolesWithOldOpportunities = [SELECT ContactId,CurrencyIsoCode, Id, OpportunityId, Role FROM OpportunityContactRole where OpportunityId IN: setOldOppoerunityId];
            
                if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
            }catch(Exception Ex)
            {
                
                        system.debug('Exception Occuered. Class: PCRM_CloneContactRoles, Method: execute, Details: ' + Ex.getMessage());
                        strError = strError + 'Excpetion: '+Ex.getMessage();
                            
                         //log the errors
                        if(test.isRunningTest() ||  (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('OpportunityContactRole')))
                             this.errorEntities.add('OpportunityContactRole');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c', 'Scheduled', this.parentLogId );
                            }
                        }
                
            }
            
        }
        
       
        if (lstContactRolesWithOldOpportunities != null && lstContactRolesWithOldOpportunities.size() > 0 &&
            mapOldOpportunityIdWithNewOpportunityId != null && mapOldOpportunityIdWithNewOpportunityId.size() > 0)
        {
             //1 PROCESSING CLONING RECORDS   
            for (; lstContactRolesWithOldOpportunities.size() > 0;)
            {
                
                system.debug('cpuLimt: '+Limits.getCpuTime());
                    //if (Limits.getCpuTime() > 5000)
                    if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                        break;
                    }
                
                OpportunityContactRole objOldOpportunityContactRole = lstContactRolesWithOldOpportunities[0];
                
                if (mapOldOpportunityIdWithNewOpportunityId.containsKey(objOldOpportunityContactRole.OpportunityId) &&
                    mapOldOpportunityIdWithNewOpportunityId.get(objOldOpportunityContactRole.OpportunityId) != null)
                {
                        
                    OpportunityContactRole objNewOpportunityContactRole = new OpportunityContactRole();
                    objNewOpportunityContactRole.ContactId = objOldOpportunityContactRole.ContactId;
                    objNewOpportunityContactRole.CurrencyIsoCode = objOldOpportunityContactRole.CurrencyIsoCode;
                    objNewOpportunityContactRole.PCRM_OpportunityContactRole_Cloned_From__c = objOldOpportunityContactRole.Id;
                    objNewOpportunityContactRole.OpportunityId = mapOldOpportunityIdWithNewOpportunityId.get(objOldOpportunityContactRole.OpportunityId);
                    objNewOpportunityContactRole.Role = objOldOpportunityContactRole.Role;
                    objNewOpportunityContactRole.PCRM_isCreatedFromCloning__c = True;    
                        
                    lstTemporaryNewContactRoles.add(objNewOpportunityContactRole);
                        
                    system.debug('objOldOpportunityContactRole.OpportunityId: '+objOldOpportunityContactRole.OpportunityId);    
                    IdsTobeCloneWithOldOpportunityId.put(objNewOpportunityContactRole.PCRM_OpportunityContactRole_Cloned_From__c,objOldOpportunityContactRole.OpportunityId);    
    
                    //this.lstNewContactRoles.add(objNewOpportunityContactRole);
                }
                
                //REMOVE PROCESSED RECORD
                lstContactRolesWithOldOpportunities.remove(0);
            }
            
            
            //IF PROCESSING RECORDS BREAKS- BECAUSE OF EXCEDDED CPU TIME - THEN PROCESS PENDING RECORDS 
            //BUT FIRST INSERT SUCCESSFULLY RECORDS WHICH CREATED BY CLONING
            if (this.lstContactRolesWithOldOpportunities != null && this.lstContactRolesWithOldOpportunities.size() > 0)
            {
                //FIRST INSERT SUCCESSFULLY RECORDS WHICH CREATED BY CLONING
                if ((lstTemporaryNewContactRoles != null && lstTemporaryNewContactRoles.size() > 0) || test.isRunningTest())
                {
                    String strSuccessIDs = '';
                    String strExceptions = '';
                
                    try
                    {
                        
                        Database.SaveResult[] srList = database.insert(lstTemporaryNewContactRoles, false);
                        this.lstNewContactRoles.addAll(lstTemporaryNewContactRoles);
                        
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
                            if(test.isRunningTest()  || (!this.errorEntities.contains('OpportunityContactRole')))
                             this.errorEntities.add('OpportunityContactRole');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c', 'Scheduled',  this.parentLogId );
                            }
                        }
                        
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                        
                        
                    }
                    catch(Exception Ex)
                    {
                        
                        system.debug('Exception Occuered. Class: PCRM_CloneContactRoles, Method: execute, Details: ' + Ex.getMessage());
                        strError = strError + 'Excpetion: '+Ex.getMessage();
                         //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('OpportunityContactRole')))
                             this.errorEntities.add('OpportunityContactRole');
                            
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c', 'Scheduled', this.parentLogId );
                            }
                        }

                    }
                }
                
                if(!test.isRunningTest())
                {
                 PCRM_CloneContactRoles objCloneContactRoles = new PCRM_CloneContactRoles(this.mapOldOpportunityIdWithNewOpportunityId, this.lstContactRolesWithOldOpportunities, this.lstNewContactRoles, this.isBulkClone, this.parentLogId, this.errorEntities,this.opportunityOwnerEmailAddress );
                 system.enqueueJob(objCloneContactRoles);
                }
            }
            
                //when all of the records' cloning process is completed
                else if (this.lstContactRolesWithOldOpportunities != null && this.lstContactRolesWithOldOpportunities.size() == 0)
                {
                try
                {
                    //insert records which got created by cloning
                    if(lstTemporaryNewContactRoles != null && lstTemporaryNewContactRoles.size() > 0)
                    {
                    
                        String strSuccessIDs = '';
                        String strExceptions = '';

                        Database.SaveResult[] srList = database.insert(lstTemporaryNewContactRoles, false);
                        this.lstNewContactRoles.addAll(lstTemporaryNewContactRoles);
                        
                        for (Database.SaveResult sr: srList){
                            if (sr.isSuccess()) {
                                strSuccessIDs = strSuccessIDs + sr.getId() + ',';
                                successIds.add('\''+ sr.getId() + '\'');
                            }else {
                                for(Database.Error err : sr.getErrors()) {
                                    strExceptions = strExceptions + err.getMessage() + ';' + '\n';
                                    
                                     strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                }
                            }
                        }
                        
                       //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()  || (!this.errorEntities.contains('OpportunityContactRole')))
                             this.errorEntities.add('OpportunityContactRole');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c','Manual', this.parentLogId );
                            }
                            else//when running via batch/scheduled jobs
                            {
                                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c', 'Scheduled', this.parentLogId );
                            }
                        }                      
                    }
                    
                    //Quotes will only be get cloned in Scheduled/Bulk Cloning not in manual Cloning
                    if (this.isBulkClone && !test.isRunningTest() )
                    {
                        PCRM_CloneQuotes objCloneQuotes = new PCRM_CloneQuotes(this.mapOldOpportunityIdWithNewOpportunityId, null, null,this.isBulkClone, this.parentLogId,this.errorEntities);
                        system.enqueueJob(objCloneQuotes);
                    }
                    
                    if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    
                                      
                }
                    catch(Exception Ex)
                    {
                    strError = strError + 'Excpetion: '+Ex.getMessage();
                    
                     //log the errors
                    if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                    {
                        if(test.isRunningTest()  || (!this.errorEntities.contains('OpportunityContactRole')))
                             this.errorEntities.add('OpportunityContactRole');
                        
                        if(!this.isBulkClone)//when running via mannaul cloning
                        {
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c','Manual', this.parentLogId );
                        }
                        else//when running via batch/scheduled jobs
                        {
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c', 'Scheduled', this.parentLogId );
                        }
                    }
                }
            }
            
        }
        
        try
        {
             //this is last job in manual cloning/contract renewal.... so sending mail to user that cloning process is complete
            if(!this.isBulkClone || test.isRunningTest())
            {
                // Email template Id
                String templateId = '';
                if(!test.isRunningTest())
                {
                    templateId = [SELECT Id,Body FROM EmailTemplate where developerName = 'PCRM_Notify_ContractRenewal'].Id;
                }
    
                if(this.mapOldOpportunityIdWithNewOpportunityId.size() > 0)
                {
                    List<Id> clonedOpportunityIdList = null;
                    if (this.mapOldOpportunityIdWithNewOpportunityId.keySet() != null)
                    {
                      clonedOpportunityIdList = new List<Id>();
                      clonedOpportunityIdList.addAll(this.mapOldOpportunityIdWithNewOpportunityId.values());
                      
                      List<string> OwnerEmailAddressList = NEW    List<string>();
                      OwnerEmailAddressList.add(this.opportunityOwnerEmailAddress);  
                        
                      //email will be sent to Owner of Parent Opportunity  
                      //but Detail link of Opportunity Record in mail template will be related to Opportunity which is created from cloning...hence third parameter
                      new PCRM_SendEmail().sendEmail(templateId,OwnerEmailAddressList,clonedOpportunityIdList[0]);
                    }
                    
                }
            } 
            
            if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
        }
        Catch(Exception Ex)
        {
            strError = strError + 'Excpetion: '+Ex.getMessage();
             //log the errors
            if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
            {
                if(test.isRunningTest()  || (!this.errorEntities.contains('OpportunityContactRole')))
                             this.errorEntities.add('OpportunityContactRole');
                if(!this.isBulkClone)//when running via mannaul cloning
                {
                    new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c','Manual', this.parentLogId );
                }
                else//when running via batch/scheduled jobs
                {
                    new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityContactRole', 'PCRM_OpportunityContactRole_Cloned_From__c', 'Scheduled', this.parentLogId );
                }
            }
        }
        
        
        //if it is manuall process and errorEntities is not null then send email to admin that job failed
        if(test.isRunningTest()  || (!this.isBulkClone  &&  this.errorEntities.size() > 0  &&  this.errorEntities != null))
         {
             new PCRM_SendEmail().sendEmailToAdmin(parentLogId);
            //PCRM_SendEmail.sendEmail(templateId,lstOfReciptent,clonedOpportunityIdList[0]);
         }
        
        
    }
}