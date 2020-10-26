/**
* @author Neha Gupta
* @company Bluewolf, an IBM Company
* @date 7/2020
*
* This test class for Twilio Phone Verification Integration Classes
*/
@isTest
public class REIDP_TwilioPhoneVerificationV2Test {
    static testMethod void TestVerificationV2(){
        Test.setMock(HttpCalloutMock.class, new TwillioMockHttpResponseGenerator()); 
        String resp=REIDP_TwilioPhoneVerificationV2.VerificationV2('+91782700','VAa44abf0331f3a62384fb56fb0acfd3f9');
        System.assert(resp!=null, 'Response  is null');
    }
    
    static testMethod void TestVerificationCheckV2(){
        Test.setMock(HttpCalloutMock.class, new TwillioMockHttpResponseGenerator()); 
        String resp=REIDP_TwilioPhoneVerificationV2.VerificationCheckV2('+919982700','VAa44abf0331f3a62384fb56fb0acfd3f9','002334');
         System.assert(resp!=null, 'Response  is null');
    }
    
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