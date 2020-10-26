/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_ManualCloneContractAgreement
*   Changes: 0.1 
 
****************************************************************************************/
@isTest
public with sharing class PCRM_TestManualCloneContractAgreement 
{
	//validating methods from class PCRM_ManualCloneContractAgreement when cpu time limit is > 50
	static testMethod void validateExecuteWithRecurssion() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSP'); //sold to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,32,'PCRM_PetChems_Acetyls');
                INSERT ListOfNewOpportunity;
                
                system.debug('ListOfNewOpportunity88:'+ListOfNewOpportunity);
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,32,'PCRM_PetChems_Acetyls');
                
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
                
                system.debug('mapOfOldwithNewOpportunityIdTestClass: '+mapOfOldwithNewOpportunityId);
                
                
                //create Products records
               // List<Product2> ListProducts = utilityClass.createProducts(3);
                
                //create logger obj
                PCRM_Logger__c objLogger = new PCRM_Logger__c();
                INSERT objLogger;
                
                if(mapOfOldwithNewOpportunityId.size() > 0)
                {
                     /*********************************create Contract Agreements*/
                      List <APXT_Redlining__Contract_Agreement__c> ListOfContractAgreements = utilityClass.createContractAgreement(ListOfNewOpportunity,'PCRM_Chemicals_Acetyls');
                      INSERT ListOfContractAgreements;
                     /*********************************create Contract Agreements*/
                    
                    
                     /*********************************create Managed clauses records*/
                      List <APXT_Redlining__Managed_Clause__c> ListOfManagedClauses = utilityClass.createManagedClauses(ListOfContractAgreements);
                      INSERT ListOfManagedClauses;
                     /*********************************create Managed clauses records*/
                    
                   
                    system.debug('ListOfManagedClausesTest: '+ListOfManagedClauses);
                    
                    
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();
                    
                    	PCRM_ManualCloneContractAgreement QueableContrctAgreemntCloneObj = NEW PCRM_ManualCloneContractAgreement(mapOfOldwithNewOpportunityId,null,null,objLogger.Id,listOfErrEntities);
                        QueableContrctAgreemntCloneObj.cpuTimeLimit = 84;
                      
                        System.enqueueJob(QueableContrctAgreemntCloneObj); 
                    
                        system.debug('abcjjj: '+mapOfOldwithNewOpportunityId.keyset().contains(ListOfNewOpportunity[0].Id));
                        system.assertEquals(true, mapOfOldwithNewOpportunityId.keyset().contains(ListOfNewOpportunity[0].Id));
                    
                    test.stopTest();
                    
                }
        
            }
    }
    
    
     //validating methods from class PCRM_ManualCloneContractAgreement when cpu limit is > 80
	static testMethod void validateExecuteWithoutRecurssion() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSP'); //sold to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                INSERT ListOfNewOpportunity;
                
                system.debug('ListOfNewOpportunity88:'+ListOfNewOpportunity);
                
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
                
                system.debug('mapOfOldwithNewOpportunityIdTestClass: '+mapOfOldwithNewOpportunityId);
                
                
                //create Products records
                List<Product2> ListProducts = utilityClass.createProducts(3);
                
                //create logger obj
                PCRM_Logger__c objLogger = new PCRM_Logger__c();
                INSERT objLogger;
                
                if(mapOfOldwithNewOpportunityId.size() > 0)
                {
                     /*********************************create Contract Agreements*/
                      List <APXT_Redlining__Contract_Agreement__c> ListOfContractAgreements = utilityClass.createContractAgreement(ListOfNewOpportunity,'PCRM_Chemicals_Acetyls');
                      INSERT ListOfContractAgreements;
                     /*********************************create Contract Agreements*/
                    
                    
                     /*********************************create Managed clauses records*/
                      List <APXT_Redlining__Managed_Clause__c> ListOfManagedClauses = utilityClass.createManagedClauses(ListOfContractAgreements);
                      INSERT ListOfManagedClauses;
                     /*********************************create Managed clauses records*/
                    
                   
                    system.debug('ListOfManagedClausesTest: '+ListOfManagedClauses);
                    
                    
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();
                    
                    	PCRM_ManualCloneContractAgreement QueableContrctAgreemntCloneObj = NEW PCRM_ManualCloneContractAgreement(mapOfOldwithNewOpportunityId,null,null,objLogger.Id,listOfErrEntities);
                        QueableContrctAgreemntCloneObj.cpuTimeLimit = 80;
                        System.enqueueJob(QueableContrctAgreemntCloneObj); 
                    
                       system.debug('abcjjj777: '+mapOfOldwithNewOpportunityId.keyset().contains(ListOfNewOpportunity[0].Id));
                       system.assertEquals(true, mapOfOldwithNewOpportunityId.keyset().contains(ListOfNewOpportunity[0].Id));
                    
                    test.stopTest();
                    
                }
        
            }
    }
    
}