/**
* @Who     Maros Zilka
* @when    20-09-2018
* @what    Test class for the CASFO_QBREventDeleted.
**/

@isTest()
private class CASFO_QBREventDeletedTest {

    private static final Integer ACCOUNTS_COUNT = 5;

    @testSetup
    static void createAccountContactTestData() {
        
        List<Account> testAccounts = new List<Account>();
        Account testAccount;
        
        for(Integer i = 0; i < ACCOUNTS_COUNT; i++){
            testAccount = new Account();
            testAccount.Name = 'QBR Test ' + i;
            testAccounts.add(testAccount);
        }
        insert testAccounts;
        
    }
    
    @isTest
    private static void updateAccountWhenQBRDeletedTest() 
    {
        List<Event> events = [Select Id,AccountId,CASFO_QBR_Closed__c,Type From Event Where Id IN : createEvents()];
        Test.startTest();
		delete events;
        Test.stopTest();
        
        for (Account testAccount : [SELECT Id, CASFO_QBR_Planned__c FROM Account WHERE Name LIKE 'QBR Test%']) {
            System.assert(!testAccount.CASFO_QBR_Planned__c, 'Account should not be planned.');
        }
    }
    
    private static List<Event> createEvents () {
        List<Event> events = new List<Event>();
        DateTime curretTime = DateTime.now();
        for(Account currentAccount : [Select Id,Name From Account limit :ACCOUNTS_COUNT]){
            Event e = new Event();
            e.Type = 'Quarterly Business Review';
            e.WhatId = currentAccount.Id;
            e.Subject = 'QBR meeting for ';
            e.DurationInMinutes = 60;
            e.CASFO_QBR_Closed__c = false;
            e.ActivityDateTime = curretTime;
            events.add(e);
        }
        Insert events;
        return events;
    }
}