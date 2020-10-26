/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 */
@isTest 
public class REIDP_FastTrackPluginTest {
    
    @isTest
    static void testFastTrackPlugin() {
        Test.startTest();
        System.runAs(createTestUser()){
            REIDP_FastTrackPlugin plg = new REIDP_FastTrackPlugin();
            Map<String, String> caMap = plg.customAttributes(UserInfo.getUserId(), null, new Map<String, String>(), null);
            System.assertEquals('FTTestSiteName01', caMap.get('sitename'));
            System.assertEquals('Street 1, City, zipCode', caMap.get('address'));
            System.assertEquals('America/Los_Angeles', caMap.get('timezone'));
        }
        Test.stopTest();
    }
    
    
    
    private static User createTestUser()
    {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String email = 'UserPermissionSetTest@email' + UserInfo.getOrganizationId() + '.com';
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole@testclass_bp'+System.currentTimeMillis()+'.com');
        Account a;
        Contact c;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Business Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, 
                            Name = 'FTTestSiteName01',
                           	BillingStreet = 'Street 1',
                            BillingCity = 'City',
                           	BillingPostalCode = 'zipCode');
            insert a;
            c = new Contact(AccountId = a.Id,
                            FirstName = 'fName',
                            LastName = 'lName');
            insert c;
        }
        Profile p = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = email,
            Username = email,
            Alias = 'TestBP', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = c.Id);
        return u;
    }
}