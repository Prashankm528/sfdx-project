public with sharing class CAPL_ChangePasswordController {
	      
	@AuraEnabled
    public static String fetchUserId() {
    	return UserInfo.getUserId();
    }
    
    @AuraEnabled
    public static String changePassword(String newPassword, String verifyNewPassword, String oldpassword) {
        PageReference siteUrl =  Site.changePassword(newPassword, verifyNewPassword, oldpassword);    

        if (siteUrl != null) {
            return siteUrl.getUrl();
        } else {
            return null;
        }
    }     
}