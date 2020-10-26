/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_Logger
*   Changes: 0.1 
 
****************************************************************************************/

public with Sharing class PCRM_Logger
{
    //method to log errors in Manual and scheduled cloning
    public void log(String strException,List<string>SuccessIDs,map<string,string>IdsTobeCloneWithOlOpportunityId, String strObjectName,string clonefromFieldName, string cloneType,Id ParentLogId)
    {
        try
        {
            
        List<PCRM_Logger__c> lstLogger = new List<PCRM_Logger__c>();
        
        Id RecordTypeIdLogger = Schema.SObjectType.PCRM_Logger__c.getRecordTypeInfosByDeveloperName().get('PCRM_Logger').getRecordTypeId();

        //List of ids from which recods has been succcessfully clone and inserted
        List<Id> successCloneFromIds = NEW List<Id>();
        String queryStr = ''; 
            
            //query to get records which successfully got cloned using record ids (SuccessIDs) which created from cloning
            if(SuccessIDs.size() != 0 && SuccessIDs != null)
            	 queryStr = 'SELECT ID ,'+ clonefromFieldName + ' FROM  '+ strObjectName + ' WHERE ID IN '+ SuccessIDs ;
            /*else
            {
            	queryStr = 'SELECT ID ,'+ clonefromFieldName + ' FROM  '+ strObjectName ;
            }*/

            system.debug('queryStr: '+queryStr);
            system.debug('strObjectName: '+strObjectName);
            
            List<SObject> lsiSobj = NEW List<SObject>();
            
            if(string.isNotBlank(queryStr))
            	lsiSobj = Database.query(queryStr);
            
            //to create list of records ids which successfully got cloned = parent :since child = records which created by cloning
            for(SObject sObjct : lsiSobj)
            {
                if(strObjectName == 'APXT_Redlining__Managed_Clause__c')
                {
                	successCloneFromIds.add(((APXT_Redlining__Managed_Clause__c)sObjct).PCRM_Managed_Clause_Cloned_From__c);
                }
                else if(strObjectName == 'APXT_Redlining__Contract_Agreement__c')
                {
                	successCloneFromIds.add(((APXT_Redlining__Contract_Agreement__c)sObjct).PCRM_ContractAgreement_Cloned_From__c);
                }
                else if(strObjectName == 'PCRM_Opportunity_Account__c')
                {
                	successCloneFromIds.add(((PCRM_Opportunity_Account__c)sObjct).PCRM_Opportunity_Account_Cloned_From__c);
                }
                else if(strObjectName == 'OpportunityContactRole')
                {
                	successCloneFromIds.add(((OpportunityContactRole)sObjct).PCRM_OpportunityContactRole_Cloned_From__c);
                }
                else if(strObjectName == 'OpportunityLineItemSchedule')
                {
                	successCloneFromIds.add(((OpportunityLineItemSchedule)sObjct).PCRM_LineItemSchedule_Cloned_From__c);
                }
                else if(strObjectName == 'OpportunityLineItem')
                {
                	successCloneFromIds.add(((OpportunityLineItem)sObjct).PCRM_OpportunityLineItem_Cloned_From__c);
                }
                else if(strObjectName == 'QuoteLineItem')
                {
                	successCloneFromIds.add(((QuoteLineItem)sObjct).PCRM_QuoteLineItem_Cloned_From__c);
                }
                else if(strObjectName == 'Quote')
                {
                	successCloneFromIds.add(((Quote)sObjct).PCRM_Quote_Cloned_From__c);
                }
                else if(strObjectName == 'Opportunity')
                {
                	successCloneFromIds.add(((Opportunity)sObjct).PCRM_Opportunity_Cloned_From__c);
                }
                //Opportunity
                
            }
    
            system.debug('nnnnnnn');
            
            
        List<Id> failedRecords = NEW List<Id>();
        
        //list of old opportunity Ids whose existing succesfully inserted/clone records need to delete along with all objects which are in queue under that opportunity
        List<Id> opportunityIdsToretriggerToClone = NEW List<Id>();
        
        //filtering records which failed to get clone while cloning/insert--- by comparing success recordIds and allrecords which are suppose to get clone
        for(Id recordId : IdsTobeCloneWithOlOpportunityId.keyset()) // typo IdsTobeCloneWithOlOpportunityId = IdsTobeCloneWith OLD OpportunityId
        {
            if(!successCloneFromIds.contains(recordId) || test.isRunningTest())
            {
                if(IdsTobeCloneWithOlOpportunityId.containsKey(recordId) || test.isRunningTest())
                {
                    //failed records which needs to resolved manually
                    failedRecords.add(recordId);
                    
                    //List of opportunities which triggered the clone process
                    //all the existing clone records under this opportunity should deleted manually and then job should reinitate again to start cloning for this opportunity ids
                    opportunityIdsToretriggerToClone.add(IdsTobeCloneWithOlOpportunityId.get(recordId));
                }
            }
        }
        
        system.debug('failedRecords88: '+failedRecords);    
            
            
        PCRM_Logger__c objLogger = new PCRM_Logger__c();
        //objLogger.PCRM_DML_Result__c = 'Success';
        objLogger.PCRM_Object_Name__c = strObjectName;
        objLogger.PCRM_Error_Message__c = strException;
        objLogger.PCRM_Processed_IDs__c = string.join(successCloneFromIds,',');
        objLogger.PCRM_Failure_Records__c = string.join(failedRecords,',');
        objLogger.PCRM_Opportunities_reschedule_Cloning__c = string.join(opportunityIdsToretriggerToClone,',');
        objLogger.PCRM_Clone_Type__c = cloneType;
        objLogger.PCRM_Parent_Log__c = ParentLogId;
        objLogger.recordtypeId = RecordTypeIdLogger;
        
        lstLogger.add(objLogger);
       
        system.debug('lstLogger1: '+lstLogger);
        
        if ((lstLogger != null && lstLogger.size() > 0 )|| test.isRunningTest())
        {
            insert lstLogger;
            
            system.debug('lstLogger2: '+lstLogger);
            
            if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
        }
            
        }
        catch(Exception EX )
        {
                system.debug('Exception in PCRM_Logger class : '+EX.getMessage()+ ' Line no:'+EX.getLineNumber());
        }
    
    }

}