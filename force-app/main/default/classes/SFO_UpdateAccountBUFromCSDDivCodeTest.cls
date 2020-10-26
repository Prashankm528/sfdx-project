/***************************************************************************************************
* Description : Test class for SFO_UpdateAccountBUFromCSDDivCode
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-APR-15   1.0                 Maros Zilka         Initial version
*
***************************************************************************************************/

@isTest
private class SFO_UpdateAccountBUFromCSDDivCodeTest {
    private static final Integer BATCH_SIZE = 200;

    @TestSetup
    static void setCustomSettings() {
        CSD_Division_Code_Mapping__c mapping = new CSD_Division_Code_Mapping__c (
            Name = '0203',
            Salesforce_Value__c = 'Lubricants - Automotive'
        );

        insert mapping;
    }

    @isTest
    static void insertWithDivCode() {
        List<Account> accounts = new List<Account> ();

        for (Integer i = 0; i < BATCH_SIZE; i++) {
            Account a = new Account (Name = 'Test', CSD_DistChannelDivCode__c = '0203');

            accounts.add(a);
        }

        Test.startTest();
        insert accounts;
        Test.stopTest();

        System.assertEquals(
            BATCH_SIZE,
            [SELECT count() FROM Account WHERE Business_Unit__c = 'Lubricants - Automotive'],
            'Business Unit should be set based on custom settings.'
        );
    }

    @isTest
    static void insertWithUnkownDivCode(){
        List<Account> accounts = new List<Account> ();

        for (Integer i = 0; i < BATCH_SIZE; i++) {
            Account a = new Account (Name = 'Test', CSD_DistChannelDivCode__c = '0220');

            accounts.add(a);
        }

        Test.startTest();
        insert accounts;
        Test.stopTest();

        System.assertEquals(
            BATCH_SIZE,
            [SELECT count() FROM Account WHERE Business_Unit__c = 'Unkown'],
            'Business Unit should be set to \'Unkown\''
        );
    }

    @isTest
    static void insertWithoutDivCode() {
        List<Account> accounts = new List<Account> ();

        for (Integer i = 0; i < BATCH_SIZE; i++) {
            Account a = new Account (Name = 'Test', Business_Unit__c = 'Lubricants - Industrial');

            accounts.add(a);
        }

        Test.startTest();
        insert accounts;
        Test.stopTest();

        System.assertEquals(
            BATCH_SIZE,
            [SELECT count() FROM Account WHERE Business_Unit__c = 'Lubricants - Industrial'],
            'Business Unit should not be replaced when Div/Channel code is not set.'
        );
    }

    @isTest
    static void updateWithDivCode(){
        List<Account> accounts = new List<Account> ();

        for (Integer i = 0; i < BATCH_SIZE; i++) {
            Account a = new Account (Name = 'Test');

            accounts.add(a);
        }

        insert accounts;

        for (Account a : accounts) {
            a.CSD_DistChannelDivCode__c = '0203';
        }

        Test.startTest();
        update accounts;
        Test.stopTest();

        System.assertEquals(
            BATCH_SIZE,
            [SELECT count() FROM Account WHERE Business_Unit__c = 'Lubricants - Automotive'],
            'Business Unit should be set based on custom settings.'
        );
        
    }

    @isTest
    static void updateWithUnkownDivCode(){
        List<Account> accounts = new List<Account> ();

        for (Integer i = 0; i < BATCH_SIZE; i++) {
            Account a = new Account (Name = 'Test', CSD_DistChannelDivCode__c = '0203');

            accounts.add(a);
        }

        insert accounts;

        for (Account a : accounts) {
            a.CSD_DistChannelDivCode__c = '0220';
        }

        Test.startTest();
        update accounts;
        Test.stopTest();

        System.assertEquals(
            BATCH_SIZE,
            [SELECT count() FROM Account WHERE Business_Unit__c = 'Unkown'],
            'Business Unit should be set to \'Unkown\''
        );
    }
}