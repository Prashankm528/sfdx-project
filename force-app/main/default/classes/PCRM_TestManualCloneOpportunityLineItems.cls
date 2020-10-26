/*****************************************************************************************
*   Date:     23/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_ManualCloneOpportunityLineItems
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestManualCloneOpportunityLineItems
{
	//validating methods from class PCRM_ManualCloneOpportunityLineItems 
	 static testMethod void validateExecute() 
     {
           
            PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        	List<Account> ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSP'); //sold to party
            insert ListOfAccount;
            
            INTEGER Count = 0;
        	if(ListOfAccount.size() > 0)
        	{
                //30
            	List<opportunity> ListOfOpportunity = utilityClass.createOpportunity(ListOfAccount,25,'PCRM_PetChems_Acetyls');
                INSERT ListOfOpportunity;
                
                //30
                //create list of opportunity cloned from above list of opportunity by updating field PCRM_Opportunity_Cloned_From__c
                List<opportunity> ListOfOpportunityCreatedFromCloning = utilityClass.createOpportunity(ListOfAccount,25,'PCRM_PetChems_Acetyls');
                for(opportunity objOpportunity : ListOfOpportunityCreatedFromCloning)
                {
                    objOpportunity.PCRM_Opportunity_Cloned_From__c = ListOfOpportunity[Count].Id;
                    Count = Count+ 1;
                }
                INSERT ListOfOpportunityCreatedFromCloning;
                
                List<Product2> ListProducts = utilityClass.createProducts(3);
              
                if(ListOfOpportunity.size() > 0)
                {
                    
                     /*********************************create opp products*/
                   
                    List<opportunityLineItem> ListOfOpportunityLineItem =utilityClass.createOpportunityProducts(ListOfOpportunity, ListProducts);
                    INSERT ListOfOpportunityLineItem;
                    
                    system.debug('ListOfOpportunityLineItem999: '+ListOfOpportunityLineItem);
                    
                     /*********************************create opp products*/
                    
                    PCRM_Logger__c objLogger = NEW PCRM_Logger__c();
                    INSERT objLogger ;
                    
                    test.startTest();
                    
                    List<string> listErrEntities = NEW 	 List<string>();
                    PCRM_ManualCloneOpportunityLineItems.execute(ListOfOpportunityCreatedFromCloning,null,objLogger.Id,listErrEntities);
                    
                    system.assertEquals(25, ListOfOpportunity.size());
                    
                    test.stopTest();
                     /***********************************opportunity with type*/
                    
                }
          
        }
     }
}