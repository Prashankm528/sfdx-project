/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 8/2018
 *
 * Twilio Custom SMS class allows custom messages to be sent via SMS
 * 
 */
public class REIDP_TwilioCustomSMS extends REIDP_TwilioVerificationResource{
    
    private String getSMSCredentialNameSandbox() {
        return 'callout:REIDP_TwilioSMSSandbox';
    }
    
    private String getSMSCredentialNameProduction() {
        return 'callout:REIDP_TwilioSMSProduction';
    }
    
    public REIDP_TwilioCustomSMS.Response send(String phoneNumber, String countryCode, String customMessage) {
        REIDP_TwilioParams params = new REIDP_TwilioParams();
        params.setAttribute('phone_number', phoneNumber);
        params.setAttribute('country_code', countryCode);
        params.setAttribute('via', verificationMethod);
        params.setAttribute('custom_message', customMessage);
        String response = post(VERIFICATION_API_PATH + VERIFICATION_START_PATH, params);
        return (REIDP_TwilioCustomSMS.Response) JSON.deserialize(response, REIDP_TwilioCustomSMS.Response.Class);
    }
    
    public class Response extends REIDP_TwilioVerificationResource.Response {}
}