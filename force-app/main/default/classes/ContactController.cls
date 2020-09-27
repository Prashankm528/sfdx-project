public with sharing class ContactController {
    
    @AuraEnabled(cacheable=true)
    public static list<contact> getContacts(){
        return [SELECT FirstName, LastName, Email FROM Contact];    
        
    }
}