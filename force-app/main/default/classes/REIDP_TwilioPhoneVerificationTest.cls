/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 6/2017
 *
 * This test class for Twilio Phone Verification Integration Classes
 */
@isTest
public with sharing class REIDP_TwilioPhoneVerificationTest {
    
    @isTest
    static void testREIDP_PhoneVerificationStart() {
        Test.startTest();
        REIDP_TwilioPhoneVerification phoneVerif = new REIDP_TwilioPhoneVerification();
        REIDP_TwilioPhoneVerification.Response resp = phoneVerif.start('testNumber', 'testCountryCode');
        Test.stopTest();
        System.assertEquals(false, resp.success);
        System.assertEquals('TEST', resp.message);
    }
    
    @isTest
    static void testREIDP_PhoneVerificationCheck() {
        Test.startTest();
        REIDP_TwilioPhoneVerification phoneVerif = new REIDP_TwilioPhoneVerification();
        REIDP_TwilioPhoneVerification.Response resp = phoneVerif.check('testNumber', 'testCountryCode', 'testCode');
        Test.stopTest();
        System.assertEquals(false, resp.success);        
        System.assertEquals('TEST', resp.message);
    }
    
    @isTest
    static void testREIDP_PhoneVerificationWithCustomSettings() {
        Test.startTest();
        REIDP_TwilioPhoneVerification phoneVerif = new REIDP_TwilioPhoneVerification();
        REIDP_TwilioPhoneVerification.Response resp = phoneVerif.start('testNumber', 'testCountryCode', 'testVia');
        Test.stopTest();
        System.assertEquals(false, resp.success);        
        System.assertEquals('TEST', resp.message);
    }
}