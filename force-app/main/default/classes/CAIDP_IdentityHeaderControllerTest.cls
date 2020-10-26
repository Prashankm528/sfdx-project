@isTest
private class CAIDP_IdentityHeaderControllerTest {

    private static String DEFAULT_COMMUNITY = 'Castrol';

    @testSetup
    static void setup() {

        insertEmailTemplates();
    }

    @future
    static void insertEmailTemplates() {

        EmailTemplate testEmailTemplate1 = new EmailTemplate(
            IsActive = true,
            Name = 'Test Email Template',
            DeveloperName = 'CAIDP_New_Member_Activated',
            TemplateType = 'visualforce',
            Markup = '<messaging:emailTemplate subject="Test"><messaging:plainTextEmailBody >activation</messaging:plainTextEmailBody></messaging:emailTemplate>',
            ApiVersion = 40.0,
            FolderId = UserInfo.getUserId()
        );
        insert testEmailTemplate1;
    }
    
    @isTest 
    static void fetchUserIdTest() {
        REIDP_TestFactory.DEFAULT_COMMUNITY = DEFAULT_COMMUNITY;
        Id uId = REIDP_TestFactory.createCommunityUser(CAIDP_IdentityHeaderControllerTest.class).Id;
        Test.startTest();
           String userId = CAIDP_IdentityHeaderController.fetchUserId();
        Test.stopTest();

        System.assertNotEquals(userId, null);
    }
    
    @isTest 
    static void fetchUserNameTest() {
        REIDP_TestFactory.DEFAULT_COMMUNITY = DEFAULT_COMMUNITY;
        Id uId = REIDP_TestFactory.createCommunityUser(CAIDP_IdentityHeaderControllerTest.class).Id;
        Test.startTest();
           String userId = CAIDP_IdentityHeaderController.fetchUserName();
        Test.stopTest();

        System.assertNotEquals(userId, null);
    }

    @isTest 
    static void fetchCommunityHomeUrlTest() {
        REIDP_TestFactory.DEFAULT_COMMUNITY = DEFAULT_COMMUNITY;
        String homeURL;
        User u = REIDP_TestFactory.createCommunityUser(CAIDP_IdentityHeaderControllerTest.class);
        System.runAs(u) {
            homeURL = CAIDP_IdentityHeaderController.fetchCommunityHomeUrl();
        }
        System.assertNotEquals(homeURL, null);
    }

    @isTest
    static void sendActivationEmailTest() {
        REIDP_TestFactory.DEFAULT_COMMUNITY = DEFAULT_COMMUNITY;
        Id userId = REIDP_TestFactory.createCommunityUser(CAIDP_IdentityHeaderControllerTest.class).Id;
        User testUser = [
            SELECT Email 
            FROM User
            WHERE Id = :userId
        ];
        Integer emailLimits = 0;
        Test.startTest();
        System.runAs(testUser) {
            CAIDP_IdentityHeaderController.sendActivationEmail();
            emailLimits = Limits.getEmailInvocations();
        }
        Test.stopTest();

        System.assertEquals(1, emailLimits);
    }
    
}