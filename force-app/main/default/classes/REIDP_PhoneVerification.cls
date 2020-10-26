/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 7/2017
*@modified by Neha Gupta
@date 7/20
* This web service wraps Twilio AUTHY PHONE VERIFICATION API (https://www.twilio.com/docs/api/authy/authy-phone-verification-api)
* 
*/
@RestResource(urlMapping='/phoneVerification/*')
global class REIDP_PhoneVerification {
    global class REIDP_PhoneVerificationRequest {
        public String countryCode;
        public String phoneNumber;
        public String code;
        public String sid;
        
    }
    
    global class REIDP_PhoneVerificationResponse {
        public String message;
        public Boolean success;
        
        public REIDP_PhoneVerificationResponse(String message, Boolean success) {
            this.message = message;
            this.success = success;
            
        }
        
        public REIDP_PhoneVerificationResponse(REIDP_TwilioPhoneVerification.Response resp) {
            message = resp.message;
            success = resp.success;
        }
    }
    
    @HttpPost
    global static REIDP_PhoneVerificationResponse start(REIDP_PhoneVerificationRequest reqData) {
        reqData.countryCode = REIDP_UserServices.formatCountryCode(reqData.countryCode);
        reqData.phoneNumber = REIDP_UserServices.formatPhoneNumber(reqData.phoneNumber);
        // check if given phone already in use
        String num = reqData.countryCode + reqData.phoneNumber;
       /* if(num != '') { 
           REIDP_PhoneVerificationResponse res =UniquePhoneNumberCheck(num);
            if(res.success == false)
                return res;
        }*///uncomment this block for unique number
          num='+'+num;
        RestContext.request.addHeader('Accept', 'application/json');
        RestContext.response.addHeader('Content-Type', 'application/json');
       /* REIDP_TwilioPhoneVerification REIDP_PhoneVerification = new REIDP_TwilioPhoneVerification();
        REIDP_TwilioPhoneVerification.Response verificationResp = REIDP_PhoneVerification.start(reqData.phoneNumber, 
                                                                                                reqData.countryCode
        																						);
        return new REIDP_PhoneVerificationResponse(verificationResp);*/
        REIDP_TwilioPhoneVerificationV2 REIDP_PhoneVerification = new REIDP_TwilioPhoneVerificationV2();
        string verificationResp = REIDP_TwilioPhoneVerificationV2.VerificationV2(num,reqData.sid); 
        System.debug('response in phone verification'+(REIDP_PhoneVerificationResponse) JSON.deserialize(verificationResp, REIDP_PhoneVerificationResponse.Class));
        return (REIDP_PhoneVerificationResponse) JSON.deserialize(verificationResp, REIDP_PhoneVerificationResponse.Class);
    }
    
 
    
    @HttpPut
    global static REIDP_PhoneVerificationResponse check(REIDP_PhoneVerificationRequest reqData) {
         REIDP_PhoneVerificationResponse res;
        reqData.countryCode = REIDP_UserServices.formatCountryCode(reqData.countryCode);
        reqData.phoneNumber = REIDP_UserServices.formatPhoneNumber(reqData.phoneNumber);
        // check if given phone already in use
        String num = reqData.countryCode + reqData.phoneNumber;
       /* if(num != '') {
       		res =UniquePhoneNumberCheck(num);
            if(res.success == false)
                return res;
        }*///uncomment this block for unique number
         num='+'+num;
        RestContext.request.addHeader('Accept', 'application/json');
        RestContext.response.addHeader('Content-Type', 'application/json');
       /* REIDP_TwilioPhoneVerification phoneVerification = new REIDP_TwilioPhoneVerification();
        REIDP_TwilioPhoneVerification.Response verificationResp = phoneVerification.check(reqData.phoneNumber, 
                                                                                          reqData.countryCode,
                                                                                          reqData.code);*/
        // REIDP_TwilioPhoneVerificationV2 REIDP_PhoneVerification = new REIDP_TwilioPhoneVerificationV2();
        string verificationResp = get(num,reqData.sid,reqData.code); 
        res=(REIDP_PhoneVerificationResponse) JSON.deserialize(verificationResp, REIDP_PhoneVerificationResponse.Class);
       
        if(res.success) {
            User currentUser = new User(Id = UserInfo.getUserId(),
                                        REIDP_Verified_Phone__c = reqData.countryCode + reqData.phoneNumber,
                                        Phone = reqData.countryCode + reqData.phoneNumber);
            try {
                update currentUser;
            }
            catch(Exception ex) {
                REIDP_ErrorHandling.logCriticalErrorLog(REIDP_PhoneVerification.class, 'Error updating User after phone verification', ex);
            }
        }
        //return new REIDP_PhoneVerificationResponse(verificationResp);
         return (REIDP_PhoneVerificationResponse) JSON.deserialize(verificationResp, REIDP_PhoneVerificationResponse.Class);
    }
    
     public static String get(string phonenumber,string ServiceSid,String Code) {
        return REIDP_TwilioPhoneVerificationV2.VerificationCheckV2(phonenumber,ServiceSid,Code);
    }
    
   /* public static REIDP_PhoneVerificationResponse UniquePhoneNumberCheck(String num){
      
            List<User> foundUsers = [SELECT Id FROM User WHERE REIDP_Verified_Phone__c=:num AND isActive=True];
            if(foundUsers.size() > 0) {
                RestContext.response.statuscode = 409;
                return new REIDP_PhoneVerificationResponse(Label.BP_Error + ': ' + Label.BPDuplicatePhone, false);
            }
        	else
            {
                RestContext.response.statuscode = 201;
                return new REIDP_PhoneVerificationResponse('No Duplicate Phone Number', false);
            }
         
    }*/
}