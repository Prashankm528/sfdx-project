/*****************************************************************************************
*   Date:           27JULY20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Queueable class to create Opportunities from Mass Upload functionality
*   Modifications:  
****************************************************************************************/
public with sharing class GEFUE_CreateOpportunityQueueable implements Queueable {
    private List<GEFUE_Opportunity_Staging__c> oppStageFinal;
    private Set<String> setAccountNumber;
    private Set<String> setTerminalNumber;
    
    public GEFUE_CreateOpportunityQueueable(List<GEFUE_Opportunity_Staging__c> oppStageRows, Set<String> setAccountNumber, Set<String> setTerminalNumber) {
        this.oppStageFinal = oppStageRows;
        this.setAccountNumber = setAccountNumber;
        this.setTerminalNumber = setTerminalNumber;
    }
    
	public void execute(QueueableContext context) {
        Set<String> setPackageNames = new Set<String>();
        Set<String> setSiteAccountNames = new Set<String>();
        Map<String, List<String>> mapSiteNameAddress =  new Map<String, List<String>>();
        Map<String, String> mapAccountNumber = new Map<String, String>();
        Map<String, String> mapTerminalNumber = new Map<String, String>();
        Map<String, String> mapPackageNameId = new Map<String, String>();
        Map<String, String> mapSiteAccountNameId = new Map<String, String>();
        Map<String, List<GEFUE_Opportunity_Staging__c>> mapPackageOppStage = new Map<String, List<GEFUE_Opportunity_Staging__c>>();
        List<Account> lstAccounts = [SELECT Id, Name, AccountNumber FROM Account WHERE AccountNumber IN :setAccountNumber];
        List<GEFUE_Terminal__c> lstTerminals = [SELECT Id, Name, GEFUE_Terminal_Number__c FROM GEFUE_Terminal__c WHERE GEFUE_Terminal_Number__c IN :setTerminalNumber];
        
        for(Account acc : lstAccounts) {
            mapAccountNumber.put(acc.AccountNumber, acc.Id);
        }
        for (GEFUE_Terminal__c terminal : lstTerminals) {
            mapTerminalNumber.put(terminal.GEFUE_Terminal_Number__c, terminal.Id);
        }
        
        for (GEFUE_Opportunity_Staging__c oppStage : oppStageFinal) {
            if (oppStage.GEFUE_Package__c != NULL && oppStage.GEFUE_Package__c != '') {
                if (!mapPackageOppStage.containsKey(oppStage.GEFUE_Package__c)) {
                    mapPackageOppStage.put(oppStage.GEFUE_Package__c, new List<GEFUE_Opportunity_Staging__c>{oppStage});
                } else {
                    mapPackageOppStage.get(oppStage.GEFUE_Package__c).add(oppStage);
                }
                setPackageNames.add(oppStage.GEFUE_Package__c);
            }
            if (oppStage.GEFUE_Site_Street__c != '' && oppStage.GEFUE_Site_Street__c != NULL &&
               	oppStage.GEFUE_Site_City__c != '' && oppStage.GEFUE_Site_City__c != NULL &&
                oppStage.GEFUE_Site_State__c != '' && oppStage.GEFUE_Site_State__c != NULL) {
				String siteAccName = oppStage.GEFUE_Site_Street__c+', '+oppStage.GEFUE_Site_City__c+', '+oppStage.GEFUE_Site_State__c;
                setSiteAccountNames.add(siteAccName);
                mapSiteNameAddress.put(siteAccName, new List<String>{oppStage.GEFUE_Site_Street__c, oppStage.GEFUE_Site_City__c, oppStage.GEFUE_Site_State__c});
            }
        }
        mapPackageNameId = createPackage(mapPackageOppStage, mapAccountNumber);
        mapSiteAccountNameId = createSiteAccount(setSiteAccountNames, mapSiteNameAddress);
        Set<String> setAccIdTemp = new Set<String>(mapSiteAccountNameId.values());
        
        Map<Id, Account> mapSiteAccountTemp = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :setAccIdTemp]);
        
        Map<String, String> mapOppIdSiteAccount = new Map<String, String>();
        List<Opportunity> lstCreatedSiteOpportunities = createSiteOpportunities(oppStageFinal, mapPackageNameId, mapSiteAccountNameId, mapAccountNumber, mapTerminalNumber);
        for (Opportunity opp : lstCreatedSiteOpportunities) {
            System.debug('@@# opp Id '+opp.Id);
            mapOppIdSiteAccount.put(mapSiteAccountTemp.get(opp.GEFUE_Site_Account__c).Name, opp.Id);
        }
        for (GEFUE_Opportunity_Staging__c oppStage : oppStageFinal) {
            String siteAccName = oppStage.GEFUE_Site_Street__c+', '+oppStage.GEFUE_Site_City__c+', '+oppStage.GEFUE_Site_State__c;
            oppStage.GEFUE_Opportunity_Id__c = mapOppIdSiteAccount.get(siteAccName);
        }
 		update oppStageFinal;
        
        createOpportunityProducts(oppStageFinal);
        
        if (mapPackageNameId.size() > 0) {
            
        }
        
    }

    /*
    * To create package opportunity
    */
    public Map<String, String> createPackage(Map<String, List<GEFUE_Opportunity_Staging__c>> mapPackageOppStage, Map<String, String> mapAccountNumber) {
        List<Opportunity> lstPackageToCreate = new List<Opportunity>();
        Map<String, String> mapPackageNameId = new Map<String, String>();
        for (String packageName : mapPackageOppStage.keySet()) {
            Opportunity packageOpp = new Opportunity();
            packageOpp.Name = packageName;
            if (mapPackageOppStage.get(packageName).size() > 0) {
                packageOpp.CloseDate = Date.valueOf(mapPackageOppStage.get(packageName)[0].GEFUE_Close_Date__c);
                packageOpp.StageName = 'Lead';
                packageOpp.AccountId = mapAccountNumber.get(mapPackageOppStage.get(packageName)[0].GEFUE_Account_Number__c);
                packageOpp.RecordTypeId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded_Package').getRecordTypeId();
            }
            lstPackageToCreate.add(packageOpp);
        }
        insert lstPackageToCreate;
        
        for (Opportunity createdPackage : lstPackageToCreate) {
            mapPackageNameId.put(createdPackage.Name, createdPackage.Id);
        }
        return mapPackageNameId;
	}
    
    /*
    * To create site account
    */
    public Map<String, String> createSiteAccount(Set<String> setSiteAccountNames, Map<String, List<String>> mapSiteNameAddress) {
        Map<String, String> mapSiteAccountNames = new Map<String, String>();
        List<Account> lstSiteAccountToInsert = new List<Account>();
        for (String siteAccount : setSiteAccountNames) {
            Account siteAcc = new Account();
            siteAcc.Name = siteAccount;
            siteAcc.BillingStreet = mapSiteNameAddress.get(siteAccount)[0];
            siteAcc.BillingCity = mapSiteNameAddress.get(siteAccount)[1];
            siteAcc.BillingState = mapSiteNameAddress.get(siteAccount)[2];
            siteAcc.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Prospect_Site').getRecordTypeId();
            lstSiteAccountToInsert.add(siteAcc);
		}
        insert lstSiteAccountToInsert;
        
        for (Account siteAccTemp : lstSiteAccountToInsert) {
            mapSiteAccountNames.put(siteAccTemp.Name, siteAccTemp.Id);
        }
        return mapSiteAccountNames;
    }
    
    /*
    * To create Site opportunity
    */
    public List<Opportunity> createSiteOpportunities(List<GEFUE_Opportunity_Staging__c> oppStageFinal, Map<String, String> mapPackageNameId, Map<String, String> mapSiteAccountNameId, Map<String, String> mapAccountNumberId, Map<String, String> mapTerminalNumberId) {
        List<Opportunity> lstSiteOpportunitiestoInsert = new List<Opportunity>();
        for (GEFUE_Opportunity_Staging__c oppStageTemp : oppStageFinal) {
            String siteAccountNameTemp = oppStageTemp.GEFUE_Site_Street__c+', '+oppStageTemp.GEFUE_Site_City__c+', '+oppStageTemp.GEFUE_Site_State__c;
            Opportunity siteOpp = new Opportunity();
            if (oppStageTemp.GEFUE_Package__c != NULL && oppStageTemp.GEFUE_Package__c != '') {
                siteOpp.GEFUE_Package__c = mapPackageNameId.get(oppStageTemp.GEFUE_Package__c);
            }
            siteOpp.Name = siteAccountNameTemp;
            siteOpp.RecordTypeId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
            siteOpp.AccountId = mapAccountNumberId.get(oppStageTemp.GEFUE_Account_Number__c);
            siteOpp.CloseDate = Date.valueOf(oppStageTemp.GEFUE_Close_Date__c);
            siteOpp.StageName = oppStageTemp.GEFUE_Stage__c;
            siteOpp.GEFUE_Site_Account__c = mapSiteAccountNameId.get(siteAccountNameTemp);
            siteOpp.GEFUE_Terminal__c = mapTerminalNumberId.get(oppStageTemp.GEFUE_Terminal_Number__c);
            if (oppStageTemp.GEFUE_IRR__c != NULL && oppStageTemp.GEFUE_IRR__c != '') {
                siteOpp.GEFUE_IRR__c = Decimal.valueOf(oppStageTemp.GEFUE_IRR__c)*100;
            }
            if (oppStageTemp.GEFUE_CPG_Amount__c != NULL && oppStageTemp.GEFUE_CPG_Amount__c != '') {
            	siteOpp.GEFUE_BP_CPG_Amount__c = Decimal.valueOf(oppStageTemp.GEFUE_CPG_Amount__c);
            }
            if (oppStageTemp.GEFUE_Image_Amount__c != NULL && oppStageTemp.GEFUE_Image_Amount__c != '') {
            	siteOpp.GEFUE_BP_Image_Amount__c = Decimal.valueOf(oppStageTemp.GEFUE_Image_Amount__c);
            }
            if (oppStageTemp.GEFUE_DCA_NTI__c != NULL && oppStageTemp.GEFUE_DCA_NTI__c != '') {
            	siteOpp.GEFUE_DCA_NTI__c = oppStageTemp.GEFUE_DCA_NTI__c;
            }
            lstSiteOpportunitiestoInsert.add(siteOpp);
        }
        insert lstSiteOpportunitiestoInsert;
        return lstSiteOpportunitiestoInsert;
    }
    
    /*
    * To create related products
    */
    public void createOpportunityProducts(List<GEFUE_Opportunity_Staging__c> oppStageForProducts) {
        
        Id fnaPriceBookId = [SELECT Id FROM PriceBook2 WHERE Pricebook2.Name = 'Fuels NA Price Book' LIMIT 1].Id;
        Id stdPricebookId = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1].Id;
        
        Map<String, String> mapGasDieselId = new Map<String, String>();
        List<Product2> lstProduct = [SELECT Id, Name, Description, ProductCode, CASFO_Product_Sales_Organisation__c FROM Product2 WHERE (Name='Gas' OR Name='Diesel') AND Description=NULL AND CASFO_Product_Sales_Organisation__c='0052'];
        for (Product2 prod : lstProduct) {
            mapGasDieselId.put(prod.Name, prod.Id);
        }
        
        Set<String> setProdTempId = new Set<String>(mapGasDieselId.values());
        Map<String, String> mapProductPBEId = new Map<String, String>();
        for (PriceBookEntry pbeTemp : [SELECT Id, Product2Id FROM PriceBookEntry WHERE Product2Id IN :setProdTempId AND PriceBook2Id = :fnaPriceBookId]) {
            mapProductPBEId.put(pbeTemp.Product2Id, pbeTemp.Id);
        }
        
        List<PriceBookEntry> lstPriceBookEntriesToInsert = new List<PriceBookEntry>();
        for (String prodTempId : setProdTempId) {
            if (!mapProductPBEId.containsKey(prodTempId)) {
                PricebookEntry pbStdEntry = new PricebookEntry(Pricebook2Id=stdPricebookId, Product2Id=prodTempId, UnitPrice=1.00, IsActive = true);
                PricebookEntry pbCustEntry = new PricebookEntry(Pricebook2Id=fnaPriceBookId, Product2Id=prodTempId, UnitPrice=1.00, IsActive = true);
                lstPriceBookEntriesToInsert.add(pbStdEntry);
                lstPriceBookEntriesToInsert.add(pbCustEntry);
            }
        }
        
        insert lstPriceBookEntriesToInsert;
        
        for (PriceBookEntry pbe : lstPriceBookEntriesToInsert) {
            mapProductPBEId.put(pbe.Product2Id, pbe.Id);
        }
        
        System.debug('@@# mapProductPBEId '+mapProductPBEId);
        System.debug('@@# mapGasDieselId '+mapGasDieselId);
        
        List<OpportunityLineItem> lstOppLineItemsToInsert = new List<OpportunityLineItem>();
        for (GEFUE_Opportunity_Staging__c oppStageTemp : oppStageForProducts) {
            if (oppStageTemp.GEFUE_Volume_Diesel__c != NULL && oppStageTemp.GEFUE_Volume_Diesel__c != '') {
                OpportunityLineItem lineitemDiesel = new OpportunityLineItem(
                    OpportunityId=oppStageTemp.GEFUE_Opportunity_Id__c, 
                    PriceBookEntryId=mapProductPBEId.get(mapGasDieselId.get('Diesel')), 
                    Quantity=Decimal.valueOf(oppStageTemp.GEFUE_Volume_Diesel__c),
                    Unitprice=1
                );
                lstOppLineItemsToInsert.add(lineitemDiesel);
            }
            if (oppStageTemp.GEFUE_Volume_Gas__c != NULL && oppStageTemp.GEFUE_Volume_Gas__c != '') {
                OpportunityLineItem lineitemGas = new OpportunityLineItem(
                    OpportunityId=oppStageTemp.GEFUE_Opportunity_Id__c, 
                    PriceBookEntryId=mapProductPBEId.get(mapGasDieselId.get('Gas')), 
                    Quantity=Decimal.valueOf(oppStageTemp.GEFUE_Volume_Gas__c),
                    Unitprice=1
                );
                lstOppLineItemsToInsert.add(lineitemGas);
            }
        }
        insert lstOppLineItemsToInsert;
    }
}