/*****************************************************************************************
*   Date:           17JUNE20
*   Author:         Abhishek Sharma – TCS (Tata Consultancy Services Ltd.)
*   Description:    Tests the lightning component GEFUE_NEW_PRODUCt, that filter Products based on Terminal entry.
*   Modifications:  
****************************************************************************************/
@isTest(SeeAllData=False)
public with sharing class GEFUE_CreateCommOppProdControllerTest {
    /* Test method for covering code in controller class */
    @isTest static void testCommercialOpportunityProduct(){
        Id commercialOpportunityRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Commercial').getRecordTypeId();
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id prodRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('GEFUE_Product').getRecordTypeId();
        test.startTest();
        Account testAccount = retrieveTestAccount('Test Account', customerRTId);
        insert testAccount;
        
        Opportunity testPackage = retrievePackageOpportunity('Test Package Opportunity', commercialOpportunityRTID, testAccount.Id );
        testPackage.StageName = 'Offer Creation';
        insert testPackage;
        
        GEFUE_Terminal__c testTerminal = new GEFUE_Terminal__c(Name = 'TerminalOne');
        insert testTerminal;
        Product2 prod = new Product2(Name = 'GAS',ProductCode = 'gas-1',isActive = true,Description='Test', CASFO_Product_Sales_Organisation__c='0052', RecordTypeId=prodRTId);
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id=pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        
        OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(OpportunityId = testPackage.Id,Quantity = 100,UnitPrice = 20,PricebookEntryId = pbEntry.Id);
        insert opptyLineItem1;
        
        GEFUE_Product_Terminal__c prodTerm =  new GEFUE_Product_Terminal__c(GEFUE_Product__c= prod.Id,GEFUE_Terminal__c=testTerminal.Id);
        insert prodTerm;
        GEFUE_Commercial_Opportunity_Product__c cop =  new GEFUE_Commercial_Opportunity_Product__c(GEFUE_Opportunity__c =testPackage.Id,GEFUE_Product__c= prod.Id,GEFUE_Terminal__c=testTerminal.Id );
        
        Database.insert(cop);
        
        //	GEFUE_CreateCommOppProdController CommOppProd = new GEFUE_CreateCommOppProdController();
        Map<String,GEFUE_Product_Terminal__c>  mapProdTerm =new Map<String,GEFUE_Product_Terminal__c>();
        GEFUE_CreateCommOppProdController temp =  new GEFUE_CreateCommOppProdController();
        mapProdTerm = GEFUE_CreateCommOppProdController.fetchRelatedProducts(testTerminal.Id);
        GEFUE_CreateCommOppProdController.fetchLookUpValues('gas', 'GEFUE_Product_Terminal__c', mapProdTerm);
        GEFUE_CreateCommOppProdController.fetchCommercialOpportunityRecord(cop.Id);
        test.stopTest();
    }

	/* Retreives package opportunity */
    public static Opportunity retrievePackageOpportunity(String oppName, Id rtId, String accId) {
        Opportunity packageOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Lead', CloseDate=System.today());
        return packageOpportunity;
    }
    
	/* Retreives test account record */
    public static Account retrieveTestAccount(String accName, Id rtId) {
        Account siteAccount = new Account(Name=accName, RecordTypeId=rtId);
        return siteAccount;
    }
    
}