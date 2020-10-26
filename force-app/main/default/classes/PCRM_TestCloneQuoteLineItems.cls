/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_CloneQuoteLineItems
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestCloneQuoteLineItems 
{
     @testSetup static void setup()
     {
        /*Profile p = [SELECT Id FROM Profile WHERE name LIKE '%System Administrator%' Limit 1];
       
        User u = new User(Alias = 'standt', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='testpermissionsetuser8@testorg.com');
        insert u;*/
       
        // Create PermissionSet with Custom Permission and assign to test user
       /* PermissionSet ps = new PermissionSet();
        ps.Name = 'Test2';
        ps.Label = 'Test1';
        insert ps;
         
        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'BPG_DisableAll'][0].Id;
        insert sea;
         
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa; */
         
      //  Boolean hasPermission = FeatureManagement.checkPermission('BPG_DisableAll');
         
     }
    
    //validating methods from class PCRM_CloneQuotes 
	static testMethod void validateExecuteWithoutRecurssion() 
    {
        //User UserWithBPGPermissionSet = [select Id from User WHERE  UserName ='testpermissionsetuser8@testorg.com'];
       
        //Run your code with inserted user.
       // System.runAs(UserWithBPGPermissionSet)
        {
            /*Boolean hasPermission = FeatureManagement.checkPermission('BPG_DisableAll');
            system.debug('hasPermission1: '+hasPermission);*/
            
            test.startTest();
            PCRM_Utility utilityClass = NEW PCRM_Utility();
             
            List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSH'); //ship to party
            insert ListOfAccount;
            
            List<Product2> ListOfProducts = utilityClass.createProducts(2); //ship to party
            
            if(ListOfAccount.size() > 0)
                {
                    List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                    for(opportunity objOpp : ListOfNewOpportunity)
                    {
                        objOpp.type = 'PCRM_Spot';
                    }
                	INSERT ListOfNewOpportunity;
                
                    //no opp line item = ListOfNewOpportunity*ListOfProducts;
                    //8 * 4 = 32
                    List<opportunityLineItem> ListOfOpportunityLineItem =utilityClass.createOpportunityProducts(ListOfNewOpportunity, ListOfProducts);
                    INSERT ListOfOpportunityLineItem;
                    
                    
                    
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
                        
                          //no of quotes = ListOfNewOpportunity;
                          //8
                          List <Quote> ListOfQuotes = utilityClass.createQuote(ListOfNewOpportunity,'PCRM_Quote');
                          for(Quote q: ListOfQuotes)
                          {
                             //q.PCRM_Quote_Cloned_From__c = '';
                             q.Status = 'Presented'; 
                          }
                        
                          system.debug('ListOfQuotesSize: '+ListOfQuotes.size());
                          INSERT ListOfQuotes;
                        
                          count = 0;
                          //creating list of records which got created by cloning by updating custom field PCRM_Quote_Cloned_From__c
                          List <Quote> ListOfNewQuotes = NEW  List <Quote>();
                          ListOfNewQuotes = utilityClass.createQuote(ListOfNewOpportunity,'PCRM_Quote');
                          for(Quote q: ListOfNewQuotes)
                          {
                             q.PCRM_Quote_Cloned_From__c = ListOfQuotes[count].Id;
                             q.Status = 'Presented'; 
                              
                             count = count + 1; 
                          }
                        
                          system.debug('ListOfNewQuotesSize: '+ListOfNewQuotes.size() );
                          INSERT ListOfNewQuotes;
                        
                         /*********************************create Quote records*/
                      
                        
                         /*********************************create Quote Line records*/
                          {
                            //number of QLI = ListOfQuotes* ListOfProducts
                            // 30 * 2 
                           	List <QuoteLineItem> ListOfQuotesLines = utilityClass.createQuoteLines(ListOfQuotes,ListOfProducts);
                           	system.debug('ListOfQuotesLinesSize: '+ListOfQuotesLines.size());
                            INSERT ListOfQuotesLines;
                          }
                         /*********************************create Quote Line records*/
                        
                        
                        List<string> listOfErrEntities = NEW List<string> ();
                        
                        PCRM_CloneQuoteLineItems QueableQuoteLinesCloneObj = NEW PCRM_CloneQuoteLineItems(mapOfOldwithNewOpportunityId,ListOfNewQuotes,null,null,false,objLogger.Id,listOfErrEntities);
                        QueableQuoteLinesCloneObj.cpuTimeLimit = 90;
                        System.enqueueJob(QueableQuoteLinesCloneObj); 
                        
                        test.stopTest();
                        
                    }
        
            }
        }
    }
    //validating methods from class PCRM_CloneQuotes 
	static testMethod void validateExecuteWithRecurssion() 
    {
        //User UserWithBPGPermissionSet = [select Id from User WHERE  UserName ='testpermissionsetuser8@testorg.com'];
       
        //Run your code with inserted user.
       // System.runAs(UserWithBPGPermissionSet)
        {
            /*Boolean hasPermission = FeatureManagement.checkPermission('BPG_DisableAll');
            system.debug('hasPermission1: '+hasPermission);*/
            
            test.startTest();
            PCRM_Utility utilityClass = NEW PCRM_Utility();
             
            List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSH'); //ship to party
            insert ListOfAccount;
            
            List<Product2> ListOfProducts = utilityClass.createProducts(2); //ship to party
            
            if(ListOfAccount.size() > 0)
                {
                    List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,20,'PCRM_PetChems_Acetyls');
                    for(opportunity objOpp : ListOfNewOpportunity)
                    {
                        objOpp.type = 'PCRM_Spot';
                    }
                	INSERT ListOfNewOpportunity;
                
                    //no opp line item = ListOfNewOpportunity*ListOfProducts;
                    //8 * 4 = 32
                    List<opportunityLineItem> ListOfOpportunityLineItem =utilityClass.createOpportunityProducts(ListOfNewOpportunity, ListOfProducts);
                    INSERT ListOfOpportunityLineItem;
                    
                    
                    
                    List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,20,'PCRM_PetChems_Acetyls');
                    
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
                        
                          //no of quotes = ListOfNewOpportunity;
                          //8
                          List <Quote> ListOfQuotes = utilityClass.createQuote(ListOfNewOpportunity,'PCRM_Quote');
                          for(Quote q: ListOfQuotes)
                          {
                             //q.PCRM_Quote_Cloned_From__c = '';
                             q.Status = 'Presented'; 
                          }
                        
                          system.debug('ListOfQuotesSize: '+ListOfQuotes.size());
                          INSERT ListOfQuotes;
                        
                          count = 0;
                          //creating list of records which got created by cloning by updating custom field PCRM_Quote_Cloned_From__c
                          List <Quote> ListOfNewQuotes = NEW  List <Quote>();
                          ListOfNewQuotes = utilityClass.createQuote(ListOfNewOpportunity,'PCRM_Quote');
                          for(Quote q: ListOfNewQuotes)
                          {
                             q.PCRM_Quote_Cloned_From__c = ListOfQuotes[count].Id;
                             q.Status = 'Presented'; 
                              
                             count = count + 1; 
                          }
                        
                          system.debug('ListOfNewQuotesSize: '+ListOfNewQuotes.size() );
                          INSERT ListOfNewQuotes;
                        
                         /*********************************create Quote records*/
                      
                        
                         /*********************************create Quote Line records*/
                          {
                            //number of QLI = ListOfQuotes* ListOfProducts
                            // 30 * 2 
                           	List <QuoteLineItem> ListOfQuotesLines = utilityClass.createQuoteLines(ListOfQuotes,ListOfProducts);
                           	system.debug('ListOfQuotesLinesSize: '+ListOfQuotesLines.size());
                            INSERT ListOfQuotesLines;
                          }
                         /*********************************create Quote Line records*/
                        
                        
                        List<string> listOfErrEntities = NEW List<string> ();
                        
                        PCRM_CloneQuoteLineItems QueableQuoteLinesCloneObj = NEW PCRM_CloneQuoteLineItems(mapOfOldwithNewOpportunityId,ListOfNewQuotes,null,null,false,objLogger.Id,listOfErrEntities);
                        
                        //48
                        QueableQuoteLinesCloneObj.cpuTimeLimit = 18;
                        System.enqueueJob(QueableQuoteLinesCloneObj); 
                        
                        test.stopTest();
                        
                    }
        
            }
        }
    }
    
    
    
   
}