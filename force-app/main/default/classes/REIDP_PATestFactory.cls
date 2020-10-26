/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
public class REIDP_PATestFactory {
    public static String accountId;
    public static User newTestUser() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String email = 'integrationtest@test.com';
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole' + System.now().getTime() +'@testorg.com');
        Account a;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, 
                            FirstName = 'TestPersonAccountFirst', 
                            LastName = 'TestPersonAccount', 
                            PersonEmail = email);
            insert a;
        }
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        accountId = a.Id;
        Profile p = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = email,
            Username = email,
            Alias = 'TestBP', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId);
        insert u;
        return u;
    }
}