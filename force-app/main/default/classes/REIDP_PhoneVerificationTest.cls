/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 6/2017
 *
 * This test class for Twilio Phone Verification Web Service
 */
@isTest
public with sharing class REIDP_PhoneVerificationTest {
    @isTest
    static void testREIDP_PhoneVerificationStart() {
        Test.setMock(HttpCalloutMock.class, new TwillioMockHttpResponseGenerator());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/REIDP_PhoneVerification';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_PhoneVerification.REIDP_PhoneVerificationRequest reqData = new REIDP_PhoneVerification.REIDP_PhoneVerificationRequest();
        reqData.countryCode = 'countryCode';
        reqData.phoneNumber = 'phoneNumber';
        reqData.sid = 'sid';
     	REIDP_PhoneVerification.REIDP_PhoneVerificationResponse resp = REIDP_PhoneVerification.start(reqData);
        System.assertEquals(true, resp.success);        
        System.assertEquals('Text message sent to+', resp.message);
    }
    
    @isTest
    static void testREIDP_PhoneVerificationCheckFail() {
        Test.setMock(HttpCalloutMock.class, new TwillioMockHttpResponseGenerator());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/REIDP_PhoneVerification';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_PhoneVerification.REIDP_PhoneVerificationRequest reqData = new REIDP_PhoneVerification.REIDP_PhoneVerificationRequest();
        reqData.countryCode = 'countryCode';
        reqData.phoneNumber = 'phoneNumber';
        reqData.sid = 'sid';
        reqData.code = 'code';
     	REIDP_PhoneVerification.REIDP_PhoneVerificationResponse resp = REIDP_PhoneVerification.check(reqData);
        System.assertEquals(false, resp.success);        
        //System.assertEquals('Verification code is correct', resp.message);
    }
    
   /* @isTest
    static void testREIDP_PhoneVerificationControllerPhoneAlreadyInUse() {
        User u = REIDP_TestFactory.createCommunityUser(REIDP_PhoneVerificationTest.class);
        String num = '+0091 ';
        String phone = '420 ';
        u.REIDP_Verified_Phone__c = '91420';
        update u;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/REIDP_PhoneVerification';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_PhoneVerification.REIDP_PhoneVerificationRequest reqData = new REIDP_PhoneVerification.REIDP_PhoneVerificationRequest();
        reqData.countryCode = countryC;
        reqData.phoneNumber = phone;
        reqData.sid = 'sid';
     	REIDP_PhoneVerification.REIDP_PhoneVerificationResponse resp = REIDP_PhoneVerification.UniquePhoneNumberCheck(num);
        System.assertEquals(false, resp.success);        
        System.assertEquals(Label.BP_Error + ': ' + Label.BPDuplicatePhone, resp.message);
    }
    
    @isTest
    static void testREIDP_PhoneVerificationCheckSuccess() {
        Test.setMock(HttpCalloutMock.class, new TwillioMockHttpResponseGenerator());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/REIDP_PhoneVerification';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_PhoneVerification.REIDP_PhoneVerificationRequest reqData = new REIDP_PhoneVerification.REIDP_PhoneVerificationRequest();
        reqData.countryCode = '+1';
        reqData.phoneNumber = '234567890';
        reqData.sid = 'sid';
        reqData.code = 'code';
     	REIDP_PhoneVerification.REIDP_PhoneVerificationResponse resp = REIDP_PhoneVerification.check(reqData);
        //System.assertEquals(true, resp.success);        
        System.assertEquals('Verification code is correct', resp.message);
    }*/
    
     public class TwillioMockHttpResponseGenerator implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        { 
           
            // Create a fake response 
            string fulljson ='{\"status\":\"pending\"}';
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/xml'); 
            res.setBody(fulljson); 
            res.setStatusCode(200); 
            return res; 
        } 
    
    } 
    
}