/*****************************************************************************************
*   Date:           07JULY20
*   Author:         Abhishek Sharma – TCS (Tata Consultancy Services Ltd.)
*   Description:    Tests the lightning component GEFUE_Branded_Fetch_Product, that filter Products based on Terminal entry.
*   Modifications:  
****************************************************************************************/

@isTest(SeeAllData=False)
public with sharing class GEFUE_Branded_Fetch_ProductTest {
    /* Test method for covering code in controller class */
    @isTest static void testFilteredProductList(){
        Id brandedSiteRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        Id productRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('GEFUE_Product').getRecordTypeId();
        
        test.startTest();  
        Account testAccount = retrieveTestAccount('Test Customer Account', customerRTId);
        insert testAccount;
        
        Opportunity siteOpportunity =  retrieveSiteOpportunity('Package Opportunity',brandedSiteRTID,testAccount.Id);
        insert siteOpportunity;
        
        GEFUE_Terminal__c testTerminal = new GEFUE_Terminal__c(Name = 'TerminalOne');
        insert testTerminal;
        Product2 prod = new Product2(Name = 'GAS',ProductCode = 'gas-1',isActive = true,Description='Test', CASFO_Product_Sales_Organisation__c='0052',RecordTypeId=productRTId);
        insert prod;
        
        Product2 prodObj = new Product2(Name = 'GAS',ProductCode = 'gas-1',isActive = true,Description='Test', CASFO_Product_Sales_Organisation__c='0052',RecordTypeId=productRTId);
        insert prodObj;
        
        PriceBook2 pricebookIdSTD = New PriceBook2(Id = test.getStandardPricebookId(), isActive = true);
        update pricebookIdSTD;
        
        Pricebook2 pricebookIdCST = new Pricebook2 (Name='Fuels NA Price Book',Description='Test Pricebook Entry 1', isActive=true);
        insert pricebookIdCST;   
        
        //Create your pricebook entry
        PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id=pricebookIdSTD.Id,Product2Id = prod.Id,UnitPrice = 1.00,IsActive = true);
        insert pbEntry1;
        
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id=pricebookIdCST.Id,Product2Id = prod.Id,UnitPrice = 1.00,IsActive = true);
        insert pbEntry2;
        

        OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(OpportunityId = siteOpportunity.Id,Quantity = 100,UnitPrice = 20,PricebookEntryId = pbEntry2.Id);
        insert opptyLineItem1;
        
        GEFUE_Product_Terminal__c prodTerm =  new GEFUE_Product_Terminal__c(GEFUE_Product__c= prod.Id,GEFUE_Terminal__c=testTerminal.Id);
        insert prodTerm;
        
        GEFUE_Product_Terminal__c prodTerm2 =  new GEFUE_Product_Terminal__c(GEFUE_Product__c= prodObj.Id,GEFUE_Terminal__c=testTerminal.Id);
        insert prodTerm2;
        
        List<GEFUE_Branded_Fetch_Product.OLIWrapperCls> lstWrapperProduct = new List< GEFUE_Branded_Fetch_Product.OLIWrapperCls>();
        GEFUE_Branded_Fetch_Product.OLIWrapperCls objWrapper = new GEFUE_Branded_Fetch_Product.OLIWrapperCls();
        objWrapper.UnitPrice = 1;
        objWrapper.Quantity =  null;
        objWrapper.isTrue  = true;
        objWrapper.productId =  prod.Id;
        objWrapper.productName = prod.Name;
        objWrapper.productCode = prod.ProductCode;
        objWrapper.brandedUnbranded =  'Branded';
        objWrapper.productDescription = 'Product Description';
        lstWrapperProduct.add(objWrapper);
        
        GEFUE_Branded_Fetch_Product.OLIWrapperCls objWrapper2 = new GEFUE_Branded_Fetch_Product.OLIWrapperCls();
        objWrapper2.UnitPrice = 1;
        objWrapper2.Quantity =  null;
        objWrapper2.isTrue  = true;
        objWrapper2.productId =  prodObj.Id;
        objWrapper2.productName = prodObj.Name;
        objWrapper2.productCode = prodObj.ProductCode;
        objWrapper2.brandedUnbranded =  'Branded';
        objWrapper2.productDescription = 'Product Description';
        lstWrapperProduct.add(objWrapper2);
        
        List< GEFUE_Branded_Fetch_Product.OLIWrapperCls> lstWrapperDraftedValue = new List< GEFUE_Branded_Fetch_Product.OLIWrapperCls>();
        GEFUE_Branded_Fetch_Product.OLIWrapperCls objWrapperDraft = new GEFUE_Branded_Fetch_Product.OLIWrapperCls();
        objWrapperDraft.Quantity = 5000;
        objWrapperDraft.productId =  prod.Id;
        lstWrapperDraftedValue.add(objWrapperDraft);
        
        GEFUE_Branded_Fetch_Product.OLIWrapperCls objWrapperDraft2 = new GEFUE_Branded_Fetch_Product.OLIWrapperCls();
        objWrapperDraft2.Quantity = 3000;
        objWrapperDraft2.productId =  prodObj.Id;
        lstWrapperDraftedValue.add(objWrapperDraft2);
        
        
        GEFUE_Branded_Fetch_Product clsObject =  new GEFUE_Branded_Fetch_Product();
        GEFUE_Branded_Fetch_Product.insertOppLineItem(JSON.serialize(lstWrapperProduct),JSON.serialize(lstWrapperDraftedValue),siteOpportunity.Id);
        GEFUE_Branded_Fetch_Product.fetchData(siteOpportunity.Id,testTerminal.Id);
        
        OpportunityLineItem oppLineItemAssert = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId=:siteOpportunity.Id AND Product2Id =:prod.Id LIMIT 1];
        System.assert(oppLineItemAssert.Id != NULL, 'Products not added');
        test.stopTest(); 
        
    }
/*
* Method to create new test Account record
*/
    public static Account retrieveTestAccount(String accName, Id rtId) {
        Account siteAccount = new Account(Name=accName, RecordTypeId=rtId);
        return siteAccount;
    }
    
/*
* Called to create new Site opportunity record
*/
    public static Opportunity retrieveSiteOpportunity(String oppName, Id rtId, String accId) {
        Opportunity siteOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Negotiation with Customer', CloseDate=System.today());
        return siteOpportunity;
    }
    
}