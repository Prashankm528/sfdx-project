public with sharing class ContactController {
    public ContactController() {

    }

    @AuraEnabled(cacheable = true)
    public static List<contact> getContacts(string ContactId){
        // return [SELECT Id,  FirstName, LastName, Email From Contact WITH SECURITY_ENFORCED];
        throw new AuraHandledException('Forced error');
    }
}
