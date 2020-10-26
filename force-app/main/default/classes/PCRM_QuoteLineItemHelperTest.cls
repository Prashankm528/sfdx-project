/*****************************************************************************************
*   Date:         11/07/2020
*   Author:      Pooja Deokar
*   Description:  Test class for quote line item before insert
****************************************************************************************/
@isTest
private with sharing class PCRM_QuoteLineItemHelperTest {
	 //test method to cover PCRM_QuoteLineItemHelper class
     static testMethod void testQuoteLineItemHelper(){
        Test.startTest();
       	    PCRM_Utility utilityClass = NEW PCRM_Utility();
         
         	//insert metadata for quotelineitem
       		QuoteLineSyncField__c qliSync = new QuoteLineSyncField__c();
        	qliSync.Name ='PCRM_Payload__c';
         	qliSync.OppLineSyncField__c ='PCRM_Payload__c';
            insert qliSync;
         
            List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'Sold-To Party');
            insert lstSoldToAccounts;
                  
            List<Product2> lstProducts = new PCRM_Utility().createProducts1(1);
            insert lstProducts;
            List<PricebookEntry> listPricebookEntry = new PCRM_Utility().createStandardPricebookEntry(lstProducts);
            insert listPricebookEntry;
            
            List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts,1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity;
             
            List<PricebookEntry> lstPricebookEntryId = [select Id from PricebookEntry limit 10];
             
            List<OpportunityLineItem> lstOpportunityLineItem = new PCRM_Utility().createOpportunityProducts(lstOpportunity, lstProducts);
            lstOpportunityLineItem[0].PricebookEntryId = lstPricebookEntryId[0].Id;
        	lstOpportunityLineItem[0].PCRM_Payload__c = '100';
            insert lstOpportunityLineItem;      
           
             
            List<Quote> lstQuote = new PCRM_Utility().createQuote(lstOpportunity,'PCRM_Quote');
            insert lstQuote;
           
      	    List <QuoteLineItem> ListOfQuotesLines = utilityClass.createQuoteLines(lstQuote,lstProducts); 
        	ListOfQuotesLines[0].Description = lstOpportunityLineItem[0].id;
            INSERT ListOfQuotesLines;
         	new PCRM_QuoteLineItemHelper().qliBeforeInsertCustomFieldSync(ListOfQuotesLines); 
            new PCRM_QuoteLineItemHandler().beforeInsert(null, null, ListOfQuotesLines, null, null, 'test', true);
         	system.assertEquals(lstOpportunityLineItem[0].PCRM_Payload__c,ListOfQuotesLines[0].PCRM_Payload__c );
            Test.stopTest();
        
    }
}