/**
 * @author Ragim Ragimov
 * @company Bluewolf, an IBM Company
 * @date 6/2017
 *
 * A test class for ChangePassword Controller
 */
@IsTest public with sharing class REIDP_ChangePasswordControllerTest {
    @IsTest 
    public static void testIncorrectPass() {
        REIDP_ChangePasswordController controller = new REIDP_ChangePasswordController();
        controller.oldPassword = '';
        controller.newPassword = 'Qwerty'; 
        controller.verifyNewPassword = 'Qwerty1';
        controller.getPasswordPolicyStatement();
        System.assertEquals(null, controller.changePassword());                           
    }   
    
    @IsTest
    public static void testCorrectPass() {      
        REIDP_ChangePasswordController controller = new REIDP_ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'Qwerty9876%'; 
        controller.verifyNewPassword = 'Qwerty9876%';
        controller.getPasswordPolicyStatement();
        System.assertEquals(null, controller.changePassword());                           
    } 
    
    @IsTest
    public static void testDeleteTokens() {      
        REIDP_ChangePasswordController controller = new REIDP_ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'Qwerty9876%'; 
        controller.verifyNewPassword = 'Qwerty9876%';
        controller.getPasswordPolicyStatement();
        System.assertEquals(controller.changePassword(),null);                           
    } 
    
    @isTest
    static void testCancel() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_ChangePassword;
        Test.setCurrentPage(pageRef);
        REIDP_ChangePasswordController cpController = new REIDP_ChangePasswordController();
        PageReference pref = cpController.cancel();
        System.assertEquals('/', pref.getUrl());
        Test.stopTest();
    }
    
    @isTest
    static void testPageTitle() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_ChangePassword;
        Test.setCurrentPage(pageRef);
        REIDP_ChangePasswordController cpController = new REIDP_ChangePasswordController();
        System.assertEquals(Label.site.change_password, cpController.pageTitle);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchUserId() {
        System.assert(UserInfo.getUserId() == REIDP_ChangePasswordController.fetchUserId());
    }
    
    @isTest
    static void testLightningChangePassword() {
        System.assertEquals(null,
                            REIDP_ChangePasswordController.changePassword('Qwerty9876$', 'Qwerty9876$', '123456'));
    }
    
}