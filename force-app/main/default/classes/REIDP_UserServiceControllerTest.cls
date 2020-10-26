/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 4/2018
 *
 */
@isTest
public class REIDP_UserServiceControllerTest {
    
    @isTest
    static void testProcessRequest() {
        
        Id uId;
        System.runAs(createTestUser()) {
            uId = UserInfo.getUserId();
        }
        PageReference pageRef = Page.REIDP_UserService;
        pageRef.getParameters().put('userId', uId);
        Test.setCurrentPage(pageRef);
        REIDP_UserServiceController controller = new REIDP_UserServiceController();
        
        Test.startTest();
        controller.processRequest();
        Test.stopTest();
        User u = [SELECT Id, Profile.Name FROM User WHERE Id = :uid];
        System.assertEquals(REIDP_Constants.GENERAL_IDP_PROFILE_NAME, u.Profile.Name);                           
    }
    
    @isTest
    static void testGetBaseURL() {
        System.assertNotEquals(null, REIDP_UserServiceController.getBaseURL());                           
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
        String profileName = '';
        for(String pName : REIDP_Constants.SET_OF_WELCOME_PROFILE_NAMES) {
            profileName = pName;
            break;
        }
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User(
            FirstName = 'testFirstName',
            LastName = 'testLastName',
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