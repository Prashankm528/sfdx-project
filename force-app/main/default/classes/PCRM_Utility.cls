/*****************************************************************************************
*   Date: 06/23/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Test Utility class to create records
*   Version 1.1 
****************************************************************************************/
@isTest
public with sharing class PCRM_Utility
{
    
     //Method is used to create Account of monthly quote frequency 
    public List<Account> createAccount(Integer nAccountCount, String recordTypeName, String strType){
        
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        List<Account> lstAccount = new List<Account>();

        Integer nCounter = 0;

        for (nCounter = 0; nCounter < nAccountCount; nCounter++){
            Account objAccount = new Account();
            objAccount.recordTypeId = accountRecordTypeId;
            objAccount.Name = 'Test' + nCounter;
            objAccount.type = strType;
            objAccount.CurrencyIsoCode = 'USD';
            objAccount.Sales_Division_Code__c = '69';
            objAccount.PCRM_Quote_Frequency__c = 'Monthly';
            objAccount.PCRM_Regional_Business__c = 'Acetyls Europe';
            lstAccount.add(objAccount);
        }
        return lstAccount;
    }    
   
     //Method is used to create Account of quaterly quote frequency 
    public List<Account> createAccountQuaterly(Integer nAccountCount, String recordTypeName, String strType){
        
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        List<Account> lstAccount = new List<Account>();

        Integer nCounter = 0;

        for (nCounter = 0; nCounter < nAccountCount; nCounter++){
            Account objAccount = new Account();
            objAccount.recordTypeId = accountRecordTypeId;
            objAccount.Name = 'Test' + nCounter;
            objAccount.type = strType;
            objAccount.CurrencyIsoCode = 'USD';
            objAccount.Sales_Division_Code__c = '69';
            objAccount.PCRM_Quote_Frequency__c = 'Quarterly';
            objAccount.PCRM_Regional_Business__c = 'Acetyls Europe';
            lstAccount.add(objAccount);
        }
        return lstAccount;
    }
    
     //Method is used to create opportunity
    public List<Opportunity> createOpportunity(List<Account> lstAccount, Integer nOpportunityPerAccount, String recordTypeName){
    
        Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        List<Opportunity> lstOpportunity = new List<Opportunity>();
        if (lstAccount != null && lstAccount.size() > 0){
            for (Account objAccount: lstAccount){
                for(Integer nCount = 0; nCount < nOpportunityPerAccount; nCount++){
                    Opportunity objOpportunity = new Opportunity();
                    objOpportunity.Name = 'Opportunity_' + nCount;
                    objOpportunity.CurrencyIsoCode = 'USD';
                    objOpportunity.accountId = objAccount.Id;
                    objOpportunity.Pricebook2Id =Test.getStandardPricebookId();
                    objOpportunity.Type = 'PCRM_Contract - Long Form';
                    objOpportunity.CloseDate = system.Today() + 5;
                    objOpportunity.PCRM_Start_Date__c = system.Today() +1;
                    objOpportunity.PCRM_End_Date__c = system.Today() +10;
                    objOpportunity.StageName = 'Proposal';
                    objOpportunity.ForecastCategoryName = 'Pipeline';
                    objOpportunity.recordTypeId = opportunityRecordTypeId;
                    lstOpportunity.add(objOpportunity);
                }
            }
        }
        return lstOpportunity;
    }
    //Method is used to create pricebook
    public List<PricebookEntry> createStandardPricebookEntry(List<Product2> listProduct)
    {
            Id pricebookId = Test.getStandardPricebookId();
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
            
            for (Product2 objProduct: listProduct)
            {
                PricebookEntry objPricebookEntry = new PricebookEntry();
                objPricebookEntry.Pricebook2Id = pricebookId;
                objPricebookEntry.Product2Id = objProduct.Id;
                objPricebookEntry.UnitPrice = 100;
                objPricebookEntry.CurrencyIsoCode = 'USD';
                objPricebookEntry.IsActive = true;
                lstPricebookEntry.add(objPricebookEntry);
            }
            return lstPricebookEntry;
    }
     //Method is used to create product
    public List<Product2> createProducts1(Integer nTotalProducts)
    {
        system.debug('nTotalProducts: '+nTotalProducts);
        List<Product2> lstProduct2 = new List<Product2>();
        
        for (Integer nProdCounter = 0; nProdCounter < nTotalProducts; nProdCounter++){
            Product2 objProduct = new Product2();
            objProduct.CurrencyIsoCode = 'USD';
            objProduct.IsActive = True;
            objProduct.Name = 'Product_' + nProdCounter;
            objProduct.CanUseQuantitySchedule = true;
            lstProduct2.add(objProduct);
        }
        return lstProduct2;
    }    
         
     //Method is used to create product
    public List<Product2> createProducts(Integer nTotalProducts)
    {
        system.debug('nTotalProducts: '+nTotalProducts);
        List<Product2> lstProduct2 = new List<Product2>();
        
        for (Integer nProdCounter = 0; nProdCounter < nTotalProducts; nProdCounter++){
            Product2 objProduct = new Product2();
            objProduct.CurrencyIsoCode = 'USD';
            objProduct.Name = 'Product_' + nProdCounter;
            objProduct.CanUseQuantitySchedule = true;
            objProduct.IsActive = True;
            lstProduct2.add(objProduct);
        }
        system.debug('lstProduct2: '+lstProduct2);
        
        if(lstProduct2 != null && lstProduct2.size() > 0)
        {
            insert lstProduct2;
            
            Id pricebookId = Test.getStandardPricebookId();
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
            
            for (Product2 objProduct: lstProduct2)
            {
                PricebookEntry objPricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, CurrencyIsoCode = 'USD',Product2Id = objProduct.Id, UnitPrice = 100, IsActive = true);
                lstPricebookEntry.add(objPricebookEntry);
            }
           
            if (lstPricebookEntry != null && lstPricebookEntry.size() > 0)
            {
                try
                {                   
                    insert lstPricebookEntry;
                    system.debug('lstProduct2dgdsg: '+lstPricebookEntry);
                }
                catch(exception ex)
                {
                    system.debug('ex: '+ex);
                }
               
            }
        }
        
        return lstProduct2;
    }
    
    
    
    //create contract Agreement records
    public List<APXT_Redlining__Contract_Agreement__c> createContractAgreement(List<Opportunity> lstOpportunity,string recordTypeName)
    {
        Id createContractAgreementRecordTypeId = Schema.SObjectType.APXT_Redlining__Contract_Agreement__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        
        List<APXT_Redlining__Contract_Agreement__c> lstContractAgreement = new List<APXT_Redlining__Contract_Agreement__c>();
        
        if (lstOpportunity != null)
        {
            for (Opportunity objOpportunity: lstOpportunity)
            {
                //for (Product2 objProduct: lstProducts)
                {
                    APXT_Redlining__Contract_Agreement__c objOpportunityContractAgreement = new APXT_Redlining__Contract_Agreement__c();
                    objOpportunityContractAgreement.PCRM_Opportunity__c = objOpportunity.Id;
                    //objOpportunityContractAgreement.Process_Instance__c = 1;
                    objOpportunityContractAgreement.APXT_Redlining__Effective_Date__c =system.Today() +1;
                    objOpportunityContractAgreement.APXT_Redlining__Expiration_Date__c =system.Today() +10;
                    objOpportunityContractAgreement.recordtypeId = createContractAgreementRecordTypeId;
                    //objOpportunityContractAgreement.APXT_Redlining__Proposed_Value__c = 10;
                    
                    lstContractAgreement.add(objOpportunityContractAgreement);
                }
            }
        }
        
        return lstContractAgreement;
    }
    
    
     //create Managed clauses records
    public List<APXT_Redlining__Managed_Clause__c> createManagedClauses(List<APXT_Redlining__Contract_Agreement__c> lstContractAgreement)
    {
        List<APXT_Redlining__Managed_Clause__c> lstManagedClauses = new List<APXT_Redlining__Managed_Clause__c>();
        
        if (lstContractAgreement != null)
        {
            for (APXT_Redlining__Contract_Agreement__c objContractAgreement: lstContractAgreement)
            {
                //for (Product2 objProduct: lstProducts)
                {
                    APXT_Redlining__Managed_Clause__c objOpportunityContractAgreement = new APXT_Redlining__Managed_Clause__c();
                    objOpportunityContractAgreement.APXT_Redlining__Contract_Agreement__c = objContractAgreement.Id;
                    
                    lstManagedClauses.add(objOpportunityContractAgreement);
                }
            }
        }
        
        return lstManagedClauses;
    }
    
    //create opportunity products
    public List<OpportunityLineItem> createOpportunityProducts(List<Opportunity> lstOpportunity, List<Product2> lstProducts)
    {
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        
        if (lstOpportunity != null){
            for (Opportunity objOpportunity: lstOpportunity){
                for (Product2 objProduct: lstProducts){
                    OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
                    objOpportunityLineItem.opportunityId = objOpportunity.Id;
                    objOpportunityLineItem.Product2Id = objProduct.Id;
                    objOpportunityLineItem.Quantity = 1;
                    objOpportunityLineItem.UnitPrice = 10;
                    
                    lstOpportunityLineItem.add(objOpportunityLineItem);
                }
            }
        }
        
        return lstOpportunityLineItem;
    }
    
    
    //create opportunity Line item schedule
     public List<OpportunityLineItemSchedule> createOpportunityLineSchedule(List<OpportunityLineItem> lstOpportunityLineItem)
     {
        List<OpportunityLineItemSchedule> lstOpportunityLineItemSchedule = new List<OpportunityLineItemSchedule>();
        
        if (lstOpportunityLineItem != null)
        {
            for (OpportunityLineItem objOpportunityLineItem: lstOpportunityLineItem)
            {
                {
                    OpportunityLineItemSchedule objOpportunityLineItemSchedule = new OpportunityLineItemSchedule();
                    objOpportunityLineItemSchedule.Description = 'Description';
                    objOpportunityLineItemSchedule.OpportunityLineItemId = objOpportunityLineItem.Id;
                    objOpportunityLineItemSchedule.Max_Annual_Quantity__c = 1;
                    objOpportunityLineItemSchedule.Quantity = 10;
                    //objOpportunityLineItemSchedule.Revenue = ;
                    objOpportunityLineItemSchedule.ScheduleDate = date.today();
                    objOpportunityLineItemSchedule.type = 'Quantity';
                    lstOpportunityLineItemSchedule.add(objOpportunityLineItemSchedule);
                }
            }
        }
        
        return lstOpportunityLineItemSchedule;
    }
    
    
    //create opportunity account records
    public List<PCRM_Opportunity_Account__c> createOpportunityAccount(Integer nAccountCount, String recordTypeName,Id OpportunityId,List<Account> LstShipAccounts)
    {
        Id opportunityAccountRecordTypeId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        List<PCRM_Opportunity_Account__c> lstOpportunityAccount = new List<PCRM_Opportunity_Account__c>();

        Integer nCounter = 0;

        for (nCounter = 0; nCounter < nAccountCount; nCounter++)
        {
            PCRM_Opportunity_Account__c objOpportunityAccount = new PCRM_Opportunity_Account__c();
            objOpportunityAccount.recordTypeId = opportunityAccountRecordTypeId;
            objOpportunityAccount.Name = 'Test' + nCounter;
            objOpportunityAccount.PCRM_Account__c = LstShipAccounts[nCounter].Id;
            objOpportunityAccount.PCRM_Opportunity__c = OpportunityId;
            //objOpportunityAccount.PCRM_Sold_To_Account__c = soldToAccountId;   
            //objOpportunityAccount.CurrencyIsoCode = 'USD';
            lstOpportunityAccount.add(objOpportunityAccount);
        }

        return lstOpportunityAccount;
        
        
    }
    
    
    //create contact records
     public List<Contact> createContact(Integer nContactCount, String recordTypeName)
     {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        List<Contact> lstContact = new List<Contact>();

        Integer nCounter = 0;

        for (nCounter = 0; nCounter < nContactCount; nCounter++)
        {
            Contact objContact = new Contact();
            objContact.recordTypeId = contactRecordTypeId;
            objContact.LastName = 'Test' + nCounter;
            //objContact.type = strType;
            //objContact.CurrencyIsoCode = 'USD';
            lstContact.add(objContact);
        }

        return lstContact;
    }
   
     //create opportunity contact roles
     public List<OpportunityContactRole> createOpportunityContactRole(Opportunity objOpportunity,List<Contact>lstContacts)
     {
        List<OpportunityContactRole> lstOpportunityContactRole = new List<OpportunityContactRole>();
        
        if (lstContacts != null)
        {
            for (Contact objContact: lstContacts)
            {
                {
                    OpportunityContactRole objOpportunityContactRole = new OpportunityContactRole();
                    objOpportunityContactRole.ContactId = objContact.Id;
                    //objOpportunityContactRole.PCRM_isCreatedFromCloning__c = True;
                    objOpportunityContactRole.OpportunityId = objOpportunity.Id;
                    //objOpportunityContactRole.PCRM_OpportunityContactRole_Cloned_From__c = date.today();
                    objOpportunityContactRole.Role = 'Business User';
                    lstOpportunityContactRole.add(objOpportunityContactRole);
                }
            }
        }
        
        return lstOpportunityContactRole;
    }
    
     //Method is used to create quote
   public List<Quote> createQuote(List<Opportunity> lstOpp, String recordTypeName)
   {
    
       Id quoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
       
        List<Quote> quoteList = new List<Quote>();
       for (Opportunity o : lstOpp)
       {
           Quote q = new Quote();
           q.name = 'Quote#$$-' + o.name;
           q.opportunityId = o.id;
            q.CurrencyIsoCode = 'USD';
           q.RecordTypeId = quoteRecordTypeId;
            q.Pricebook2Id =Test.getStandardPricebookId();
           quoteList.add(q);
       }    
        return quoteList;
    }
    
    //create Quote Lines
    public List<QuoteLineItem> createQuoteLines(List<Quote> lstQuote,List<Product2> lstProducts)
    {
       Map<Id,Id> MapofProductIdWithPricebookEntryId = NEW  Map<Id,Id>();
       
       //creating map of Map of ProductId With PricebookEntryId ...so that can assign it while creating Quote Line Items
       for(PricebookEntry pbe : [SELECT ID,Pricebook2Id,CurrencyIsoCode,Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id IN : lstProducts])
       {
           MapofProductIdWithPricebookEntryId.put(pbe.Product2Id, pbe.Id);
       }
        
       system.debug('MapofProductIdWithPricebookEntryId: '+MapofProductIdWithPricebookEntryId);
        
       List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        
        if (lstQuote != null)
        {
            for (Quote objQuote: lstQuote)
            {
                for (Product2 objProduct: lstProducts)
                {
                    QuoteLineItem objQuoteLineItem = new QuoteLineItem();
                    objQuoteLineItem.QuoteId = objQuote.Id;
                    objQuoteLineItem.PricebookEntryId = MapofProductIdWithPricebookEntryId.get(objProduct.Id);
                    objQuoteLineItem.Quantity  = 5;
                    objQuoteLineItem.UnitPrice  = 7;
                    objQuoteLineItem.Product2Id  = objProduct.Id;
                    
                    lstQuoteLineItem.add(objQuoteLineItem);
                }
            }
        }
        
        return lstQuoteLineItem;
    }
    //method is used to create cronexpression
     public string  getCronExpession()
     {
        //parse to cron expression
        String cronexpression = String.valueOf(Datetime.now().second() ) + ' ' + String.valueOf(Datetime.now().minute()) + ' ' + String.valueOf(Datetime.now().hour()) + ' * * ?';	
        return cronexpression;        
     }
    
    //method is used to get old and new opp Id
     public map<Id, Id>  getMapOldNewOppID()
     {       
        map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
        for(Opportunity opty:[Select id,PCRM_Opportunity_Cloned_From__c,PCRM_isFirstSyncWithQuote__c 
                              From Opportunity 
                              Where PCRM_Quote_Frequency__c ='Quarterly' ]){
            mapOldOpportunityIDsWithNewOpportunityIDs.put(opty.PCRM_Opportunity_Cloned_From__c,opty.Id);
        }  
         return mapOldOpportunityIDsWithNewOpportunityIDs;
     }
    
    //method is used to setup batch class data 
     public void testPCRM_BatchCloneOpportunitydata(String frequency)
     {
          //create montly account        
		List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'Sold-To Party');
		insert lstSoldToAccounts;      
            
        //Create opportunity for montly account
		List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts,1, 'PCRM_PetChems_Acetyls');
		for(Opportunity ObjOpp : lstOpportunity)
		{
			ObjOpp.Type ='PCRM_Spot';
			ObjOpp.PCRM_isFirstSyncWithQuote__c = true;
			ObjOpp.PCRM_Quote_Frequency__c = frequency;
			ObjOpp.StageName = 'Prospecting';
		}         
		insert lstOpportunity;  
         
        //Create quote
		List<Quote> lstQuote = new PCRM_Utility().createQuote(lstOpportunity,'PCRM_Quote');
		for(Quote q: lstQuote){
			q.Status = 'Presented'; 
		}  
		insert lstQuote;
     }
     //method is used to setup batch class data 
     public void setupBatchclassdataFrequency(String frequency) {
        //create montly account        
		List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'Sold-To Party');
		insert lstSoldToAccounts;      
            
        //Create opportunity for montly account
		List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts,1, 'PCRM_PetChems_Acetyls');
		for(Opportunity ObjOpp : lstOpportunity)
		{
			ObjOpp.Type ='PCRM_Spot';
			ObjOpp.PCRM_isFirstSyncWithQuote__c = true;
			ObjOpp.PCRM_Quote_Frequency__c = frequency;
			ObjOpp.StageName = 'Prospecting';
		}         
		insert lstOpportunity;  
		
		//Create opportunity for quaterly account
		List<Opportunity> lstOpportunity1 = new PCRM_Utility().createOpportunity(lstSoldToAccounts,1, 'PCRM_PetChems_Acetyls');			
		for(Integer nCount = 0; nCount < lstOpportunity1.size(); nCount++){  
			lstOpportunity1[nCount].PCRM_Opportunity_Cloned_From__c = lstOpportunity[nCount].id;
			lstOpportunity1[nCount].Type ='PCRM_Spot';
			lstOpportunity1[nCount].PCRM_isFirstSyncWithQuote__c = true;
			lstOpportunity1[nCount].PCRM_Quote_Frequency__c = frequency;
			lstOpportunity1[nCount].StageName = 'Prospecting';
            
		}  
		insert lstOpportunity1;
		
		//insert Contact         
		List <Contact>  ListOfContacts =  new PCRM_Utility().createContact(5,'PCRM_Petchem_Contact');
		INSERT ListOfContacts;
	 
		//Creaet opportunity Account
		List <OpportunityContactRole> ListOfOpportunityContactRole = new PCRM_Utility().createOpportunityContactRole(lstOpportunity[0],ListOfContacts);
		INSERT ListOfOpportunityContactRole;
		
		
		List <PCRM_Opportunity_Account__c> ListOfOpportunityAccounts  = new PCRM_Utility().createOpportunityAccount(lstSoldToAccounts.size(),'PCRM_Opportunity_Account',lstOpportunity[0].Id,lstSoldToAccounts);
		INSERT ListOfOpportunityAccounts;
		
	    //Create product
		List<Product2> lstProducts = new PCRM_Utility().createProducts1(1);
		insert lstProducts;
	 
		//Create pricebook
		List<PricebookEntry> listPricebookEntry = new PCRM_Utility().createStandardPricebookEntry(lstProducts);
		insert listPricebookEntry;
		
		List<PricebookEntry> lstPricebookEntryId = [select Id from PricebookEntry limit 10];
		//Create opportunity Product
		List<OpportunityLineItem> lstOpportunityLineItem = new PCRM_Utility().createOpportunityProducts(lstOpportunity, lstProducts);
		lstOpportunityLineItem[0].PricebookEntryId = lstPricebookEntryId[0].Id;
		lstOpportunityLineItem[0].PCRM_Payload__c = '100';         
		insert lstOpportunityLineItem;  

		//Create quote
		List<Quote> lstQuote = new PCRM_Utility().createQuote(lstOpportunity,'PCRM_Quote');
		for(Quote q: lstQuote){
			q.Status = 'Presented'; 
		}  
		insert lstQuote;
	 
		//Create quote
		List<Quote> lstQuote1 = new PCRM_Utility().createQuote(lstOpportunity1,'PCRM_Quote');
		for(Integer nCount = 0; nCount < lstQuote1.size(); nCount++){ 
			lstQuote1[nCount].Status ='Draft';
			lstQuote1[nCount].PCRM_Quote_Cloned_From__c = lstQuote[nCount].id;
		}
		insert lstQuote1;
		
		//sync quote
		List<Opportunity> lstOpportunityUpdate = new List<Opportunity>();
		for(Quote quot:lstQuote1){
			if(quot.IsSyncing == false && quot.OpportunityId != null){
				Opportunity opty = new Opportunity();
				opty.PCRM_isFirstSyncWithQuote__c = true;
				opty.ID = quot.OpportunityId;
				opty.SyncedQuoteID = quot.id;
				lstOpportunityUpdate.add(opty);
			}
		}
		if(lstOpportunityUpdate != null && (!lstOpportunityUpdate.isEmpty())) {
			update lstOpportunityUpdate;
		}			
     }	 
     
}