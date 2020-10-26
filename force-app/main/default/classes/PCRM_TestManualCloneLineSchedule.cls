/*****************************************************************************************
*   Date:     23/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_ManualCloneLineSchedule
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestManualCloneLineSchedule 
{
	//validating methods from class PCRM_ManualCloneLineSchedule when cpu time limit is > 50
	 static testMethod void validateExecuteWithRecurssion() 
     {
            
            PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        	List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSP'); //sold to party
            insert ListOfAccount;
            
            INTEGER Count = 0;
        	if(ListOfAccount.size() > 0)
        	{
                map<id,id> mapOfOldOpportunityWithNewOpportunity = NEW  map<id,id>();
            	List<opportunity> ListOfOpportunity = utilityClass.createOpportunity(ListOfAccount,10,'PCRM_PetChems_Acetyls');
                INSERT ListOfOpportunity;
                
                //create list of opportunity cloned from above list of opportunity by updating field PCRM_Opportunity_Cloned_From__c
                List<opportunity> ListOfOpportunityCreatedFromCloning = utilityClass.createOpportunity(ListOfAccount,10,'PCRM_PetChems_Acetyls');
                INSERT ListOfOpportunityCreatedFromCloning;
                
                Count = 0;
                ///creating map of old opp id and new opp id ,updating field PCRM_Opportunity_Cloned_From__c
                for(opportunity objOpportunity : ListOfOpportunityCreatedFromCloning)
                {
                    objOpportunity.PCRM_Opportunity_Cloned_From__c = ListOfOpportunity[Count].Id;
                    mapOfOldOpportunityWithNewOpportunity.put(ListOfOpportunity[Count].Id,objOpportunity.Id);

                    Count = Count+ 1;
                    
                }
                UPDATE ListOfOpportunityCreatedFromCloning;
                
                
                List<Product2> ListProducts = utilityClass.createProducts(3);
              
                if(ListOfOpportunity.size() > 0)
                {
                     /*********************************create opp products*/
                    List<opportunityLineItem> ListOfOpportunityLineItem = utilityClass.createOpportunityProducts(ListOfOpportunity, ListProducts);
                    INSERT ListOfOpportunityLineItem;
                    
                    
                    //create list of opportunity cloned from above list of opportunity by updating field PCRM_Opportunity_Cloned_From__c
                    List<opportunityLineItem> ListOfLineItemCreatedFromClone = utilityClass.createOpportunityProducts(ListOfOpportunity, ListProducts);
                    Count = 0 ;
                    for(opportunityLineItem lineItemObj : ListOfLineItemCreatedFromClone)
                    {
                        lineItemObj.PCRM_OpportunityLineItem_Cloned_From__c = ListOfOpportunityLineItem[Count].Id;
                        Count = Count+ 1;
                    }
                    
                    INSERT ListOfLineItemCreatedFromClone;
                    
                    
                     /*********************************create opp products*/
                    
                  
                    PCRM_Logger__c objLogger = NEW PCRM_Logger__c();
                    INSERT objLogger ;
                    
                    
                    /*********************************create opp line schedule*/
                    List <OpportunityLineItemSchedule> ListOfOpportunityLineItemItemSchedule = utilityClass.createOpportunityLineSchedule(ListOfOpportunityLineItem);
                    INSERT ListOfOpportunityLineItemItemSchedule;
                     /*********************************create opp line schedule*/
                    
                     
                    //queable jobs for opportunityLineitem schedule
                    // //with cpu time limit > 50
                    List<string> listErrEntities = NEW 	 List<string>();
                    PCRM_ManualCloneOpportunityLineSchedule objCloneOpportunityLineSchedule = new PCRM_ManualCloneOpportunityLineSchedule(ListOfLineItemCreatedFromClone,null,mapOfOldOpportunityWithNewOpportunity,objLogger.Id,listErrEntities);
                    
                    //50
                    objCloneOpportunityLineSchedule.cpuTimeLimit = 20;
                    test.startTest();
                    
                    System.enqueueJob(objCloneOpportunityLineSchedule); 
                    
                    system.debug('ListOfLineItemCreatedFromClone.size()888: '+ListOfLineItemCreatedFromClone.size());
                    system.assertEquals(30, ListOfLineItemCreatedFromClone.size());
                    test.stopTest();
                    
                    /***********************************opportunity with type*/
                    
                }
          
        }
     }
    
    
     //validating methods from class PCRM_ManualCloneLineSchedule when cpu limit is > 80
	 static testMethod void validateExecuteWithoutRecurssion() 
     {
            PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        	List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSP'); //sold to party
            insert ListOfAccount;
            
            INTEGER Count = 0;
        	if(ListOfAccount.size() > 0)
        	{
                map<id,id> mapOfOldOpportunityWithNewOpportunity = NEW  map<id,id>();
            	List<opportunity> ListOfOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                INSERT ListOfOpportunity;
                
                //create list of opportunity cloned from above list of opportunity by updating field PCRM_Opportunity_Cloned_From__c
                List<opportunity> ListOfOpportunityCreatedFromCloning = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                INSERT ListOfOpportunityCreatedFromCloning;
                
                Count = 0;
                ///creating map of old opp id and new opp id ,updating field PCRM_Opportunity_Cloned_From__c
                for(opportunity objOpportunity : ListOfOpportunityCreatedFromCloning)
                {
                    objOpportunity.PCRM_Opportunity_Cloned_From__c = ListOfOpportunity[Count].Id;
                    mapOfOldOpportunityWithNewOpportunity.put(ListOfOpportunity[Count].Id,objOpportunity.Id);

                    Count = Count+ 1;
                    
                }
                UPDATE ListOfOpportunityCreatedFromCloning;
                
                
                
                List<Product2> ListProducts = utilityClass.createProducts(3);
              
                if(ListOfOpportunity.size() > 0)
                {
                    
                     /*********************************create opp products*/
                    /*List<opportunity> ListofOpportunity2 = new List<opportunity>();
                    ListofOpportunity2.add(ListOfOpportunity[0]);*/
                    
                    List<opportunityLineItem> ListOfOpportunityLineItem = utilityClass.createOpportunityProducts(ListOfOpportunity, ListProducts);
                    INSERT ListOfOpportunityLineItem;
                    
                    
                    //create list of opportunity cloned from above list of opportunity by updating field PCRM_Opportunity_Cloned_From__c
                    List<opportunityLineItem> ListOfLineItemCreatedFromClone = utilityClass.createOpportunityProducts(ListOfOpportunity, ListProducts);
                    Count = 0 ;
                    for(opportunityLineItem lineItemObj : ListOfLineItemCreatedFromClone)
                    {
                        lineItemObj.PCRM_OpportunityLineItem_Cloned_From__c = ListOfOpportunityLineItem[Count].Id;
                        Count = Count+ 1;
                    }
                    
                    INSERT ListOfLineItemCreatedFromClone;
                    
                    
                     /*********************************create opp products*/
                    
                  
                    PCRM_Logger__c objLogger = NEW PCRM_Logger__c();
                    INSERT objLogger ;
                    
                    
                    /*********************************create opp line schedule*/
                    List <OpportunityLineItemSchedule> ListOfOpportunityLineItemItemSchedule = utilityClass.createOpportunityLineSchedule(ListOfOpportunityLineItem);
                    INSERT ListOfOpportunityLineItemItemSchedule;
                     /*********************************create opp line schedule*/
                    
                    
                     
                    //queable jobs for opportunityLineitem schedule
                    // //with cpu time limit > 50
                    List<string> listErrEntities = NEW 	 List<string>();
                    PCRM_ManualCloneOpportunityLineSchedule objCloneOpportunityLineSchedule = new PCRM_ManualCloneOpportunityLineSchedule(ListOfLineItemCreatedFromClone,null,mapOfOldOpportunityWithNewOpportunity,objLogger.Id,listErrEntities);
                    objCloneOpportunityLineSchedule.cpuTimeLimit = 80;
                    
                    test.startTest();
                    
                       System.enqueueJob(objCloneOpportunityLineSchedule); 
                   
                    system.debug('ListOfLineItemCreatedFromClone.size()999: '+ListOfLineItemCreatedFromClone.size());
                    system.assertEquals(6, ListOfLineItemCreatedFromClone.size());

                    test.stopTest();
                    
                     /***********************************opportunity with type*/
                    
                }
          
        }
     }
    
    
}