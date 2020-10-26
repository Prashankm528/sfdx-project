/*****************************************************************************************
*   Date:           07MAY20
*   Author:         Abhishek Sharma – TCS (Tata Consultancy Services Ltd.)
*   Description:    Tests the code in GEFUE_Update_Site_Opportunites that copy Package Opportunites Infomation to the related Site Opportunities
*   Modifications:  
****************************************************************************************/
@isTest(SeeAllData=False)
public with sharing class GEFUE_Update_Site_OpportunitiesTest {
    
    @isTest static void testUpdateSiteCloseDate(){
        Id brandedPackageRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded_Package').getRecordTypeId();
        
        Id brandedSiteRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        Id siteRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
		
        Test.startTest();
        
        List<Account> lstAccount = new List<Account>();

        Account testAccount = retrieveTestAccount('Test Customer Account', customerRTId);
        lstAccount.add(testAccount);
	    
        Account testSiteAccount = retrieveTestAccount('Test Site Account', siteRTId);
        lstAccount.add(testSiteAccount);
        
        //Account testSiteAccount2 = retrieveTestAccount('Test Site Account 2', siteRTId);
        //lstAccount.add(testSiteAccount2);
        insert lstAccount;
        
        Opportunity testPackageOpportunity = retrievePackageOpportunity('Test Package Opportunity', brandedPackageRTID, testAccount.Id );         
        insert testPackageOpportunity;
        
        Opportunity testSiteOpportunity = retrieveSiteOpportunity('Test Site Opportunity', brandedSiteRTID, testAccount.Id, testPackageOpportunity.Id);
        insert testSiteOpportunity;
        
        GEFUE_Terminal__c testTerminal = retrieveTestTerminal('Test Terminal');
        insert testTerminal;
        
        GEFUE_Opportunity_Terminal__c  testOppTerminal = retrieveTestOpptyTerminal(testPackageOpportunity.Id,testTerminal.Id);
        insert testOppTerminal;
        
        //Opportunity opp3 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount.Id);
        
        Opportunity opp = InsertSiteOpp(brandedSiteRTID , testSiteAccount.ID , NULL);
        
        Opportunity oppty = [Select Name from Opportunity Where ID =:opp.Id];
        
        GEFUE_Update_Site_Opportunities.updateSiteCloseDate(testPackageOpportunity.Id);
         
        Test.stopTest();
        System.assertEquals(1, [Select Count() From GEFUE_Opportunity_Terminal__c Where Opportunity__c =: testPackageOpportunity.Id],'Terminal not copied to Site Opportunity' );
        system.assertequals(testPackageOpportunity.CloseDate, testSiteOpportunity.CloseDate, 'CloseDate not copied to Site Opportunity');
        System.assertEquals('Test Site Account',oppty.Name, 'Opportunity Name is not updated');
    }
	
	 @isTest static void testNegativeCriteria(){
	
	    Id brandedPackageRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded_Package').getRecordTypeId();
        
        Id brandedSiteRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        Id siteRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
	
		Account testAccount = retrieveTestAccount('Test Customer Account', customerRTId);
        insert testAccount;
        
        Account testSiteAccount = retrieveTestAccount('Test Site Account', siteRTId);
        insert testSiteAccount;
		
        Test.startTest();
		Opportunity testPackage = retrievePackageOpportunity('Test Package Opportunity', brandedPackageRTID, testAccount.Id );
        testPackage.StageName = 'EFM';
        insert testPackage;
        
        Opportunity testSite1 = retrieveSiteOpportunity('Test Site Opportunity', brandedSiteRTID, testAccount.Id, testPackage.Id);
        insert testSite1;
        
        List<GEFUE_Terminal__c> lstTerminal = new List<GEFUE_Terminal__c>();
        GEFUE_Terminal__c testTerminal = retrieveTestTerminal('Test Terminal');
        lstTerminal.add(testTerminal);
        GEFUE_Terminal__c testTerminal1 = retrieveTestTerminal('Test Terminal 1');
        lstTerminal.add(testTerminal1);
        insert lstTerminal;
         
        List<GEFUE_Opportunity_Terminal__c> lstOppTerminal = new List<GEFUE_Opportunity_Terminal__c>();
        GEFUE_Opportunity_Terminal__c  testOppTerminal = retrieveTestOpptyTerminal(testPackage.Id,testTerminal.Id);
        lstOppTerminal.add(testOppTerminal);
        GEFUE_Opportunity_Terminal__c  testOppTerminal1 = retrieveTestOpptyTerminal(testPackage.Id,testTerminal1.Id);
        lstOppTerminal.add(testOppTerminal1);
        insert lstOppTerminal;
		
        GEFUE_Update_Site_Opportunities.updateSiteCloseDate(testPackage.Id);
        Test.stopTest();
		System.assertEquals('Negotiation with Customer',testSite1.StageName , 'Site stage is updated');
        System.assertEquals(NULL, testSite1.GEFUE_Terminal__c,'Terminals are copied to site');
	}
    
    public static Opportunity retrieveSiteOpportunity(String oppName, Id rtId, String accId,Id packageOpptyID) {
        Opportunity siteOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Negotiation with Customer', CloseDate=System.today(), GEFUE_Package__c =packageOpptyID );
        return siteOpportunity;
    }
    
    public static Opportunity retrievePackageOpportunity(String oppName, Id rtId, String accId) {
        Opportunity packageOpportunity = new Opportunity(Name=oppName, RecordTypeId=rtId, AccountId=accId, StageName='Lead', CloseDate=System.today());
        return packageOpportunity;
    }
    
    public static Account retrieveTestAccount(String accName, Id rtId) {
        Account siteAccount = new Account(Name=accName, RecordTypeId=rtId);
        return siteAccount;
    }
    
    public static GEFUE_Terminal__c  retrieveTestTerminal(String tmName){
        GEFUE_Terminal__c terminal = new GEFUE_Terminal__c (Name=tmname);
        return terminal;
    }
    
    public static GEFUE_Opportunity_Terminal__c retrieveTestOpptyTerminal(Id opportunityID, Id terminalID){
        GEFUE_Opportunity_Terminal__c opptyTM = new GEFUE_Opportunity_Terminal__c(Opportunity__c =opportunityID, Terminal__c= terminalID);
        return opptyTM;
    }
    
    public static Opportunity InsertSiteOpp(Id rtd , Id accID , Id siteID) {
        
        Opportunity siteOpp = new Opportunity(Name = 'test opportunity',
                                              StageName = 'Lead',
                                              RecordtypeID = rtd,
                                              CloseDate = Date.today(),
                                              AccountID = accID,   
                                              GEFUE_Site_Account__C = siteID);
        insert siteOpp;
        return siteOpp;
    }
}