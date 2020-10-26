/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * Twilio Phone Verification class starts verification and checks provided Code
 * 
 */
public class REIDP_TwilioPhoneVerification extends REIDP_TwilioVerificationResource {
    
    private String getSMSCredentialNameSandbox() {
        return 'callout:REIDP_TwilioVerificationSandbox';
    }
    
    private String getSMSCredentialNameProduction() {
        return 'callout:REIDP_TwilioVerificationProduction';
    }
    
    public REIDP_TwilioPhoneVerification.Response start(String phoneNumber, String countryCode) {
        return start(phoneNumber, countryCode, verificationMethod);
    } 
    
    public REIDP_TwilioPhoneVerification.Response start(String phoneNumber, String countryCode, String via) {
        return start(phoneNumber, countryCode, via, null);
    }
    
    public REIDP_TwilioPhoneVerification.Response start(String phoneNumber, String countryCode, String via, REIDP_TwilioParams params) {
        if(params == null)
            params = new REIDP_TwilioParams();
        params.setAttribute('phone_number', phoneNumber);
        params.setAttribute('country_code', countryCode);
		params.setAttribute('via', via);
		params.setAttribute('code_length', codeLength);
        String response = post(VERIFICATION_API_PATH + VERIFICATION_START_PATH, params);
        return (REIDP_TwilioPhoneVerification.Response) JSON.deserialize(response, REIDP_TwilioPhoneVerification.Response.Class);
    }
    
    public REIDP_TwilioPhoneVerification.Response check(String phoneNumber, String countryCode, String code) {
        REIDP_TwilioParams tParams = new REIDP_TwilioParams();
        tParams.setAttribute('phone_number', phoneNumber);
        tParams.setAttribute('country_code', countryCode);
        tParams.setAttribute('verification_code', code);
        String response = get(VERIFICATION_API_PATH + VERIFICATION_CHECK_PATH, tParams);
        return (REIDP_TwilioPhoneVerification.Response) JSON.deserialize(response, REIDP_TwilioPhoneVerification.Response.Class);
    }
    
    public class Response extends REIDP_TwilioVerificationResource.Response {}
}