public with sharing class getDetails {
   
    @AuraEnabled(Cacheable = true)
    public static string getDetailsByCaseId(id caseId){
        return [select id, Contact.name From case where id =:caseId].contact.name;
        
    }

  /*  @AuraEnabled
    public static Void createContact(List<string> str){
        contact c= new contact();
        c.FirstName = str[0].firstname;
        c.LastName = str[0].lastName;
        c.Email = str[0].emailValue;
        c.Phone = str[0].Phone;

        insert c;
        system.debug('contact is' +c);

        
    }*/
   
}
