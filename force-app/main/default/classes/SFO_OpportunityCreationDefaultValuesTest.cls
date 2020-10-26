/**************************************************************************************************************************************
* Description : test the different scenarios to  SFO_OpportunityCreationDefaultValues.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 05-05-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class SFO_OpportunityCreationDefaultValuesTest 
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
    static void isProspectTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        testCustomerAccount.recordTypeId = returnAccountRecordTypeId('Prospect') ;
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
		
        Test.startTest();
        	insert testOpportunity;       
        Test.stopTest();   
        
        testOpportunity = [Select Id,Customer_Type__c from Opportunity Where Id =:testOpportunity.Id];
        system.assertEquals('Prospect Customer', testOpportunity.Customer_Type__c,'Opportunity customer type should be equal to Prospect Customer');
    }
    
    @isTest
    static void isCustomerTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        testCustomerAccount.recordTypeId = returnAccountRecordTypeId('Customer') ;
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);

        Test.startTest();
        	insert testOpportunity;       
        Test.stopTest();        
        
        testOpportunity = [Select Id,Customer_Type__c from Opportunity Where Id =:testOpportunity.Id];
        system.assertEquals('Existing Customer', testOpportunity.Customer_Type__c,'Opportunity customer type should be equal to Existing Customer');
    }
    
    private static ID returnAccountRecordTypeId(String RTName)
    {
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }

}