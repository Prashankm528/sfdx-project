/*****************************************************************************************
*   Date:           13FEB20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Tests the code in GEFUE_OpportunityTriggerHandler that updates parent Site Account with number of open Site Opportunities
*   Modifications:  
****************************************************************************************/
@isTest(SeeAllData=False)
public with sharing class GEFUE_OpportunityTriggerHandlerTest {
    
    /*
     * Method to test count of open opportunities
	*/
    @isTest static void testOpenOpportunitiesCount() {
        Id prospectSiteRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fuels NA Prospect Site').getRecordTypeId();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Id siteOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fuels NA - Branded Site').getRecordTypeId();
        
        Account testAccount = retrieveTestAccount('Test Customer Account', customerRTId);
        insert testAccount;
        
        Account testSiteAccount = retrieveTestAccount('Test Site Account', prospectSiteRTId);
        insert testSiteAccount;
        
        Opportunity testSiteOpportuity = retrieveSiteOpportunity('Test Site Opportunity', siteOppRTId, testAccount.Id, testSiteAccount.Id);
        
        Test.startTest();
        
        insert testSiteOpportuity;
        
        Account accNow = [SELECT Id, Name, GEFUE_Number_of_Open_Opportunities__c FROM Account WHERE Name = 'Test Site Account'];
        System.assertEquals(1, accNow.GEFUE_Number_of_Open_Opportunities__c);
        
        testSiteOpportuity.StageName='Credit Approval';
        update testSiteOpportuity;
        
        delete testSiteOpportuity;
        Account accNowDel = [SELECT Id, Name, GEFUE_Number_of_Open_Opportunities__c FROM Account WHERE Name = 'Test Site Account'];
        System.assertEquals(0, accNowDel.GEFUE_Number_of_Open_Opportunities__c);
        
        Test.stopTest();
        
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
    public static Opportunity retrieveSiteOpportunity(String oppName, Id rtId, String accId, Id siteAccId) {
        Opportunity siteOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Negotiation with Customer', CloseDate=System.today(), GEFUE_Site_Account__c=siteAccId,GEFUE_Is_Forecasting_for_Volume__c=true);
        return siteOpportunity;
    }
    
    /*
	* Called to create new package opportunity record
	*/
    public static Opportunity retrievePackageOpportunity(String oppName, Id rtID, String accId)
    {
        Opportunity packageOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Negotiation with Customer', CloseDate=System.today());
        return packageOpportunity;
    }
    
    /*
	* Called to create new site opportunity with Parent 
	*/
    public static Opportunity retrieveSiteOpportunityWithParent(String oppName, Id rtId, String accId, Id siteAccId, Id packageId) {
        Opportunity siteOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Negotiation with Customer', CloseDate=System.today(), GEFUE_Site_Account__c=siteAccId, GEFUE_Package__c =packageId, GEFUE_Is_Forecasting_for_Volume__c=true);
        return siteOpportunity;
    }
    
    /*
	* Called to added/updated  the volume on the Terminal related list as per terminal value selected on the site opportunity  
	*/
    @isTest static void checkPackageAndTerminal(){
        Id brandedPackageRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded_Package').getRecordTypeId();
        
        Id brandedSiteRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        Id siteRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
        
        Account testAccount = retrieveTestAccount('Test Customer Account', customerRTId);
        insert testAccount;
        
        Account siteAccount = retrieveTestAccount('Test Site Account', siteRTId);
        insert siteAccount;
        
        Test.startTest();

        Opportunity packageOppty =  retrievePackageOpportunity('Package Opportunity',brandedPackageRTID,testAccount.Id);
        insert packageOppty;
        
        GEFUE_Terminal__c terminal1 = new GEFUE_Terminal__c(Name = 'TerminalOne');
        GEFUE_Terminal__c terminal2 = new GEFUE_Terminal__c(Name = 'TerminalTwo');
        GEFUE_Terminal__c terminal3 = new GEFUE_Terminal__c(Name = 'TerminalThree');
        
        List<GEFUE_Terminal__c> lstTerminal = new List<GEFUE_Terminal__c>();
        lstTerminal.add(terminal1);
        lstTerminal.add(terminal2);
        lstTerminal.add(terminal3);
        
        Database.Insert(lstTerminal);
        
        List<Opportunity> siteOpportunity = new List<Opportunity>();
        
        Opportunity site1 = retrieveSiteOpportunityWithParent('Site1 Opportunity',brandedSiteRTID, testAccount.Id,siteAccount.Id,packageOppty.Id);
        Opportunity site2 = retrieveSiteOpportunityWithParent('Site2 Opportunity',brandedSiteRTID, testAccount.Id,siteAccount.Id,packageOppty.Id);
        Opportunity site3 = retrieveSiteOpportunityWithParent('Site3 Opportunity',brandedSiteRTID, testAccount.Id,siteAccount.Id,packageOppty.Id);
        siteOpportunity.add(site1);
        siteOpportunity.add(site2);
        siteOpportunity.add(site3);
        Database.Insert(siteOpportunity,false);        
        
        // PriceBook2 priceBookId = [Select id from PriceBook2 where Pricebook2.Name = 'Fuels NA Price Book'];
        
        Product2 prod = new Product2(Name = 'GAS',ProductCode = 'gas-1',isActive = true);
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id=pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        
        List<OpportunityLineItem> lstOpptyLineItem =  new  List<OpportunityLineItem>();
        OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(OpportunityId = site1.Id,Quantity = 100,UnitPrice = 20,PricebookEntryId = pbEntry.Id);
        OpportunityLineItem opptyLineItem2 = new OpportunityLineItem(OpportunityId = site2.Id,Quantity = 50,UnitPrice = 20,PricebookEntryId = pbEntry.Id);
        OpportunityLineItem opptyLineItem3 = new OpportunityLineItem(OpportunityId = site3.Id,Quantity = 200,UnitPrice = 20,PricebookEntryId = pbEntry.Id);
        lstOpptyLineItem.add(opptyLineItem1);
        lstOpptyLineItem.add(opptyLineItem2);
        lstOpptyLineItem.add(opptyLineItem3);
        Database.Insert(lstOpptyLineItem,false);
        
        siteOpportunity[0].GEFUE_Terminal__c = terminal1.Id;
        siteOpportunity[1].GEFUE_Terminal__c = terminal2.Id;
        siteOpportunity[2].GEFUE_Terminal__c = terminal3.Id;   
        update siteOpportunity;
        
        Test.stopTest();

        GEFUE_Opportunity_Terminal__c oppTerminal = [Select Total_Volume__c,Terminal__c From GEFUE_Opportunity_Terminal__c Where Opportunity__c = :packageOppty.Id AND Terminal__c =:terminal1.Id];
        System.assertEquals(site1.GEFUE_Terminal__c,oppTerminal.Terminal__c);
        
    }
    

}