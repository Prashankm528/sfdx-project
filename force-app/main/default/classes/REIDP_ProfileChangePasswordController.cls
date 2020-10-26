/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 3/2019
*
* This Controller is used in REIDP_modalBody Lightning component in REIDP_Profile Lightning Component
*/
public class REIDP_ProfileChangePasswordController {
    
    @AuraEnabled
    public static String changePassword(String newPassword, String verifyNewPassword, String oldpassword) {
        PageReference siteUrl = processPasswordChange(newPassword, verifyNewPassword, oldpassword);
        if (siteUrl != null) {
            return siteUrl.getUrl();
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPolicyRule() {
        return Site.getPasswordPolicyStatement();
    }
    
    private static PageReference processPasswordChange(String newPassword, String verifyNewPassword, String oldpassword) {
        
        //Set generic Profile after first Password Setup
        String profileId = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id;
        if(Site.isPasswordExpired() && oldpassword == null && UserInfo.getProfileId() != profileId) {
            Site.validatePassword(new User(Id = UserInfo.getUserId()), newPassword, verifyNewPassword);
            REIDP_UserServiceController.updateUsersIDPProfile();
        }
        
        PageReference pageRef = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        if (pageRef == null && !Test.isRunningTest())
            return null;
        
        //Revoke tokens if password was reset
        if (Site.isPasswordExpired()) {            
            REIDP_OAuthHelper.revokeTokensForUser(UserInfo.getUserId());
        }
        
        return pageRef;
    }
}