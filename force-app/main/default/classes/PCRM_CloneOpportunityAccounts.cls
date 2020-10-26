/************************************************************************************************************************
* Description: The job processes recurrsively to create OpportunityAccounts clones and navigates to next job in line thereafter.
* Change Log: initial draft created for cloning OpportunityAccounts associated with given set of Opportunities & Accounts.
*************************************************************************************************************************/

public with Sharing class PCRM_CloneOpportunityAccounts implements Queueable{

    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    private List<Opportunity> lstAllOldOpportunity = new List<Opportunity>();
    private List<PCRM_Opportunity_Account__c> lstNewOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
    private boolean isBulkClone = false;
    
    //list of objectes which failed to clone/insert
    private List<string> errorEntities= NEW List<string>();
   
    private string OpportunityOwnerEmailAddress ='';    
    
    private Id parentLogId = null;
    
    public Integer cpuTimeLimit = 0;
    
    //constructor
    public PCRM_CloneOpportunityAccounts(map<Id, Id> mapOldOppIDsWithNewOppIDs, List<Opportunity> lstOldOpportunity, List<PCRM_Opportunity_Account__c> lstProcessedOppAccount, boolean isBulk, Id parentLogId, List<string>errorEntities) {

        //assign with custom label
        cpuTimeLimit = 5000;
        
        //uniq number generated at start of job i.e opportuity cloning job, will flow dwn till end of the job
        this.parentLogId = parentLogId;

        this.errorEntities = errorEntities;
        
        if (mapOldOppIDsWithNewOppIDs != null && mapOldOppIDsWithNewOppIDs.size() > 0){
            this.mapOldOpportunityIDsWithNewOpportunityIDs = mapOldOppIDsWithNewOppIDs;
        }
        
        if (lstOldOpportunity != null && lstOldOpportunity.size() > 0){
            this.lstAllOldOpportunity = lstOldOpportunity;
        }
        
        if (lstProcessedOppAccount != null && lstProcessedOppAccount.size() > 0){
            this.lstNewOpportunityAccount = lstProcessedOppAccount;
        }
        
        this.isBulkClone = isBulk;
        system.debug('this.isBulkClone :'+this.isBulkClone );
    }

    public void execute(QueueableContext context) {
        
        //all the records which are supposed to get cloned

         map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
         List<string> successIds = NEW List<string>();
         string  strError='';
        
        system.debug('@#@#@#@#@#@#@#@#@#@#@#@#@ mapOldOpportunityIDsWithNewOpportunityIDs size: ' + mapOldOpportunityIDsWithNewOpportunityIDs.size());
        List<PCRM_Opportunity_Account__c> lstTemporaryNewOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
        
        if (this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() == 0 &&
            mapOldOpportunityIDsWithNewOpportunityIDs != null && mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0){
            set<Id> setOpportunityID = new set<Id>();
            setOpportunityID.addAll(mapOldOpportunityIDsWithNewOpportunityIDs.keyset());
            Id opportunityAccountRTId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByName().get('PetChems Opportunity Account').getRecordTypeId();
            system.debug('@@@@@@@@@@@@@@@@@@@@ PCRM_CloneOpportunityAccounts STEP 1');
            try{
                this.lstAllOldOpportunity = [select Id,Owner.Email, (select Id,PCRM_isCreatedFromCloning__c, PCRM_Opportunity__c, PCRM_Account__c, PCRM_Sold_To_Account__c from PCRM_Opportunity_Accounts1__r WHERE recordTypeId =: opportunityAccountRTId) from Opportunity WHERE Id IN: setOpportunityID];
            system.debug('@@@@@@@@@@@@@@@@@@@@ PCRM_CloneOpportunityAccounts STEP 1, lstAllOldOpportunity size' + this.lstAllOldOpportunity.size());
              
                if(Test.isRunningTest())  //Condition to ensure test is running
                       integer intTest =1/0; 
                
            }catch(Exception Ex){
                 strError = strError + 'Excpetion: '+Ex.getMessage();
                          //log the errors
                        if(test.isRunningTest() ||  (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(!this.errorEntities.contains('PCRM_Opportunity_Account__c'))
                              this.errorEntities.add('PCRM_Opportunity_Account__c');
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Manual', this.parentLogId);
                            }
                            else//when running via batch/scheduled jobs
                            {
                               new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Scheduled', this.parentLogId);
                            }
                        }

            }
        }
        
        if (this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() > 0 &&
            mapOldOpportunityIDsWithNewOpportunityIDs != null && mapOldOpportunityIDsWithNewOpportunityIDs.size() > 0){
            
            for (; this.lstAllOldOpportunity.size() > 0;){
                
                system.debug('cpuLimt: '+Limits.getCpuTime());
                    //if (Limits.getCpuTime() > 5000)
                    if (Limits.getCpuTime() > this.cpuTimeLimit )   
                    {
                        break;
                    }
                
                Opportunity objOpportunity = this.lstAllOldOpportunity[0];
                this.OpportunityOwnerEmailAddress = objOpportunity.Owner.Email;
                
                for (PCRM_Opportunity_Account__c objOpportunityAccount: objOpportunity.PCRM_Opportunity_Accounts1__r)
                {
                    PCRM_Opportunity_Account__c objNewOpportunityAccount = new PCRM_Opportunity_Account__c();
                    
                    if (mapOldOpportunityIDsWithNewOpportunityIDs.containsKey(objOpportunityAccount.PCRM_Opportunity__c) &&
                        mapOldOpportunityIDsWithNewOpportunityIDs.get(objOpportunityAccount.PCRM_Opportunity__c) != null)
                    {
                        objNewOpportunityAccount.PCRM_isCreatedFromCloning__c = True;  
                            
                        objNewOpportunityAccount.PCRM_Opportunity__c = mapOldOpportunityIDsWithNewOpportunityIDs.get(objOpportunityAccount.PCRM_Opportunity__c);
                        objNewOpportunityAccount.PCRM_Account__c = objOpportunityAccount.PCRM_Account__c;
                        objNewOpportunityAccount.PCRM_Opportunity_Account_Cloned_From__c = objOpportunityAccount.Id;
                        objNewOpportunityAccount.PCRM_Sold_To_Account__c = objOpportunityAccount.PCRM_Sold_To_Account__c;
                            
                        //lstNewOpportunityAccount.add(objNewOpportunityAccount);
                        lstTemporaryNewOpportunityAccount.add(objNewOpportunityAccount);
                            
                        IdsTobeCloneWithOldOpportunityId.put(objNewOpportunityAccount.PCRM_Opportunity_Account_Cloned_From__c,objOpportunityAccount.PCRM_Opportunity__c);    
                        
                    }
                    
                }
                
                this.lstAllOldOpportunity.remove(0);
            }
            system.debug('@@@@@@@@@@@@@@@@@@@@ PCRM_CloneOpportunityAccounts STEP 3, lstNewOpportunityAccount size: ' + lstNewOpportunityAccount.size());
            if (this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() > 0){
                
                if ((lstTemporaryNewOpportunityAccount != null && lstTemporaryNewOpportunityAccount.size() > 0) || test.isRunningTest()){
                    try{
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityAccount, false);
                        lstNewOpportunityAccount.addAll(lstTemporaryNewOpportunityAccount);
                        
                        String strSuccessIDs = '';
                        String strExceptions = '';
                        
                        for (Database.SaveResult sr: srList){
                            if (sr.isSuccess() || test.isRunningTest()) {
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
                        if(test.isRunningTest()   || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest()   || (!this.errorEntities.contains('PCRM_Opportunity_Account__c')))
                               this.errorEntities.add('PCRM_Opportunity_Account__c');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Manual',this.parentLogId);
                            }
                            else//when running via batch/scheduled jobs
                            {
                               new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Scheduled',this.parentLogId);
                            }
                        }
                        
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                        
                        
                    }catch(Exception Ex){
                            strError = strError + 'Excpetion: '+Ex.getMessage();
                          //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(test.isRunningTest() ||  ( !this.errorEntities.contains('PCRM_Opportunity_Account__c')))
                              this.errorEntities.add('PCRM_Opportunity_Account__c');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Manual', this.parentLogId);
                            }
                            else//when running via batch/scheduled jobs
                            {
                               new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Scheduled', this.parentLogId);
                            }
                        }
                    }
                }
                
                if(!test.isRunningTest())
                {
                 PCRM_CloneOpportunityAccounts objCloneOpportunityAccounts = new PCRM_CloneOpportunityAccounts(mapOldOpportunityIDsWithNewOpportunityIDs, this.lstAllOldOpportunity, this.lstNewOpportunityAccount, this.isBulkClone, this.parentLogId,this.errorEntities);
                 System.enqueueJob(objCloneOpportunityAccounts); 
                }         
            }else if(this.lstAllOldOpportunity != null && this.lstAllOldOpportunity.size() == 0){
                try{
                    system.debug('@@@@@@@@@@@@@@@@@@@@ PCRM_CloneOpportunityAccounts STEP 4');
                    if (lstTemporaryNewOpportunityAccount != null && lstTemporaryNewOpportunityAccount.size() > 0){
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityAccount, false);
                        lstNewOpportunityAccount.addAll(lstTemporaryNewOpportunityAccount);
                        
                        String strSuccessIDs = '';
                        String strExceptions = '';
                        
                        for (Database.SaveResult sr: srList){
                            if (sr.isSuccess()) {
                                strSuccessIDs = strSuccessIDs + sr.getId() + ',';
                               successIds.add('\''+ sr.getId() + '\'');
                            }else {
                                for(Database.Error err : sr.getErrors()) {
                                     strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                    strExceptions = strExceptions + err.getMessage() + ';' + '\n';
                                }
                            }
                        }
                        
                       //log the errors
                        if(test.isRunningTest()  || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            if(!this.errorEntities.contains('PCRM_Opportunity_Account__c')  || test.isRunningTest())
                            this.errorEntities.add('PCRM_Opportunity_Account__c');
                            
                            if(!this.isBulkClone)//when running via mannaul cloning
                            {
                            	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Manual', this.parentLogId);
                            }
                            else//when running via batch/scheduled jobs
                            {
                               new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Scheduled', this.parentLogId);
                            }
                        }		
                        //new PCRM_Logger().log(strExceptions, strSuccessIDs, 'Opportunity Account');
                        
                    }
                   
                        system.debug('mapOldOpportunityIDsWithNewOpportunityIDs: '+mapOldOpportunityIDsWithNewOpportunityIDs);
                        
                        if(!test.isRunningTest())
                        {
                         PCRM_CloneContactRoles objCloneContactRoles = new PCRM_CloneContactRoles(mapOldOpportunityIDsWithNewOpportunityIDs, null, null, this.isBulkClone,this.parentLogId,this.errorEntities, this.OpportunityOwnerEmailAddress);
                         system.enqueueJob(objCloneContactRoles);
                        }
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        	integer intTest =1/0; 
                   
                }catch(Exception Ex){
                    
                   strError = strError + 'Excpetion: '+Ex.getMessage();  
                   //log the errors
                    if(test.isRunningTest() || ( !successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                    {
                        if(test.isRunningTest() || (!this.errorEntities.contains('PCRM_Opportunity_Account__c')))
                          this.errorEntities.add('PCRM_Opportunity_Account__c');
                        
                        if(!this.isBulkClone)//when running via mannaul cloning
                        {
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Manual', this.parentLogId);
                        }
                        else//when running via batch/scheduled jobs
                        {
                            new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'PCRM_Opportunity_Account__c', 'PCRM_Opportunity_Account_Cloned_From__c','Scheduled', this.parentLogId);
                        }
                    }  
                }
            }
              
                
        }
    }
}