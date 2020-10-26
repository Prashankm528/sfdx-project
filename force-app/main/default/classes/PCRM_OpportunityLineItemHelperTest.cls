/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Pooja Deokar (TCS)  
*   Description:   Test Class for Class PCRM_OpportunityAccount_Trigger,PCRM_opportunityLineItemTrigger,
					PCRM_OpportunityLineItemHelper,PCRM_OpportunityLineItemHandler,PCRM_OpportunityAccountHandler  				
*   Changes: 0.1 
 
****************************************************************************************/
@isTest
public with sharing class PCRM_OpportunityLineItemHelperTest{
	//Test data setup
    @testSetup static void setup() {         
        
	        List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'ZMSP'); // sold to account
            insert lstSoldToAccounts;
            
            List<Account> lstShipToAccounts = new PCRM_Utility().createAccount(2, 'Customer', 'ZMSH'); //ship to account
            lstShipToAccounts[0].parentId = lstSoldToAccounts[0].Id;
            insert lstShipToAccounts;
             
            List<Product2> lstProducts = new PCRM_Utility().createProducts(2);
        
       		List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts, 1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity;
       		
            List<Opportunity> lstOpportunity1 = new PCRM_Utility().createOpportunity(lstShipToAccounts, 1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity1;
        	 Id opportunityAccountRecordTypeId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByDeveloperName().get('PCRM_Opportunity_Account').getRecordTypeId();

        
        	PCRM_Opportunity_Account__c objOpportunityAccount = new PCRM_Opportunity_Account__c();
       		objOpportunityAccount.Name = 'Testoppacc22345' ;
        	objOpportunityAccount.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount.PCRM_Opportunity__c = lstOpportunity[0].Id;
            objOpportunityAccount.PCRM_Account__c = lstSoldToAccounts[0].Id;   
        	
            insert objOpportunityAccount;
        
       		PCRM_Opportunity_Account__c objOpportunityAccount1 = new PCRM_Opportunity_Account__c();
       		objOpportunityAccount1.Name = 'Testoppacc223456' ;
        	objOpportunityAccount1.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount1.PCRM_Opportunity__c = lstOpportunity1[0].Id;
            objOpportunityAccount1.PCRM_Account__c = lstShipToAccounts[0].Id;             
            insert objOpportunityAccount1;
        
       		PCRM_Opportunity_Account__c objOpportunityAccount2 = new PCRM_Opportunity_Account__c();
       		objOpportunityAccount2.Name = 'Testoppacc223457' ;
        	objOpportunityAccount2.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount2.PCRM_Opportunity__c = lstOpportunity[0].Id;
            objOpportunityAccount2.PCRM_Account__c = lstShipToAccounts[0].Id;             
            insert objOpportunityAccount2;
        
      		PCRM_Opportunity_Account__c objOpportunityAccount3 = new PCRM_Opportunity_Account__c();
       		objOpportunityAccount3.Name = 'Testoppacc223457' ;
        	objOpportunityAccount3.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount3.PCRM_Opportunity__c = lstOpportunity1[0].Id;
            objOpportunityAccount3.PCRM_Account__c = lstSoldToAccounts[0].Id;             
            insert objOpportunityAccount3;
        	
        	List<PricebookEntry> lstPricebookEntryId = [select Id from PricebookEntry limit 10];
             
            List<OpportunityLineItem> lstOpportunityLineItem = new PCRM_Utility().createOpportunityProducts(lstOpportunity, lstProducts);
            lstOpportunityLineItem[0].PricebookEntryId = lstPricebookEntryId[0].Id;
        	lstOpportunityLineItem[0].PCRM_Ship_To__c = lstShipToAccounts[0].id;
        	lstOpportunityLineItem[0].PCRM_Sold_To__c = lstSoldToAccounts[0].id;
            insert lstOpportunityLineItem;      
           
        	List<OpportunityLineItem> lstOpportunityLineItem1 = new PCRM_Utility().createOpportunityProducts(lstOpportunity1, lstProducts);
            lstOpportunityLineItem1[0].PricebookEntryId = lstPricebookEntryId[0].Id;
        	lstOpportunityLineItem1[0].PCRM_Ship_To__c = lstShipToAccounts[0].id;
        	lstOpportunityLineItem1[0].PCRM_Sold_To__c = lstSoldToAccounts[0].id;
           insert lstOpportunityLineItem1;      
    }
    
     //Test method to cover PCRM_OpportunityLineItemHelper
    static testMethod void testupdateProductLineItem(){
        Test.startTest();      
        list<OpportunityLineItem> lstOpportunityLineItem =[Select id,PCRM_Ship_To__c,opportunityId,Product2Id,Quantity,UnitPrice from OpportunityLineItem ];
        //lstOpportunityLineItem[0].PCRM_Ship_To__c =  null;
      	new PCRM_OpportunityLineItemHandler().afterUpdate(null, null, lstOpportunityLineItem, null, null, 'test', true);        
        system.assertEquals(6,lstOpportunityLineItem.size() );
        Test.stopTest();
    }
    
    
    //Test method to cover PCRM_OpportunityLineItemHelper
    static testMethod void testAddProductLineItem(){
        Test.startTest();      
        list<OpportunityLineItem> lstOpportunityLineItem =[Select id,PCRM_Ship_To__c,opportunityId,Product2Id,Quantity,UnitPrice from OpportunityLineItem ];
        new PCRM_OpportunityLineItemHelper().autoCreateOpportunityLineItemOnProductInsertion(lstOpportunityLineItem);
        
            
        List<PCRM_Opportunity_Account__c> objOpportunityAccount = [select id,PCRM_Account__c,PCRM_Sold_To_Account__c,PCRM_Opportunity__c from PCRM_Opportunity_Account__c ];
       
        new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(objOpportunityAccount, false);      
        new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(objOpportunityAccount, true);
        system.assertEquals(4,objOpportunityAccount.size() );
        Test.stopTest();
    }
    
     //Test method to cover PCRM_OpportunityLineItemHelper
    static testMethod void testAddProductLineItem1(){
        Test.startTest();      
        list<OpportunityLineItem> lstOpportunityLineItem =[Select id,PCRM_Ship_To__c,opportunityId,Product2Id,Quantity,UnitPrice from OpportunityLineItem ];
        new PCRM_OpportunityLineItemHelper().autoCreateOpportunityLineItemOnProductInsertion(lstOpportunityLineItem);
        new PCRM_OpportunityLineItemHelper().populateOLIValues(lstOpportunityLineItem);
            
        List<PCRM_Opportunity_Account__c> objOpportunityAccount = [select id,PCRM_Account__c,PCRM_Sold_To_Account__c,PCRM_Opportunity__c from PCRM_Opportunity_Account__c ];
        new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(objOpportunityAccount, false);      
        new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(objOpportunityAccount, true);
        
        delete objOpportunityAccount;
        List <account> lstShipToAccounts = [select id from account where type = 'ZMSH' ];        
        List<Opportunity> lstOpportunity = [select id , accountId from opportunity where accountId =:lstShipToAccounts[0].id];
            
        PCRM_Opportunity_Account__c objTestOpportunityAccount = new PCRM_Opportunity_Account__c();
        objTestOpportunityAccount.PCRM_Opportunity__c = lstOpportunity[0].Id;
        objTestOpportunityAccount.PCRM_Account__c = lstShipToAccounts[0].Id;
        
        insert objTestOpportunityAccount;
             
        List<PCRM_Opportunity_Account__c> lstOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
        lstOpportunityAccount.add(objTestOpportunityAccount);
        
        new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(lstOpportunityAccount, false);      
        new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(lstOpportunityAccount, true);
       
        system.assertEquals(lstOpportunity[0].accountId,lstShipToAccounts[0].id );
        
        Test.stopTest();
    }
    
}