/**************************************************************************************************************************************
* Description : test the different scenarios to CALCF_QBR_Planned_Invocable.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 30-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CASFO_SetCallFrequencyByClasificCodeTest 
{

    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() 
    {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }
    
    @isTest
    static void SetCallFrequencyMonthlyTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount  = SFO_TestDataService.createCustomerAccount();

        Test.startTest();
        system.runAs(testUser) 
        {
            testCustomerAccount.Sales_Organisation__c = 'AU0A';
        	insert testCustomerAccount;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,Call_Frequency__c From Account Where Id =: testCustomerAccount.Id limit 1];
        System.assertEquals('Monthly', testCustomerAccount.Call_Frequency__c,'Customer Call_Frequency__c should be equal to Monthly');
    }
    
    @isTest
    static void SetCallFrequencyBIMonthlyTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount  = SFO_TestDataService.createCustomerAccount();

        Test.startTest();
        system.runAs(testUser) 
        {
            testCustomerAccount.Sales_Organisation__c = 'AU0A';
			testCustomerAccount.Classification__c = 'aub';
        	insert testCustomerAccount;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,Call_Frequency__c From Account Where Id =: testCustomerAccount.Id limit 1];
        System.assertEquals('Bi-Monthly', testCustomerAccount.Call_Frequency__c,'Customer Call_Frequency__c should be equal to Bi-Monthly');
        
    }
    
    @isTest
    static void SetCallFrequencyQuaterlyTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount  = SFO_TestDataService.createCustomerAccount();

        Test.startTest();
        system.runAs(testUser) 
        {
            testCustomerAccount.Sales_Organisation__c = 'AU0A';
			testCustomerAccount.Classification__c = 'AUC';
        	insert testCustomerAccount;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,Call_Frequency__c From Account Where Id =: testCustomerAccount.Id limit 1];
        System.assertEquals('Quarterly', testCustomerAccount.Call_Frequency__c,'Customer Call_Frequency__c should be equal to Quarterly');
    }
    
    @isTest
    static void SetCallFrequencyTelephoneTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount  = SFO_TestDataService.createCustomerAccount();

        Test.startTest();
        system.runAs(testUser) 
        {
            testCustomerAccount.Sales_Organisation__c = 'AU0A';
			testCustomerAccount.Classification__c = 'AUT';
        	insert testCustomerAccount;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,Call_Frequency__c From Account Where Id =: testCustomerAccount.Id limit 1];
        System.assertEquals('Telephone', testCustomerAccount.Call_Frequency__c,'Customer Call_Frequency__c should be equal to Telephone');
    }
}