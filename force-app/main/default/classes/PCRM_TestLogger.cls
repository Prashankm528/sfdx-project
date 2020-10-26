/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_Logger
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestLogger
{
   //validating methods from class CloneOpportunityAccounts     
   static testMethod void validateLog() 
   {
       PCRM_Logger__c objparentLogger = new PCRM_Logger__c();
       INSERT objparentLogger;
       List<string> lstSuccessId = NEW List<string>();
       
       
       PCRM_Utility objUtility = NEW PCRM_Utility();
       
       List<Account> accounts = objUtility.createAccount(2, 'Customer', 'ZMSH');
       INSERT accounts;
       
       List<Opportunity> opportunities =  objUtility.createOpportunity(accounts,2, 'PCRM_PetChems_Acetyls');
       INSERT opportunities;
       
        ///////////////////////////////d////////////////////////////
       List<APXT_Redlining__Contract_Agreement__c> contractAgreementRecords = objUtility.createContractAgreement(opportunities,'PCRM_Chemicals_Acetyls');
       INSERT contractAgreementRecords;
       
       List<APXT_Redlining__Managed_Clause__c>  managedClauses = objUtility.createManagedClauses(contractAgreementRecords);
       INSERT managedClauses;
       
       List<Product2>  Products = objUtility.createProducts(2);
       //INSERT Products;
       
       List<OpportunityLineItem>  opportunityProducts = objUtility.createOpportunityProducts(opportunities,Products);
       INSERT opportunityProducts;
       
       List<Contact>  contacts = objUtility.createContact(2, 'PCRM_Petchem_Contact');
       INSERT contacts;
       
       
       List<OpportunityContactRole> opportunityContactRoles = objUtility.createOpportunityContactRole(opportunities[0],contacts);
       INSERT opportunityContactRoles;
       
       
       List<PCRM_Opportunity_Account__c> opportunityAccounts = objUtility.createOpportunityAccount(2, 'PCRM_Opportunity_Account',opportunities[0].Id,accounts);
       INSERT opportunityAccounts;
       
       List<OpportunityLineItemSchedule> lineItemSchedules = objUtility.createOpportunityLineSchedule(opportunityProducts);
       INSERT lineItemSchedules;
       
    ///////////////////////////////d////////////////////////////
       
       map<string,string> IdsTobeCloneWithOlOpportunityId = NEW map<string,string>();
       
     //(String strException,List<string>SuccessIDs,map<string,string>IdsTobeCloneWithOlOpportunityId, String strObjectName,string clonefromFieldName, string cloneType,Id ParentLogId)
     	
       PCRM_Logger objLogger = NEW PCRM_Logger();
          
       
       lstSuccessId = NEW List<string>();
       lstSuccessId.add('\''+managedClauses[0].Id+ '\'');
       objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'APXT_Redlining__Managed_Clause__c','PCRM_Managed_Clause_Cloned_From__c','Scheduled',objparentLogger.Id);
       
       
      //PCRM_Logger objLogger2 = NEW PCRM_Logger();
      lstSuccessId = NEW List<string>();
      lstSuccessId.add('\''+contractAgreementRecords[0].Id+ '\'');
      objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'APXT_Redlining__Contract_Agreement__c','PCRM_ContractAgreement_Cloned_From__c','Scheduled',objparentLogger.Id);

       
      //PCRM_Logger objLogger3 = NEW PCRM_Logger();
      lstSuccessId = NEW List<string>();
      lstSuccessId.add('\''+opportunityAccounts[0].Id+ '\'');  
      objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'PCRM_Opportunity_Account__c','PCRM_Opportunity_Account_Cloned_From__c','Scheduled',objparentLogger.Id);

       
      lstSuccessId = NEW List<string>();
      lstSuccessId.add('\''+opportunityContactRoles[0].Id+ '\'');    
      objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'OpportunityContactRole','PCRM_OpportunityContactRole_Cloned_From__c','Scheduled',objparentLogger.Id);
      
     
      lstSuccessId = NEW List<string>();
      lstSuccessId.add('\''+opportunities[0].Id+ '\'');    
      objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'Opportunity','PCRM_Opportunity_Cloned_From__c','Scheduled',objparentLogger.Id); 
       
       
      lstSuccessId = NEW List<string>();
      lstSuccessId.add('\''+lineItemSchedules[0].Id+ '\'');    
      objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'OpportunityLineItemSchedule','PCRM_LineItemSchedule_Cloned_From__c','Scheduled',objparentLogger.Id); 
        
       
      lstSuccessId = NEW List<string>();
      lstSuccessId.add('\''+opportunityProducts[0].Id+ '\'');    
      objLogger.log('strException',lstSuccessId,IdsTobeCloneWithOlOpportunityId,'OpportunityLineItem','PCRM_OpportunityLineItem_Cloned_From__c','Scheduled',objparentLogger.Id); 
         
      system.assertEquals(true, lstSuccessId.contains('\''+opportunityProducts[0].Id+ '\'')) ;

   }
 
   
}