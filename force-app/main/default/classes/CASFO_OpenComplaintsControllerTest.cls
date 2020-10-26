/***************************************************************************************************
* Description : Test class for CASFO_OpenComplaintsController class which lists Accounts with too
*               many open complaint cases.
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2018-AUG-28   1.0                 Maros Zilka         Initial version
* 2018-SEP-27   1.1                 Maros Zilka         SonarCube Fixes
*
***************************************************************************************************/

@isTest
private class CASFO_OpenComplaintsControllerTest {

    private static final Integer COMPLAINTS_COUNT = 3;

    @isTest
    static void testShowWarning() {
        Boolean showWarning;

        Account acc = [SELECT Id FROM Account WHERE Name = 'Complaints'];

        Test.startTest();

        showWarning = CASFO_OpenComplaintsWarningController.showOpenComplaintsWarning(acc.Id);

        Test.stopTest();

        System.assert(showWarning, 'Show warning method should return TRUE for this account.');
    }

    @isTest
    static void testShowWarningNegative() {
        Boolean showWarning;

        Account acc = [SELECT Id FROM Account WHERE Name = 'NoComplaints'];

        Test.startTest();

        showWarning = CASFO_OpenComplaintsWarningController.showOpenComplaintsWarning(acc.Id);

        Test.stopTest();

        System.assert(!showWarning, 'Show warning method should return FALSE for this account.');
    }

    @isTest
    static void testGetAccounts() {
      	List<Account> accounts;

        Test.startTest();

        accounts = CASFO_OpenComplaintsWarningController.getAccounts();

        Test.stopTest();

        System.assert(accounts.size() == 1, 'getAccounts should return only one account.');
        System.assert(accounts[0].Name == 'Complaints', 'wrong account returned by getAccounts.');
    }

    @isTest
    static void testGetAccountsNegative() {
      	List<Account> accounts;
        List<Case> cases;

        cases = [SELECT Id FROM Case WHERE Complaint__c = TRUE];

        delete cases;

        Test.startTest();
            accounts = CASFO_OpenComplaintsWarningController.getAccounts();
        Test.stopTest();

        System.assert(accounts == null, 'There should be no accounts returned by getAccounts.');
    }

    @testSetup
    static void createData() {
        Account account;
        List<Case> cases = new List<Case>();

        account = new Account();
        account.Name = 'NoComplaints';
        insert account;

        account = new Account();
        account.Name = 'Complaints';
        insert account;

        for (Integer i = 0; i < COMPLAINTS_COUNT; i++) {
            Case c = new Case();

            c.Complaint__c = TRUE;
            c.AccountId = account.Id;

            cases.add(c);
        }

        insert cases;
    }
}