/**************************************************************************************************************************************
* Description : test the different scenarios to  CASFO_SetNegativeRevenue.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 05-05-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CASFO_SetNegativeRevenueTest 
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
    static void isRevenueDemandReductionRTTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
		insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        insert testOpportunity;
		Product2 testProduct =  SFO_TestDataService.createCastrolTestProducts(1)[0];
        insert testProduct;
        Revenue__c oppRevenue  = SFO_TestDataService.createOpportunityRevenue(testOpportunity.Id,testProduct.Id);
        
        Test.startTest();
        system.runAs(testUser) 
        {
            oppRevenue.recordTypeId = returnRecordTypeId('Demand Reduction');
            oppRevenue.Margin__c = 2000;
            oppRevenue.Revenue__c = 200;
            oppRevenue.Volume__c = 30;
            insert oppRevenue;
        }
        Test.stopTest();
        oppRevenue = [Select Id,Margin__c,Revenue__c,Volume__c from Revenue__c Where Id =:oppRevenue.Id];
        system.assertEquals(-2000,oppRevenue.Margin__c,'oppRevenue.Margin__c value should be equal to -2000' );
        system.assertEquals(-200,oppRevenue.Revenue__c,'oppRevenue.Revenue__c value should be equal to -200' );
        system.assertEquals(-30,oppRevenue.Volume__c,'oppRevenue.Volume__c value should be equal to -30' );
    }
    
    private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Revenue__c.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}