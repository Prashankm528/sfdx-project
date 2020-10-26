/**************************************************************************************************************************************
* Description : test the different scenarios to  CASFO_QBR_Overdue_Notification.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 29-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CASFO_QBROverdueNotificationTest
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }
    @isTest
    static void chatFeedItemTest()
    {
        
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount  = SFO_TestDataService.createCustomerAccount();

        Test.startTest();
        system.runAs(testUser) 
        {
            testCustomerAccount.CASFO_QBR_Overdue_Notification__c = true;
            insert testCustomerAccount;
        }
		Test.stopTest();
        FeedItem fItem = [Select Id,Body,ParentId from FeedItem Where ParentId =:testCustomerAccount.Id];
        system.assertEquals(testCustomerAccount.Id,fItem.ParentId,'ParentId value of FeedItem should be equal to testCustomerAccount.Id' );
        system.assert(fItem.Body.contains('Quarterly Business Review is still not planned for'));
    }
}