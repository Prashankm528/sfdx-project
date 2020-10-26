/**************************************************************************************************************************************
* Description : test the different scenarios to  CASFO Swiss Integration.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 29-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CASFO_SwissIntegrationTest 
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }

    @isTest
    static void eventIsPlannedTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount;
        List<Account> accountList  = SFO_TestDataService.createCustomerAccounts(4);

        Test.startTest();
        system.runAs(testUser) 
        {
            accountList[0].Alternate_Customer_Name__c = 'Alternate Customer Name';
            accountList[0].Sales_Organisation__c = 'CH01';
            accountList[1].Alternate_Customer_Name__c = 'Alternate Customer Name 1';
			accountList[1].CASFO_Customer_Service_Level__c = 'Silber';
            accountList[1].Sales_Organisation__c = 'CH01';
            accountList[2].Alternate_Customer_Name__c = 'Alternate Customer Name 2';
			accountList[2].CASFO_Customer_Service_Level__c = 'GOLD';
            accountList[2].Sales_Organisation__c = 'CH01';
			accountList[3].Alternate_Customer_Name__c = 'Alternate Customer Name 3';
			accountList[3].CASFO_Customer_Service_Level__c = 'Platin';
            accountList[3].Sales_Organisation__c = 'CH01';
        	insert accountList;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,Alternate_Customer_Name__c,Name From Account Where Id =: accountList[0].Id limit 1];
        System.assertEquals(testCustomerAccount.Alternate_Customer_Name__c, testCustomerAccount.Name,'Customer Name should be equal to customer Alternate_Customer_Name__c');
        testCustomerAccount = [Select Id,Classification__c From Account Where Id =: accountList[1].Id limit 1];
        System.assert(testCustomerAccount.Classification__c.contains('Silver'),'Customer Classification should be equal to Silver');
        testCustomerAccount = [Select Id,Classification__c From Account Where Id =: accountList[2].Id limit 1];
        System.assert(testCustomerAccount.Classification__c.contains('Gold'), 'Customer Classification should be equal to Gold');
        testCustomerAccount = [Select Id,Classification__c From Account Where Id =: accountList[3].Id limit 1];
        System.assert(testCustomerAccount.Classification__c.contains('Platinum'), 'Customer Classification should be equal to Platinum');
        
    }
    
}