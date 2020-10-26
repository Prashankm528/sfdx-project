/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_CloneQuotes
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestCloneQuotes 
{
//validating methods from class PCRM_CloneQuotes 
	static testMethod void validateExecuteWithRecurssion() 
    {
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(2, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,10,'PCRM_PetChems_Acetyls');
                INSERT ListOfNewOpportunity;
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,10,'PCRM_PetChems_Acetyls');
                
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
                      /*********************************create Quote records*/
                      List <Quote> ListOfQuotes = utilityClass.createQuote(ListOfNewOpportunity,'PCRM_Quote');
                      for(Quote q: ListOfQuotes)
                      {
                         q.Status = 'Presented'; 
                      }
                    
                      INSERT ListOfQuotes;
                     /*********************************create Quote records*/
                
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();

                    PCRM_CloneQuotes QueableQuoteCloneObj = NEW PCRM_CloneQuotes(mapOfOldwithNewOpportunityId,null,null,false,objLogger.Id,listOfErrEntities);
                    //55
                    QueableQuoteCloneObj.cpuTimeLimit = 25;
                    System.enqueueJob(QueableQuoteCloneObj); 
                    
                    system.debug('kk88: '+ListOfQuotes[0].Status);
                    system.assertEquals('Presented', ListOfQuotes[0].Status);
                    
                    test.stopTest();
                    
                }
        
            }
    }
  
    //validating methods from class PCRM_CloneQuotes 
	static testMethod void validateExecuteWithoutRecurssion() 
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
                      /*********************************create Quote records*/
                      List <Quote> ListOfQuotes = utilityClass.createQuote(ListOfNewOpportunity,'PCRM_Quote');
                      for(Quote q: ListOfQuotes)
                      {
                         q.Status = 'Presented'; 
                      }
                    
                      INSERT ListOfQuotes;
                     /*********************************create Quote records*/
                
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();

                    PCRM_CloneQuotes QueableQuoteCloneObj = NEW PCRM_CloneQuotes(mapOfOldwithNewOpportunityId,null,null,false,objLogger.Id,listOfErrEntities);
                    QueableQuoteCloneObj.cpuTimeLimit = 50;
                    System.enqueueJob(QueableQuoteCloneObj); 
                    
                    system.debug('kk00: '+ListOfQuotes[0].Status);
                    system.assertEquals('Presented', ListOfQuotes[0].Status);
                    
                    test.stopTest();
                    
                }
        
            }
    }
    

    
    
}