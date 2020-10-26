/**
* @author Ragim Ragimov
* @company Bluewolf, an IBM Company
* @date 6/2017
*
* This Controller is used in Phone Verification Visualforce pages in BP Community
*/
public with sharing class REIDP_PhoneVerificationController {
    
    public String countryCode {public get;public set;}
    public String phoneNumber {public get;public set;}
    public String code {public get; public set;}
    public Boolean requireVerification {public get; private set;}
    
    public REIDP_PhoneVerificationController() {
        try {
            requireVerification = Boolean.valueOf(ApexPages.currentPage().
                                                  getParameters().
                                                  get('requireVerification'));
        }
        catch(Exception ex) {
            requireVerification = false;
        }
    }
    
    public PageReference openCodePage() {
        if(countryCode == null || countryCode == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       Label.BP_Error + ': ' + Label.BP_Please_Select_Country));
            return null;
        }
        if(phoneNumber == null || phoneNumber == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       Label.BP_Error + ': ' + Label.BP_Please_enter_valid_phone_number));                
            return null;
        }
        if(requireVerification) {
            REIDP_TwilioPhoneVerification REIDP_PhoneVerification = new REIDP_TwilioPhoneVerification();
            REIDP_TwilioPhoneVerification.Response verificationResp = REIDP_PhoneVerification.start(phoneNumber, 
                                                                                        countryCode);
            if(verificationResp.success)
                return Page.REIDP_PhoneVerificationPageTwo;
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                           Label.BP_Error + ': ' + verificationResp.message));
                return null;
            }
        }
        else
            return openConfirmedPage();
    }
    
    public PageReference openConfirmedPage() {
        if(requireVerification) {
            if(code == null || code == '' || code.length() < 4) {
                return null;
            }
            REIDP_TwilioPhoneVerification REIDP_PhoneVerification = new REIDP_TwilioPhoneVerification();
            REIDP_TwilioPhoneVerification.Response verificationResp = REIDP_PhoneVerification.check(phoneNumber, 
                                                                                        countryCode,
                                                                                        code);
            if(!verificationResp.success) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                           'Error: ' + verificationResp.message));
                return null;
            }
        }
        updateUser(requireVerification);
        return Page.REIDP_PhoneVerificationPageThree;
    }
    
    private void updateUser(Boolean verifiedPhone) {
        User currentUser = new User(Id = UserInfo.getUserId(),
                                    REIDP_Verified_Phone__c = (verifiedPhone) ? countryCode + phoneNumber : '',
                                    Phone = countryCode + phoneNumber);
        update currentUser;
    }
    
    public PageReference cancel() {
        String url = ApexPages.currentPage().getParameters().get('retURL');
        if (url == '' || url == null)
            url = '/';
        return new PageReference(url);
    }
}