/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_CloneContactRoles
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestCloneContactRoles
{
    //validation methods from PCRM_CloneContactRoles
	static testMethod void validateExecuteViaManualClone() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(2, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                INSERT ListOfNewOpportunity;
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                
                Integer count = 0;
                //update opportunity as they are created from cloning
                for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
                {
                    cloneOpportunity.PCRM_isCreatedFromCloning__c = true;
                    
                    cloneOpportunity.PCRM_Opportunity_Cloned_From__c = ListOfNewOpportunity[Count].Id;
                    
                    if(Count < ListOfNewOpportunity.size())
                    Count = count + 1;
                }
                INSERT ListOfCreatedFromCloningOpportunity;
                
                //create map of old opportunity and new oppotunity Id
                Map<Id,Id> mapOfOldwithNewOpportunityId = NEW Map<Id,Id>();
                for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
                {
                    mapOfOldwithNewOpportunityId.put(cloneOpportunity.PCRM_Opportunity_Cloned_From__c,cloneOpportunity.Id);
                }
                
                //create logger obj
                PCRM_Logger__c objLogger = new PCRM_Logger__c();
                INSERT objLogger;
                
                if(mapOfOldwithNewOpportunityId.size() > 0)
                {
                    /********** create contacts */
                     List <Contact> ListOfContacts = utilityClass.createContact(25,'PCRM_Petchem_Contact');
                     INSERT ListOfContacts;
                    /********** create contacts */
                    
                    
                      /*********************************create Clone Contact Roles records*/
                      List <OpportunityContactRole> ListOfOpportunityContactRole = utilityClass.createOpportunityContactRole(ListOfNewOpportunity[0],ListOfContacts);
                      INSERT ListOfOpportunityContactRole;
                     /*********************************create Clone Contact Roles records*/
                
                    test.startTest();
                    
                        List<string> listOfErrEntities = NEW List<string> ();
                    
                    	PCRM_CloneContactRoles QueableContactRoleCloneObj = NEW PCRM_CloneContactRoles(mapOfOldwithNewOpportunityId,null,null,false,objLogger.Id,listOfErrEntities,'');
                    	//53,40
                        QueableContactRoleCloneObj.cpuTimeLimit = 20;
                        System.enqueueJob(QueableContactRoleCloneObj); 
                    
                    
                       system.debug('abc : '+ ListOfOpportunityContactRole[0].opportunityId);
                       system.debug('xyz: '+ListOfNewOpportunity[0].Id);
                    
                       system.assertEquals(ListOfNewOpportunity[0].Id, ListOfOpportunityContactRole[0].opportunityId);
                    
                    test.stopTest();
                    
                }
        
            }
        

    }
    
    
    
    //validation methods from PCRM_CloneContactRoles
	static testMethod void validateExecuteViaScheduleClone() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(2, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                INSERT ListOfNewOpportunity;
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                
                Integer count = 0;
                //update opportunity as they are created from cloning
                for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
                {
                    cloneOpportunity.PCRM_isCreatedFromCloning__c = true;
                    
                    cloneOpportunity.PCRM_Opportunity_Cloned_From__c = ListOfNewOpportunity[Count].Id;
                    
                    if(Count < ListOfNewOpportunity.size())
                    Count = count + 1;
                }
                INSERT ListOfCreatedFromCloningOpportunity;
                
                //create map of old opportunity and new oppotunity Id
                Map<Id,Id> mapOfOldwithNewOpportunityId = NEW Map<Id,Id>();
                for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
                {
                    mapOfOldwithNewOpportunityId.put(cloneOpportunity.PCRM_Opportunity_Cloned_From__c,cloneOpportunity.Id);
                }
                
                //create logger obj
                PCRM_Logger__c objLogger = new PCRM_Logger__c();
                INSERT objLogger;
                
                if(mapOfOldwithNewOpportunityId.size() > 0)
                {
                    /********** create contacts */
                     List <Contact> ListOfContacts = utilityClass.createContact(3,'PCRM_Petchem_Contact');
                     INSERT ListOfContacts;
                    /********** create contacts */
                    
                    
                      /*********************************create Clone Contact Roles records*/
                      List <OpportunityContactRole> ListOfOpportunityContactRole = utilityClass.createOpportunityContactRole(ListOfNewOpportunity[0],ListOfContacts);
                      INSERT ListOfOpportunityContactRole;
                     /*********************************create Clone Contact Roles records*/
                
                    test.startTest();
                    
                        List<string> listOfErrEntities = NEW List<string> ();

                    	PCRM_CloneContactRoles QueableContactRoleCloneObj = NEW PCRM_CloneContactRoles(mapOfOldwithNewOpportunityId,null,null,true,objLogger.Id,listOfErrEntities,'');
                    	QueableContactRoleCloneObj.cpuTimeLimit = 80;
                        System.enqueueJob(QueableContactRoleCloneObj); 
                    
                       system.debug('abc1 : '+ ListOfOpportunityContactRole[0].opportunityId);
                       system.debug('xyz1: '+ListOfNewOpportunity[0].Id);
                       system.assertEquals(ListOfNewOpportunity[0].Id, ListOfOpportunityContactRole[0].opportunityId);
                    
                    test.stopTest();
                    
                }
        
            }
        

    }
}