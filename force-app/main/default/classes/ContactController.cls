public with sharing class ContactController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [
            SELECT Id, FirstName, LastName, Title, Phone, Email
            FROM Contact
            WITH SECURITY_ENFORCED order by createdDate desc
            limit 10 
            
        ];
    }
    @AuraEnabled
    public static list<contact> addContact(Contact con){
        system.debug('contact' + con);
        insert con;
        return [
            SELECT Id, FirstName, LastName, Title, Phone, Email
            FROM Contact
            WITH SECURITY_ENFORCED order by createdDate desc
            limit 10 
            
        ];
    } 

/*
    @AuraEnabled
    public static list<contact> addContact( string FirstName , string LastName , string Email ,
    string Gender, string Department ){
        system.debug('LastNAme'+LastName);
        system.debug('LastNAme'+FirstName);
        contact c  = new contact();
        c.FirstName = FirstName;
        c.LastName = Lastname ;
        c.Email = Email;
        c.Gender__c =  Gender;
        c.Department__c = Department;
        insert c;

        return [
            SELECT Id, FirstName, LastName, Title, Phone, Email, Gender__c, Department__c
            FROM Contact
            WITH SECURITY_ENFORCED order by createdDate desc
            limit 10 
            
        ];
    } */
}