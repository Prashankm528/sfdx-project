/**************************************************************************************************************************************
* Description : test the different scenarios to CASFO_RemindOpportunityOwnerOfContractExpiry.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 28-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CASFO_RemindOppOwnerOfContractExpiryTest 
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() {
        
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }
    
    @isTest
    static void RemindOppOwnerOfContractExpiry90Days()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity;
        Test.startTest();
        system.runAs(testUser) 
        {
            testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
            testOpportunity.CloseDate = Date.today();
            testOpportunity.Contract_End_Date__c =  Date.today().addDays(10);
            testOpportunity.StageName = 'Closed - Won';
            insert testOpportunity;
        }
        Test.stopTest();
        System.debug([Select Id,isClosed,Contract_End_Date__c,CloseDate From Opportunity Where Id =: testOpportunity.Id limit 1]);
        
        List<FlowInterview> flowInterviews = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews.size(),'FlowInterviews count should be equal to 1');
        
    }
    
    @isTest
    static void RemindOppOwnerOfContractExpiry180Days()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity;
        Test.startTest();
        system.runAs(testUser) 
        {
            testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
            testOpportunity.CloseDate = Date.today();
            testOpportunity.Contract_End_Date__c =  Date.today().addDays(181);
            testOpportunity.StageName = 'Closed - Won';
            insert testOpportunity;
        }
        Test.stopTest();
        Opportunity oppTest = [Select Id,isClosed,Contract_End_Date__c,CloseDate From Opportunity Where Id =: testOpportunity.Id limit 1];
        List<FlowInterview> flowInterviews = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews.size(),'FlowInterviews count should be equal to 1');
    }
    
    @isTest
    static void RemindOppOwnerOfContractExpiry90DaysBatchTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        List<Account> testCustomerAccountList = SFO_TestDataService.createCustomerAccounts(5);
        insert testCustomerAccountList;
        List<Opportunity> testOpportunityList = new List<Opportunity>();
        Test.startTest();
        system.runAs(testUser) 
        {
            for(Account testAccount : testCustomerAccountList)
            {
                Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testAccount.Id);
                testOpportunity.CloseDate = Date.today();
                testOpportunity.Contract_End_Date__c =  Date.today().addDays(90);
                testOpportunity.StageName = 'Closed - Won';                
                testOpportunityList.add(testOpportunity);
                Opportunity testOpportunity2 = SFO_TestDataService.createCastrolOpportunity(testAccount.Id);
                testOpportunity2.CloseDate = Date.today();
                testOpportunity2.Contract_End_Date__c =  Date.today().addDays(170);
                testOpportunity2.StageName = 'Closed - Won';                
                testOpportunityList.add(testOpportunity2);
            }
            insert testOpportunityList;
        }
        Test.stopTest();
       
        List<FlowInterview> flowInterviews = [SELECT Id FROM FlowInterview];
        System.assertEquals(testOpportunityList.size(), flowInterviews.size(),'FlowInterviews count should be equal to number of opportunity records');
        
    }
    
}