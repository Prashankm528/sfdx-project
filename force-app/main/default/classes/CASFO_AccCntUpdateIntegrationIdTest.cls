/***************************************************************************************************
* Description : Unit Tests for the CASFO_Update_Integration_Id_on_Account_Contact_Relation Process Builder
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2016-SEP-20   1.0                 Grant Whitfield     Initial version
* 2016-NOV-15   1.1                 Grant Whitfield     Test data updated to include
*                                                       Integration_Id__c & Contact_Siebel_Id__c
* 2018-SEP-27   1.2                 Maros Zilka         SonarCube Fixes
* 2019-JAN-30	1.3					Maros Zilka			Added methods to fully cover flow
*
***************************************************************************************************/

@isTest
private class CASFO_AccCntUpdateIntegrationIdTest {

    private static final Integer ACCOUNTS_COUNT = 400;

    @testSetup
    static void createAccountContactTestData() {
        List<Account> testAccounts = new List<Account>();
        List<Contact> testContacts = new List<Contact>();
        
        Integer i;

        for(i = 0; i < ACCOUNTS_COUNT; i++){
            Account testAccount = new Account();

            testAccount.Name = 'Test Account ' + i;
            testAccount.Integration_Id__c = 'IntId' + i;
            testAccounts.add(testAccount);
        }

        insert testAccounts;
        
        // loop through the accounts in the system and add a contact
        i = 0;
        
        for(Account acc : testAccounts) {

            Contact testContact = new Contact();

            testContact.FirstName = 'Test';
            testContact.LastName = 'Test'  + i;
            testContact.AccountId = acc.Id;
            testContact.Contact_Siebel_Id__c = '1-' + i;
            testContacts.add(testContact);

            i++;
        }

        // insert testContacts list (will test trigger in bulk)
        insert testContacts;
    }

    /**********************************************************************
    * test_integration_id_populated
    * ------------------------
    * Method to check that the Account Contact Relationship Integration Id
    * is populated
    ***********************************************************************/
    @isTest
    static void accountContactRealtionshipIntegrationIdIsPopulated() {
		String expectedIntegrationId;
        
        // return all of the Accounts from the system
        List<Account> testAccountList = [SELECT Id FROM Account];

        // confirm the correct number of records
        system.assertEquals(testAccountList.size(), ACCOUNTS_COUNT);

        // confirm the correct number of contacts have been inserted
        List<Contact> testContactList = [SELECT ID, Name FROM Contact];

        // confirm the correct number of records
        system.assertEquals(testContactList.size(), ACCOUNTS_COUNT);

        // after insert of contacts, check the account contact relationship object
        List<AccountContactRelation> testAccountContactRelationList = [
            SELECT ID, Integration_Id__c, Account.Integration_Id__c, Contact.Contact_Siebel_Id__c
            FROM AccountContactRelation
            ];

        system.assertEquals(testAccountContactRelationList.size(), ACCOUNTS_COUNT);

        // loop the list of account contact relationships
        for (AccountContactRelation acr : testAccountContactRelationList) {
            expectedIntegrationId = acr.Account.Integration_Id__c + '_' + acr.Contact.Contact_Siebel_Id__c;
            system.assert(acr.Integration_Id__c == expectedIntegrationId);
        }
    }
    
    /**********************************************************************
    * Account integration Id changed
    ***********************************************************************/
    
    @isTest
    static void accountIntegrationIdChanged() {
        Integer i;
        String expectedIntegrationId;
        
        // return all of the Accounts from the system
        list<Account> testAccountList = [SELECT Id FROM Account];

        // confirm the correct number of records
        system.assertEquals(testAccountList.size(), ACCOUNTS_COUNT);

        // confirm the correct number of contacts have been inserted
        list<Contact> testContactList = [SELECT ID, Name FROM Contact];

        // confirm the correct number of records
        system.assertEquals(testContactList.size(), ACCOUNTS_COUNT);

        // after insert of contacts, check the account contact relationship object
        list<AccountContactRelation> testAccountContactRelationList = [
            SELECT Id, Integration_Id__c, Account.Integration_Id__c, Contact.Contact_Siebel_Id__c
            FROM AccountContactRelation
            ];

        // confirm that relationship records have been created
        system.assertEquals(testAccountContactRelationList.size(), ACCOUNTS_COUNT);

        // loop the list of account contact relationships
        
        for (AccountContactRelation acr : testAccountContactRelationList) {
            expectedIntegrationId = acr.Account.Integration_Id__c + '_' + acr.Contact.Contact_Siebel_Id__c;
            system.assert(acr.Integration_Id__c == expectedIntegrationId);
        }
        
        i = 0;
        
        for (Account acc : testAccountList) {
            acc.Integration_Id__c = 'ChangedIntId' + i;
            
            i++;
        }
        
        update testAccountList;
        
        testAccountContactRelationList = [
            SELECT Id, Integration_Id__c, Account.Integration_Id__c, Contact.Contact_Siebel_Id__c
            FROM AccountContactRelation
        ];
        
       	for (AccountContactRelation acr : testAccountContactRelationList) {
            expectedIntegrationId = acr.Account.Integration_Id__c + '_' + acr.Contact.Contact_Siebel_Id__c;
            system.assert(acr.Integration_Id__c == expectedIntegrationId);
        }
    }
    
    @isTest
    static void contactIntegrationIdChanged() {
        Integer i;
        String expectedIntegrationId;
        
        // return all of the Accounts from the system
        list<Account> testAccountList = [SELECT Id FROM Account];

        // confirm the correct number of records
        system.assertEquals(testAccountList.size(), ACCOUNTS_COUNT);

        // confirm the correct number of contacts have been inserted
        list<Contact> testContactList = [SELECT ID, Name FROM Contact];

        // confirm the correct number of records
        system.assertEquals(testContactList.size(), ACCOUNTS_COUNT);

        // after insert of contacts, check the account contact relationship object
        list<AccountContactRelation> testAccountContactRelationList = [
            SELECT Id, Integration_Id__c, Account.Integration_Id__c, Contact.Contact_Siebel_Id__c
            FROM AccountContactRelation
            ];

        // confirm that relationship records have been created
        system.assertEquals(testAccountContactRelationList.size(), ACCOUNTS_COUNT);

        // loop the list of account contact relationships
        
        for (AccountContactRelation acr : testAccountContactRelationList) {
            expectedIntegrationId = acr.Account.Integration_Id__c + '_' + acr.Contact.Contact_Siebel_Id__c;
            system.assert(acr.Integration_Id__c == expectedIntegrationId);
        }
        
        i = 0;
        
        for (Contact c : testContactList) {
            c.Contact_Siebel_Id__c = 'ChangedIntId' + i;
            
            i++;
        }
        
        update testAccountList;
        
        testAccountContactRelationList = [
            SELECT Id, Integration_Id__c, Account.Integration_Id__c, Contact.Contact_Siebel_Id__c
            FROM AccountContactRelation
        ];
        
       	for (AccountContactRelation acr : testAccountContactRelationList) {
            expectedIntegrationId = acr.Account.Integration_Id__c + '_' + acr.Contact.Contact_Siebel_Id__c;
            system.assert(acr.Integration_Id__c == expectedIntegrationId);
        }
    }
}