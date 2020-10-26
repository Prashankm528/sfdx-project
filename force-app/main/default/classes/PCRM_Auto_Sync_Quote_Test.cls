/*****************************************************************************************
*   Date:         19/06/2020
*   Author:      Pooja Deokar
*   Description:  Test class for PCRM_Auto_Sync_Quote class
****************************************************************************************/
@isTest
private with sharing class PCRM_Auto_Sync_Quote_Test {
	 //test method to cover auto sync quote functionality
     static testMethod void testcreateQuote(){
        Test.startTest();
         
            List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'Sold-To Party');
            insert lstSoldToAccounts;
                  
            List<Product2> lstProducts = new PCRM_Utility().createProducts1(2);
            insert lstProducts;
            List<PricebookEntry> listPricebookEntry = new PCRM_Utility().createStandardPricebookEntry(lstProducts);
            insert listPricebookEntry;
            
            List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts,1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity;
             
            List<PricebookEntry> lstPricebookEntryId = [select Id from PricebookEntry limit 10];
             
            List<OpportunityLineItem> lstOpportunityLineItem = new PCRM_Utility().createOpportunityProducts(lstOpportunity, lstProducts);
            lstOpportunityLineItem[0].PricebookEntryId = lstPricebookEntryId[0].Id;         	
            insert lstOpportunityLineItem;      
           
             
            List<Quote> lstQuote = new PCRM_Utility().createQuote(lstOpportunity,'PCRM_Quote');
            insert lstQuote;
            List<ID> quoteIds = new List<ID>();
            for(Quote qt:lstQuote){
                quoteIds.add(qt.id);
            }
            PCRM_Auto_Sync_Quote.syncQuote(quoteIds);
                        
            system.assertEquals(2,lstOpportunityLineItem.size() );
            Test.stopTest();
        
    }
}