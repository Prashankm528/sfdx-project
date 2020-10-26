/**************************************************************************************************************************************
* Description : test the different scenarios to  CASFO_Set_FWSSupergroupOpportunity.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 05-05-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private  class CASFO_SetFWSSupergroupOpportunityTest 
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
    static void isFWSSGTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        testOpportunity.recordTypeId = returnOpportunityRecordTypeId('FWS SG') ;
		
        Test.startTest();
        	insert testOpportunity;       
        Test.stopTest();   
        
        testOpportunity = [Select Id,CASFO_FWS_supergroup_opportunity__c from Opportunity Where Id =:testOpportunity.Id];
        system.assert(testOpportunity.CASFO_FWS_supergroup_opportunity__c,'supergroup opportunity value should be true');
    }
    
    @isTest
    static void isGeneralTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        testOpportunity.recordTypeId = returnOpportunityRecordTypeId('General') ;

        Test.startTest();
        	insert testOpportunity;       
        Test.stopTest();        
        
        testOpportunity = [Select Id,CASFO_FWS_supergroup_opportunity__c from Opportunity Where Id =:testOpportunity.Id];
        system.assert(!testOpportunity.CASFO_FWS_supergroup_opportunity__c,'supergroup opportunity value should be false');
    }
    
    private static ID returnOpportunityRecordTypeId(String RTName)
    {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}