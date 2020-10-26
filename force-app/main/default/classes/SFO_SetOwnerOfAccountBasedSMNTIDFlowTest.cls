/**************************************************************************************************************************************
* Description : test the different scenarios to Set_Owner_of_Account_Based_on_Sales_Manager_NTID.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 2020-JAN-09   1.0                 Ignacio Sarmiento       Initial version
***************************************************************************************************************************************/
@isTest (SeeAllData=false)
private with sharing class SFO_SetOwnerOfAccountBasedSMNTIDFlowTest {
    private static final String UNASSIGNED_USER_USERNAME = Label.SFO_UnassignedUserUsername;
    private static final String ACCOUNT_INTEGRATION_USER_USERNAME = Label.SFO_AccountIntegrationUserUsername;
    private static final String USERNAME_TEST_SUFFIX = Label.SFO_UsernameTestSuffix;

    @testSetup
    static void setup() {
        List<User> accountIntegrationUsers = SFO_TestDataService.getUsers(ACCOUNT_INTEGRATION_USER_USERNAME + SFO_TestDataService.SandboxUsernameSuffix);
        if(accountIntegrationUsers.isEmpty()){
            User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
            accountIntegrationUserToInsert.username = ACCOUNT_INTEGRATION_USER_USERNAME + USERNAME_TEST_SUFFIX;
            insert accountIntegrationUserToInsert;
        }

        List<User> unassignedUsers = SFO_TestDataService.getUsers(UNASSIGNED_USER_USERNAME + SFO_TestDataService.SandboxUsernameSuffix);
        if(unassignedUsers.isEmpty()){
            User unassignedUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
            unassignedUserToInsert.username = UNASSIGNED_USER_USERNAME + USERNAME_TEST_SUFFIX;
            insert unassignedUserToInsert;
        }
    }

    @isTest
    static void accountWithoutNTIDTest() {
        User accountIntegrationUser = SFO_TestDataService.getUserLike(ACCOUNT_INTEGRATION_USER_USERNAME);
        String accountName = 'Account without NTID';

        Account accountToInsert = new Account(
                Name = accountName,
                Sales_Manager_NTID__c = ''
        );
        system.runAs(accountIntegrationUser) {
            Test.startTest();
            insert accountToInsert;
            Test.stopTest();
        }

        String searchedAccountName = accountName + '%';
        List<Account> insertedAccounts = [SELECT Id, Name, OwnerId FROM Account WHERE Id =: accountToInsert.Id AND OwnerId =: SFO_TestDataService.getUserLike(UNASSIGNED_USER_USERNAME).Id];
        system.assertEquals(1, insertedAccounts.size(), 'Should be 1 inserted account with unassigned user as owner');
    }

    @isTest
    static void accountWithExistingNTIDTest() {
        String accountName = 'Account with NTID';
        String castrolUserNTID = 'ntidtest1';
        User accountIntegrationUser = SFO_TestDataService.getUserLike(ACCOUNT_INTEGRATION_USER_USERNAME);

        User castrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        castrolUser.NTID__c = castrolUserNTID;
        insert castrolUser;

        Account accountToInsert = new Account(
                Name = accountName ,
                Sales_Manager_NTID__c = castrolUserNTID
        );
        system.runAs(accountIntegrationUser) {
            Test.startTest();
            insert accountToInsert;
            Test.stopTest();
        }

        List<Account> insertedAccounts = [SELECT Id, Name, OwnerId FROM Account WHERE Id =: accountToInsert.Id AND OwnerId =: castrolUser.Id];
        system.assertEquals(1, insertedAccounts.size(), 'Should be 1 inserted account with castrol user as owner');
    }

    @isTest
    static void accountWithMultipleNTIDsTest() {
        String accountName = 'Account with multiple NTIDs';
        User multipleNTIDTestUser = SFO_TestDataService.createMultipleNTIDTestUser();
        insert multipleNTIDTestUser;

        User accountIntegrationUser = SFO_TestDataService.getUserLike(ACCOUNT_INTEGRATION_USER_USERNAME);
        Account accountToInsert = new Account(
                Name = accountName,
                Sales_Manager_NTID__c = SFO_TestDataService.MULTIPLE_NTID_TEST_USER_SECOND_NTID
        );
        system.runAs(accountIntegrationUser) {
            Test.startTest();
            insert accountToInsert;
            Test.stopTest();
        }

        List<Account> insertedAccounts = [SELECT Id, Name, OwnerId FROM Account WHERE Id =: accountToInsert.Id AND OwnerId =: multipleNTIDTestUser.Id];
        system.assertEquals(1, insertedAccounts.size(), 'Should be 1 inserted account with multiple NTID user as owner');
    }
}