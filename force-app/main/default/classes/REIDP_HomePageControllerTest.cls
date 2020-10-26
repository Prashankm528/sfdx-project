/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 */
@isTest
public with sharing class REIDP_HomePageControllerTest {
    @isTest
    static void testLoginRedirect() {
        REIDP_HomePageController hpController = new REIDP_HomePageController();
        PageReference pref = hpController.loginRedirect();
        System.assertEquals(null, pref);
    }
    
    @isTest
    static void testChangePassword() {
        REIDP_HomePageController hpController = new REIDP_HomePageController();
        PageReference pref = hpController.changePassword();
        System.assertEquals('/changepassword', pref.getUrl());
	}
}