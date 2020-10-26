/**
 * @author Ksenia Potapovich
 * @company Bluewolf, an IBM Company
 * @date 04/2018
 *
 */
@isTest
private class CAIDP_LightningHelpControllerTest {

    @testSetup
    static void setup() {
        insertEmailTemplates();
    }

    @future
    static void insertEmailTemplates() {

        EmailTemplate testEmailTemplate1 = new EmailTemplate(
            isActive = true,
            Name = 'Test Email Template',
            DeveloperName = 'CAIDP_Support_Email',
            TemplateType = 'custom',
            HtmlValue = 'Test HTML',
            Body = 'Test Body',
            Subject = 'Test',
            FolderId = UserInfo.getUserId()
        );
        insert testEmailTemplate1;
    }
	
	@isTest 
    static void testGetUserEmail() {
        REIDP_TestFactory.DEFAULT_COMMUNITY = 'Castrol';
        User u = REIDP_TestFactory.createCommunityUser(CAIDP_LightningHelpControllerTest.class);
        String email = null;
		Test.startTest();
        System.runAs(u) {
            email = CAIDP_LightningHelpController.getUserEmail();
        }
        Test.stopTest();

        System.assertEquals(u.Email, email);
	}
	
	@isTest 
    static void testSendMailToSupport() {
        REIDP_TestFactory.DEFAULT_COMMUNITY = 'Castrol';
        User u = REIDP_TestFactory.createCommunityUser(CAIDP_LightningHelpControllerTest.class);
        Test.startTest();
        String result = CAIDP_LightningHelpController.sendMailToSupport('testsupport@mail.com', u.Email, 'Test', 'Test Message');
        Test.stopTest();

        System.assertEquals(null, result);
	}
	
}