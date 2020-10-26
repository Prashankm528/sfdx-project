/*****************************************************************************************
*   Date:           27JULY20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Test class to send email notification to Opportunity Owner
*   Modifications:  
****************************************************************************************/
@isTest(SeeAllData=False)
public with sharing class GEFUE_sendEmailOpportunityTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @isTest
    static void testSendEmailOppty(){
        Id brandedPackageRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded_Package').getRecordTypeId();
        
        Id brandedSiteRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        Id siteRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
        
        Test.startTest();
        
        List<Account> lstAccount = new List<Account>();
        Account testAccount = retrieveTestAccount('Test Customer Account', customerRTId);
        lstAccount.add(testAccount);
        Account testSiteAccount = retrieveTestAccount('Test Site Account1', siteRTId);
        lstAccount.add(testSiteAccount);
        Account testSiteAccount2 = retrieveTestAccount('Test Site Account 2', siteRTId);
        lstAccount.add(testSiteAccount2);
        Account testSiteAccount3 = retrieveTestAccount('Test Site Account 3', siteRTId);
        lstAccount.add(testSiteAccount3);
        Account testSiteAccount4 = retrieveTestAccount('Test Site Account 4', siteRTId);
        lstAccount.add(testSiteAccount4);
        Account testSiteAccount5 = retrieveTestAccount('Test Site Account 5', siteRTId);
        lstAccount.add(testSiteAccount5);
        Account testSiteAccount6 = retrieveTestAccount('Test Site Account 6', siteRTId);
        lstAccount.add(testSiteAccount6);
        insert lstAccount;
        
        List<Opportunity> lstOppty = new List<Opportunity>();
        Opportunity oppty1 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount.Id, Date.today().addDays(15), 10,true);
        lstOppty.add(oppty1);
        Opportunity oppty2 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount2.Id, Date.today().addDays(30), 10, true);
        lstOppty.add(oppty2);
        Opportunity oppty3 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount3.Id, Date.today().addDays(60), 10,true);
        lstOppty.add(oppty3);
        Opportunity oppty4 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount4.Id, Date.today().addDays(30), 60, true);
        lstOppty.add(oppty4);
        Opportunity oppty5 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount5.Id, Date.today().addDays(60), 60, true);
        lstOppty.add(oppty5);
        Opportunity oppty6 = InsertSiteOpp(brandedSiteRTID , testAccount.ID , testSiteAccount6.Id, Date.today().addDays(-1), 10, true);
        lstOppty.add(oppty6);
        insert lstOppty;

        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new GEFUE_SendEmailOpportunitySchedulable());
        
        System.assert(jobId != NULL, 'Opportunity job scheduled');

        Test.stopTest();
    }
    public static Account retrieveTestAccount(String accName, Id rtId) {
        Account acc = new Account(Name=accName, RecordTypeId=rtId);
        return acc;
    }
    public static Opportunity InsertSiteOpp(Id rtd , Id accID , Id siteID, Date CloseDt, Integer percent, Boolean isForecast) {
        
        Opportunity siteOpp = new Opportunity(Name = 'test oppty',
                                              StageName = 'Lead',
                                              RecordtypeID = rtd,
                                              CloseDate = CloseDt,
                                              AccountID = accID,   
                                              GEFUE_Site_Account__C = siteID,
                                              Probability = percent,
                                              GEFUE_Is_Forecasting_for_Volume__c = isForecast);
        
        return siteOpp;
    }
}