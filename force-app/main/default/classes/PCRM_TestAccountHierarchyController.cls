/*****************************************************************************************
*   Date:     24/05/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_TestAccountHierarchyController
*   Changes: 0.1 
 
****************************************************************************************/
@isTest
public with sharing class PCRM_TestAccountHierarchyController
{

     //Test method to cover PCRM_AccountHierarchyController
    static testMethod void testPCRM_AccountHierarchyController(){       
        
        Test.startTest();     
            List<Account> ListOfShipToAccountWithParent = NEW List<Account>();
            List<Account> lstCGToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'ZMHI'); // customer group to account                   
            insert lstCGToAccounts; 			
            ListOfShipToAccountWithParent.addAll(lstCGToAccounts);
            
            List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(2, 'Customer', 'ZMSP'); // sold to account
            lstSoldToAccounts[0].parentId = lstCGToAccounts[0].Id;
            lstSoldToAccounts[1].parentId = lstCGToAccounts[0].Id;
            insert lstSoldToAccounts;
            ListOfShipToAccountWithParent.addAll(lstSoldToAccounts);
            
            List<Account> lstShipToAccounts = new PCRM_Utility().createAccount(2, 'Customer', 'ZMSH'); //ship to account
            lstShipToAccounts[0].parentId = lstSoldToAccounts[0].Id;
            insert lstShipToAccounts;
            ListOfShipToAccountWithParent.addAll(lstShipToAccounts); 
            
            List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstCGToAccounts, 1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity;           
            
            Id opportunityAccountRecordTypeId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByDeveloperName().get('PCRM_Opportunity_Account').getRecordTypeId();
            
            PCRM_Opportunity_Account__c objOpportunityAccount = new PCRM_Opportunity_Account__c();
            objOpportunityAccount.Name = 'Testoppacc22345' ;
            objOpportunityAccount.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount.PCRM_Opportunity__c = lstOpportunity[0].Id;
            objOpportunityAccount.PCRM_Account__c = lstSoldToAccounts[0].Id;             
            insert objOpportunityAccount;
            
            
            PCRM_Opportunity_Account__c objOpportunityAccount2 = new PCRM_Opportunity_Account__c();
            objOpportunityAccount2.Name = 'Testoppacc223457' ;
            objOpportunityAccount2.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount2.PCRM_Opportunity__c = lstOpportunity[0].Id;
            objOpportunityAccount2.PCRM_Account__c = lstShipToAccounts[0].Id;             
            insert objOpportunityAccount2;
            
            PCRM_AccountHierarchyController.getParentAccount(lstOpportunity[0].Id);
            PCRM_AccountHierarchyController.findHierarchyData(lstOpportunity[0].Accountid);
            PCRM_AccountHierarchyController.createDeleteOpportunityAccounts(lstOpportunity[0].Id,ListOfShipToAccountWithParent);
            PCRM_AccountHierarchyController.getOpportunityRelatedAccounts(lstOpportunity[0].Id,ListOfShipToAccountWithParent[0].Id);
            PCRM_AccountHierarchyController.findPicklistOptions('Account','Type'); 
        
        	system.assertEquals(lstOpportunity[0].accountId,lstCGToAccounts[0].id );
        Test.stopTest();
    }    
}