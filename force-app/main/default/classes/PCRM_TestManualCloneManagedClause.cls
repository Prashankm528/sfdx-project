/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_ManualCloneManagedClause
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestManualCloneManagedClause 
{
	//validating methods from class PCRM_ManualCloneManagedClause when cpu time limit is > 50
	static testMethod void validateExecuteWithRecurssion() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,30,'PCRM_PetChems_Acetyls');
                INSERT ListOfNewOpportunity;
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,30,'PCRM_PetChems_Acetyls');
                
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
                    
                       //create cloned test data of contrct agreement by updating field PCRM_ContractAgreement_Cloned_From__c
                      List <APXT_Redlining__Contract_Agreement__c> ListOfContractAgreementsCreatedFromClone = utilityClass.createContractAgreement(ListOfNewOpportunity,'PCRM_Chemicals_Acetyls');
                      
                      Count = 0;
                      //updating PCRM_ContractAgreement_Cloned_From__c with ListOfContractAgreements records
                      for(APXT_Redlining__Contract_Agreement__c clonedContrctAgreemnt : ListOfContractAgreementsCreatedFromClone)
                      {
                          clonedContrctAgreemnt.PCRM_isCreatedFromCloning__c = true;
                          clonedContrctAgreemnt.PCRM_ContractAgreement_Cloned_From__c = ListOfContractAgreements[Count].Id;
                          
                          if(count < ListOfContractAgreements.size() )
                          Count= Count+ 1;      
                      }
                    
                      INSERT  ListOfContractAgreementsCreatedFromClone;
                      system.debug('ListOfContractAgreementsCreatedFromCloneYTetclsss: '+ListOfContractAgreementsCreatedFromClone);
                    
                    
                     /*********************************create Contract Agreements*/
                    
                    
                     /*********************************create Managed clauses records*/
                      List <APXT_Redlining__Managed_Clause__c> ListOfManagedClauses = utilityClass.createManagedClauses(ListOfContractAgreements);
                      INSERT ListOfManagedClauses;
                     /*********************************create Managed clauses records*/
                    
                   
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();

                    	PCRM_ManualCloneManagedClause QueableManagedClauseCloneObj = NEW PCRM_ManualCloneManagedClause(ListOfContractAgreementsCreatedFromClone,null,mapOfOldwithNewOpportunityId,objLogger.Id,listOfErrEntities);
                        
                        //62
                        QueableManagedClauseCloneObj.cpuTimeLimit = 22;
                        System.enqueueJob(QueableManagedClauseCloneObj); 
                    
                    system.debug('jjjjiiiipppp: '+ListOfContractAgreementsCreatedFromClone[0].PCRM_isCreatedFromCloning__c);
                    system.assertEquals(true,ListOfContractAgreementsCreatedFromClone[0].PCRM_isCreatedFromCloning__c );
                    
                    test.stopTest();
                    
                }
        
            }
    }
    
     //validating methods from class PCRM_ManualCloneManagedClause when cpu limit is > 80
	static testMethod void validateExecuteWithoutRecurssion() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSH'); //ship to party
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
                    
                       //create cloned test data of contrct agreement by updating field PCRM_ContractAgreement_Cloned_From__c
                      List <APXT_Redlining__Contract_Agreement__c> ListOfContractAgreementsCreatedFromClone = utilityClass.createContractAgreement(ListOfNewOpportunity,'PCRM_Chemicals_Acetyls');
                      
                      Count = 0;
                      //updating PCRM_ContractAgreement_Cloned_From__c with ListOfContractAgreements records
                      for(APXT_Redlining__Contract_Agreement__c clonedContrctAgreemnt : ListOfContractAgreementsCreatedFromClone)
                      {
                          clonedContrctAgreemnt.PCRM_isCreatedFromCloning__c = true;
                          clonedContrctAgreemnt.PCRM_ContractAgreement_Cloned_From__c = ListOfContractAgreements[Count].Id;
                          
                          if(count < ListOfContractAgreements.size() )
                          Count= Count+ 1;      
                      }
                    
                      INSERT  ListOfContractAgreementsCreatedFromClone;
                      system.debug('ListOfContractAgreementsCreatedFromCloneYTetclsss: '+ListOfContractAgreementsCreatedFromClone);
                    
                    
                     /*********************************create Contract Agreements*/
                    
                    
                     /*********************************create Managed clauses records*/
                      List <APXT_Redlining__Managed_Clause__c> ListOfManagedClauses = utilityClass.createManagedClauses(ListOfContractAgreements);
                      INSERT ListOfManagedClauses;
                     /*********************************create Managed clauses records*/
                    
                   
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();

                    	PCRM_ManualCloneManagedClause QueableManagedClauseCloneObj = NEW PCRM_ManualCloneManagedClause(ListOfContractAgreementsCreatedFromClone,null,mapOfOldwithNewOpportunityId,objLogger.Id,listOfErrEntities);
                        QueableManagedClauseCloneObj.cpuTimeLimit = 80;
                        System.enqueueJob(QueableManagedClauseCloneObj); 
                    
                    system.debug('jkhkj: '+ListOfContractAgreementsCreatedFromClone[0].PCRM_isCreatedFromCloning__c);
                    system.assertEquals(true, ListOfContractAgreementsCreatedFromClone[0].PCRM_isCreatedFromCloning__c);
                    
                    test.stopTest();
                    
                }
        
            }
    }
}