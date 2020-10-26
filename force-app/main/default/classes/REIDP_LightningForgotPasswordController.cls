/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 7/2017
*
*/
global class REIDP_LightningForgotPasswordController {
    
    public REIDP_LightningForgotPasswordController() {
        
    }
    
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            // email is empty/null validation
            if (String.isEmpty(username) || String.isBlank(username)) {
				return Label.IDPEnterEmailRequired;
            }

            if(!Site.isValidUsername(username)) {
                return Label.IDPInvalidEmail;
            }

            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);

            checkEmailRef.getParameters().put('type', 'email');
            aura.redirect(checkEmailRef);
            
            return null;
        }
        catch (Exception ex) {
            REIDP_ErrorHandling.logCriticalErrorLog(REIDP_LightningForgotPasswordController.class, 'Error during password reset', ex);
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String forgotPasswordPhone(String countryCode, String phoneNumber, String checkEmailUrl) {
        if (phoneNumber == null || String.isEmpty(phoneNumber)) {
            return Label.IDPPhoneNumberRequired;
        }
        if (countryCode == null || String.isEmpty(countryCode)) {
            return Label.IDPPhoneCountryCodeRequired;
        }
        if(!Site.isValidUsername(REIDP_UserServices.formatMobileUsername(countryCode, phoneNumber))) {
            return Label.IDPInvalidPhoneNumber;
        }
        try {
            List<User> usersToProcess = new List<User>([SELECT Id, Username, REIDP_Default_Community__c FROM User WHERE Username = :REIDP_UserServices.formatMobileUsername(countryCode, phoneNumber) LIMIT 1]);
            if (usersToProcess.size() > 0) {
                REIDP_ResetMobileUserPassword resetPassword = new REIDP_ResetMobileUserPassword(usersToProcess, true);
                
                ID jobID = System.enqueueJob(resetPassword);
            }
            if(!Test.isRunningTest()) {
                ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                checkEmailRef.getParameters().put('type', 'phone');
                aura.redirect(checkEmailRef);
            }
            
            return null;
        } catch (Exception ex) {
            REIDP_ErrorHandling.logCriticalErrorLog(REIDP_LightningForgotPasswordController.class, 'Error during password reset', ex);
            return ex.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static String getUserType(String urlPath) {
        ApexPages.PageReference tabName = new PageReference(urlPath);
        return tabName.getParameters().get('type');
    }
}