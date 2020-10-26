/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_CloneOpportunityAccounts
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestCloneOpportunityAccounts 
{
      @testSetup static void setup()
     {
        Profile p = [SELECT Id FROM Profile WHERE name LIKE '%System Administrator%' Limit 1];
       
        User u = new User(Alias = 'standt', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='testpermissionsetuser8@testorg.com');
        insert u;
         
     }
    
    
//validating methods from class CloneOpportunityAccounts 
	static testMethod void validateExecuteViaManualClone() 
    {
        User userObject = [SELECT ID ,email FROM USER WHERE USERNAME = 'testpermissionsetuser8@testorg.com'];
        
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(15, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                for(opportunity oldOpportunity : ListOfNewOpportunity)
                {
                     oldOpportunity.OwnerId = userObject.Id;
                }
                INSERT ListOfNewOpportunity;
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                
                Integer count = 0;
                //update opportunity as they are created from cloning
                for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
                {
                    cloneOpportunity.PCRM_isCreatedFromCloning__c = true;
                    cloneOpportunity.OwnerId = userObject.Id;
                    //cloneOpportunity.OwnerId.email = userObject.email;
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
                      /*********************************create Opportunity Accounts records*/
                      List <PCRM_Opportunity_Account__c> ListOfOpportunityAccounts = utilityClass.createOpportunityAccount(15,'PCRM_Opportunity_Account',ListOfNewOpportunity[0].Id,ListOfAccount);
                      INSERT ListOfOpportunityAccounts;
                     /*********************************create Opportunity Accounts records*/
                
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();

                    PCRM_CloneOpportunityAccounts QueableOpportunityAccountCloneObj = NEW PCRM_CloneOpportunityAccounts(mapOfOldwithNewOpportunityId,null,null,false,objLogger.Id,listOfErrEntities);
                    
                    //75,66
                    QueableOpportunityAccountCloneObj.cpuTimeLimit = 20;
                    System.enqueueJob(QueableOpportunityAccountCloneObj); 
                    
                    system.debug('jjj: '+ ListOfOpportunityAccounts[0].PCRM_Opportunity__c);
                    system.assertEquals(ListOfNewOpportunity[0].Id, ListOfOpportunityAccounts[0].PCRM_Opportunity__c);
                    
                    test.stopTest();
                    
                }
        
            }
    }
  
    
//validating methods from class CloneOpportunityAccounts     
   static testMethod void validateExecuteViaScheduelClone() 
   {  
        User userObject = [SELECT ID ,email FROM USER WHERE USERNAME = 'testpermissionsetuser8@testorg.com'];

        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(2, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        if(ListOfAccount.size() > 0)
        	{
            	List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                for(opportunity oldOpportunity : ListOfNewOpportunity)
                {
                     oldOpportunity.OwnerId = userObject.Id;
                }
                INSERT ListOfNewOpportunity;
                
                
                List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                
                Integer count = 0;
                //update opportunity as they are created from cloning
                for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
                {
                    cloneOpportunity.PCRM_isCreatedFromCloning__c = true;
                     cloneOpportunity.OwnerId = userObject.Id;
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
                      //////////////create Opportunity Accounts records
                      List <PCRM_Opportunity_Account__c> ListOfOpportunityAccounts = utilityClass.createOpportunityAccount(2,'PCRM_Opportunity_Account',ListOfNewOpportunity[0].Id,ListOfAccount);
                      INSERT ListOfOpportunityAccounts;
                     ////////////////////////////create Opportunity Accounts records
                
                   
                    test.startTest();
                        List<string> listOfErrEntities = NEW List<string> ();

                    PCRM_CloneOpportunityAccounts QueableOpportunityAccountCloneObj = NEW PCRM_CloneOpportunityAccounts(mapOfOldwithNewOpportunityId,null,null,true,objLogger.Id,listOfErrEntities);
                        System.enqueueJob(QueableOpportunityAccountCloneObj); 
                        QueableOpportunityAccountCloneObj.cpuTimeLimit = 80;
                    
                    system.debug('kkk: '+ ListOfOpportunityAccounts[0].PCRM_Opportunity__c);
                    system.debug('ListOfNewOpportunity[0].Id:'+ListOfNewOpportunity[0].Id);
                    
                    system.assertEquals(ListOfNewOpportunity[0].Id, ListOfOpportunityAccounts[0].PCRM_Opportunity__c);
                    
                    test.stopTest();
                    
                }
        
            }
   } 
    
    
}