/**
* @author Neha Gupta
* @company Bluewolf, an IBM Company
* @date 7/2020
*
* Twilio Phone Verification class verifies phone number and checks provided Code
* 
*/
public class REIDP_TwilioPhoneVerificationV2 {
    //This method requests for verification code for the phonenumber from twilio
    /*
Curl command for verify
curl -X POST https://verify.twilio.com/v2/Services/VAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Verifications \
--data-urlencode "To=+15017122661" \
--data-urlencode "Channel=sms" \
-u AC42357842ecd011a4c91fead4e3f2e47e:your_auth_token

*/
    public static String VerificationV2(string phonenumber,string ServiceSid){
        if(ServiceSid==null || ServiceSid=='')
            ServiceSid='DefaultTwilioAcc';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String Account_SID='{!$Credential.Username}';//tws.REIDP_Account_SID__c;//Value same for 3 twilio accounts
        String auth_token='{!$Credential.Password}';//tws.REIDP_Auth_Token__c;//Value same for 3 twilio accounts
        
        req.setEndpoint('callout:REIDP_'+ServiceSid+'/Verifications');
        //req.setEndpoint('https://verify.twilio.com/v2/Services/VA33e83e36e08752bbf4be05149230423e');
        req.setMethod('POST');
        Blob headerValue = Blob.valueOf(EncodingUtil.urlEncode(Account_SID,'UTF-8') +':' + EncodingUtil.urlEncode(auth_token,'UTF-8')); 
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        String payload='';
        payload += '&To='+ EncodingUtil.urlEncode(phonenumber,'UTF-8');
        payload += '&Channel=sms';
        req.setBody(payload);
        HTTPResponse resp = http.send(req);
        
        String responseBody = resp.getBody(); 
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        System.debug('responseMap in first class'+responseMap);
        String resCode= string.valueof(resp.getstatusCode());
        
        if(resCode.startsWith('2') && resp.getBody()!=null){
            String status = (String)responseMap.get('status');
            String responseJson='{';
            responseJson+='"success":true,';
            responseJson+='"message":'+'"Text message sent to'+phonenumber+'",';
            responseJson+='"status":'+'"'+ status +'"}'; 
            return responseJson;
        }
        else{
            String message = (String)responseMap.get('message');
            String responseJson='{';
            responseJson+='"success":false,';
            responseJson+='"message":'+'"'+ message +'"}'; 
            return responseJson;
        }
    }
    
    
    //this method validates the code received on mobile with twilio
    public static string VerificationCheckV2(string phonenumber,string ServiceSid,String Code){
        /**Curl command to check
https://www.twilio.com/docs/verify/api/verification-check
curl -X POST https://verify.twilio.com/v2/Services/VAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/VerificationCheck \
--data-urlencode "To=+15017122661" \
--data-urlencode "Code=1234" \
-u ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:your_auth_token
***/
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        if(ServiceSid==null || ServiceSid=='')
            ServiceSid='DefaultTwilioAcc';
        
        String Account_SID='{!$Credential.Username}';
        String auth_token='{!$Credential.Password}';
        
        req.setEndpoint('callout:REIDP_'+ServiceSid+'/VerificationCheck');
        req.setMethod('POST');
        Blob headerValue = Blob.valueOf(EncodingUtil.urlEncode(Account_SID,'UTF-8') +':' + EncodingUtil.urlEncode(auth_token,'UTF-8'));
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        String payload='';
        payload += '&To='+ EncodingUtil.urlEncode(phonenumber,'UTF-8');
        payload += '&Code='+EncodingUtil.urlEncode(Code,'UTF-8');
        system.debug('the request body is'+payload);
        req.setBody(payload);
        HTTPResponse resp = http.send(req);
        //return resp.getBody();
        String responseBody = resp.getBody(); 
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
       
        String resCode= string.valueof(resp.getstatusCode());
        //if(resp.getstatusCode() == 201 && resp.getbody() != null){
        if(resCode.startsWith('2') && resp.getBody()!=null && responseMap.get('status')=='Approved'){
            String status = (String)responseMap.get('status');
            String responseJson='{';
            responseJson+='"success":true,';
            responseJson+='"message":'+'"Verification code is correct",';
            responseJson+='"status":'+'"'+ status +'"}'; 
            return responseJson;
        }
       // else if(responseMap.get('status')=='Pending'){}
        else{
        
            String message = (String)responseMap.get('message');
            System.debug('message###'+message);
             
            String responseJson='{';
            responseJson+='"success":false,';
            if(message!=null)
            	responseJson+='"message":'+'"'+ message +'"}'; 
            else
            	responseJson+='"message":'+'"Code entered is not correct"}'; 
            return responseJson;
        }    
    }
}