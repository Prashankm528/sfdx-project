public with sharing class AccountContact {
    @AuraEnabled(cacheable=true)
    public static list<contact> getAccountContacts( string accId) {
        return [select Id , FirstName, LastName  from contact where accountId=:accId ];
    }
}