/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 6/2017
*
*/
@isTest
public class REIDP_CommunityEmailControllerTest {
    
    @isTest
    static void testCommunityBaseUrl() { 
        REIDP_CommunityEmailController.NETWORK_URL_PATH_PREFIX = 'BP';
        Network n = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = :REIDP_CommunityEmailController.NETWORK_URL_PATH_PREFIX LIMIT 1];
        URL uri = new URL(Network.getLoginUrl(n.Id));
        
        String communityBaseUrl = 'https://' + uri.getHost();
        
        if(uri.getPath().startsWith('/' + n.UrlPathPrefix + '/'))
            communityBaseUrl += '/' + n.UrlPathPrefix;
        System.assertEquals(communityBaseUrl, REIDP_CommunityEmailController.communityBaseUrl);
    }
    
    @isTest
    static void testForgotPasswordLink() {
        System.assertEquals(REIDP_CommunityEmailController.communityBaseUrl + '/s/login/ForgotPassword', REIDP_CommunityEmailController.forgotPasswordUrl);
    }
    
    @isTest
    static void testSelfRegisterLink() {
        System.assertEquals(REIDP_CommunityEmailController.communityBaseUrl + '/s/login/SelfRegister', REIDP_CommunityEmailController.selfRegisterUrl);
    }
    
    @isTest
    static void testInvalidUserUserCountry() {
        REIDP_CommunityEmailController ceController = new REIDP_CommunityEmailController();
        ceController.cId = 'invalidId';
        System.assertEquals('NULL', ceController.userCountry);
    }
    
    @isTest
    static void testValidUserCountry() {
        REIDP_CommunityEmailController ceController = new REIDP_CommunityEmailController();
        System.runAs(createTestUser()) {
            User u = new User(Id = UserInfo.getUserId(), REIDP_Country_Of_App__c = 'UK');
            update u;
            u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            ceController.cId = u.ContactId;
        }
        System.assertEquals('UK', ceController.userCountry);
    }
    
    @isTest
    static void testValidCustomMergeFields() {
        System.assertEquals(new Map<String, String>{'webservice' => 'New Service Name'}, REIDP_CommunityEmailController.customMergeFields);
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
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, 
                            FirstName = 'TestPersonAccountFirst', 
                            LastName = 'TestPersonAccount', 
                            PersonEmail = email);
            insert a;
        }
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        Profile p = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstNameCommunityEmail',
            LastName = 'TestFirstNameCommunityEmail',
            Email = email,
            Username = email,
            Alias = 'TestBP', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId);
        return u;
    }
    
}