/*****************************************************************************************
*   Date:     18/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_InitiateCloningController
*   Changes: 0.1 
*	Date :	9/24/2020
*	Author :Pooja Deokar(TCS)
*	Description : added the manual clonning code coverage. 
 
****************************************************************************************/
@isTest
public with sharing class PCRM_TestInitiateCloningController 
{
    //Test data setup
    @testSetup static void setup() {         
         	PCRM_Utility utilityClass = NEW PCRM_Utility();
        
	        List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'ZMSP'); // sold to account
            insert lstSoldToAccounts;
                       
            List<Product2> lstProducts = new PCRM_Utility().createProducts(2);
        
       		List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts, 1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity;
            Id opportunityAccountRecordTypeId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByDeveloperName().get('PCRM_Opportunity_Account').getRecordTypeId();

        	PCRM_Opportunity_Account__c objOpportunityAccount = new PCRM_Opportunity_Account__c();
       		objOpportunityAccount.Name = 'Testoppacc22345' ;
        	objOpportunityAccount.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount.PCRM_Opportunity__c = lstOpportunity[0].Id;
            objOpportunityAccount.PCRM_Account__c = lstSoldToAccounts[0].Id;          	
            insert objOpportunityAccount;
        
        	List<PricebookEntry> lstPricebookEntryId = [select Id from PricebookEntry limit 10];
             
            List<OpportunityLineItem> lstOpportunityLineItem = new PCRM_Utility().createOpportunityProducts(lstOpportunity, lstProducts);
            lstOpportunityLineItem[0].PricebookEntryId = lstPricebookEntryId[0].Id;
        	insert lstOpportunityLineItem;           
        	
            List <OpportunityLineItemSchedule> ListOfOpportunityLineItemItemSchedule = utilityClass.createOpportunityLineSchedule(lstOpportunityLineItem);
            INSERT ListOfOpportunityLineItemItemSchedule;
        
        	List <APXT_Redlining__Contract_Agreement__c> ListOfContractAgreements = utilityClass.createContractAgreement(lstOpportunity,'PCRM_Chemicals_Acetyls');
            INSERT ListOfContractAgreements;
        
         	List <APXT_Redlining__Managed_Clause__c> ListOfManagedClauses = utilityClass.createManagedClauses(ListOfContractAgreements);
         	INSERT ListOfManagedClauses;
    }
    //validating methods from class InitiateCloningController 
	 static testMethod void validateExecuteManualClone1() 
     {
         test.startTest();
         	List<Opportunity> ListOfOpportunity = [Select id,CloseDate,recordTypeId,Type,PCRM_Start_Date__c,PCRM_End_Date__c
                                                   From Opportunity ];
        	 PCRM_InitiateCloningController.initiateCloning(ListOfOpportunity[0].Id);         	
         	system.assertEquals(ListOfOpportunity.size(), 1);
         test.stopTest();
     }
}