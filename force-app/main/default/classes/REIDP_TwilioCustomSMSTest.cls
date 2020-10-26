/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 8/2018
 *
 * This test class for Twilio Custom SMS Integration Classes
 */
@isTest
public class REIDP_TwilioCustomSMSTest {
    
    @isTest
    static void testSend() {
        Test.startTest();
        REIDP_TwilioCustomSMS customSMS = new REIDP_TwilioCustomSMS();
        REIDP_TwilioCustomSMS.Response resp = customSMS.send('testNumber', 'testCountryCode', 'test message');
        Test.stopTest();
        System.assertEquals(false, resp.success);        
        System.assertEquals('TEST', resp.message);
    }
}