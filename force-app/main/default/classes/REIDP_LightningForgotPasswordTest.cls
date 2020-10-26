/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 */
@IsTest(SeeAllData = true)
public with sharing class REIDP_LightningForgotPasswordTest {
    
    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(REIDP_LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.IDPInvalidEmail);
        System.assertEquals(REIDP_LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.IDPEnterEmailRequired);
        System.assertEquals(REIDP_LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.IDPInvalidEmail);
    }
    
    /* Verifies that null checkEmailRef url throws proper exception. */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(REIDP_LightningForgotPasswordController.forgotPassword('a', null), Label.IDPInvalidEmail);
        System.assertEquals(REIDP_LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
    }
    
    /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        REIDP_LightningForgotPasswordController controller = new REIDP_LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
    
    @isTest
    static void testForgotPasswordPhoneFailCountryCode() {
        System.assertEquals(Label.IDPPhoneCountryCodeRequired, REIDP_LightningForgotPasswordController.forgotPasswordPhone(null, '518741769', 'http://a.com'));
    }
    
    @isTest
    static void testForgotPasswordPhoneFailPhoneNumber() {
        System.assertEquals(Label.IDPPhoneNumberRequired, REIDP_LightningForgotPasswordController.forgotPasswordPhone('1', null, 'http://a.com'));
    }
    
    @isTest
    static void testForgotPasswordPhoneInvalid() {
        System.assertEquals(Label.IDPInvalidPhoneNumber, REIDP_LightningForgotPasswordController.forgotPasswordPhone('asd', '1234567890', 'http://a.com'));
    }
    
    @isTest
    static void testForgotPasswordPhoneSuccess() {
        User cUser = REIDP_TestFactory.createCommunityPhoneNumberUser();

        //Exctracting phone number from Username
        List<String> phoneNumber = cUser.Username.split('@').get(0).split('\\.');
        System.assertEquals(null, REIDP_LightningForgotPasswordController.forgotPasswordPhone(phoneNumber[0],phoneNumber[1], 'http://a.com'));
    }
    
}