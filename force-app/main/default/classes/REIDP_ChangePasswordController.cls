/**
* @author Ragim Ragimov
* @company Bluewolf, an IBM Company
* @date 6/2017
*
* This Controller is used in ChangePassword Visualforce page and ChangePassword Lightning Component
*/
public with sharing class REIDP_ChangePasswordController {
    
    private static User u = [SELECT Id, REIDP_Return_App__c FROM User WHERE Id =: UserInfo.getUserId()];
    
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    public String pageTitle {
        get {
            if (Site.isPasswordExpired()) {
                return Label.IDPNewPasswordTitle;
            } else {
                return Label.IDPChangePassword;
            } 
        }
        set;
    }
    
    public REIDP_ChangePasswordController() {
        /**
        * IE11 Compatibility Mode Fix
        * https://msdn.microsoft.com/en-us/library/ff955275(v=vs.85).aspx
        */
        
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=11; IE=edge');
        
        /**
        * END
        */
    }

    @future(Callout = true)
    private static void scheduleProfileChange() {
        REIDP_UserServiceController.updateUsersIDPProfile();
    }
    
    private static PageReference processPasswordChange(String newPassword, String verifyNewPassword, String oldpassword) {
        
        //Set generic Profile after first Password Setup
        String profileId = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id;
        Boolean isInitialSetup = false;
        if(Site.isPasswordExpired() && oldpassword == null && UserInfo.getProfileId() != profileId) {
            Site.validatePassword(new User(Id = UserInfo.getUserId()), newPassword, verifyNewPassword);
            isInitialSetup = true;

            try {
                REIDP_UserServiceController.updateUsersIDPProfile();
            } catch (Exception ex) {
                //Proceed further and schedule profile switch
                scheduleProfileChange();
            }
        }
        
        PageReference pageRef = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        if (pageRef == null && !Test.isRunningTest())
            return null;
        
        //Revoke tokens if password was reset
        if (Site.isPasswordExpired() && !isInitialSetup) {            
            REIDP_OAuthHelper.revokeTokensForUser(UserInfo.getUserId());
        }
        
        return pageRef;
    }
    
    public PageReference changePassword() {
        /**
        * IE11 Compatibility Mode Fix
        * https://msdn.microsoft.com/en-us/library/ff955275(v=vs.85).aspx
        */
        
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=11; IE=edge');
        
        /**
        * END
        */
        
        String regex = '^.{10,}$';
        Boolean errorOccured = false;
        if (!Site.isPasswordExpired()) {
            if (oldPassword == null || oldPassword == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.BPInvalidOldPassword));
                errorOccured = true;
            }
        }
        if (!Pattern.matches(regex, newPassword)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.BPInvalidNewPassword));
            errorOccured = true;
        }
        if (newPassword != verifyNewPassword) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDPPasswordNotMatch));
            errorOccured = true; 
        }

        if (errorOccured == false) {
            PageReference pageRef = processPasswordChange(newPassword, verifyNewPassword, oldpassword);
            
            if(pageRef == null && !Test.isRunningTest())
                return null;

            return performRedirection(pageRef);
        } else {
            return null;
        }   
        
    }
    
    @AuraEnabled
    public String getPasswordPolicyStatement() {
        return Site.getPasswordPolicyStatement();
    }   
    
    public PageReference cancel() {
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=11; IE=Edge');
        
        return performRedirection(new PageReference('/'));
    }
    
    @AuraEnabled
    public static String fetchUserId() {
        return UserInfo.getUserId();
    }
    
    @AuraEnabled
    public static String changePassword(String newPassword, String verifyNewPassword, String oldpassword) {
        PageReference siteUrl = processPasswordChange(newPassword, verifyNewPassword, oldpassword);
        
        siteUrl = performRedirection(siteUrl);
        
        if (siteUrl != null)
            return siteUrl.getUrl();   
        
        return null;
    }
    
    private static PageReference performRedirection(PageReference pageRef) {
        String expId = null;
        
        //Get expirience id settings from Site
        if(!Test.isRunningTest() && Site.getExperienceId() != null)
            expId = Site.getExperienceId();
        
        //Get expirience id settings from URL and override Site settings
        if(!String.isEmpty(ApexPages.currentPage().getParameters().get('expId')))
            expId = ApexPages.currentPage().getParameters().get('expId');
        
        //Get Expirience Id from Return App Field
        if(!String.isBlank(u.REIDP_Return_App__c)) {
            expId = u.REIDP_Return_App__c;
            
            //Clean up return URL on user to prevent redirection next time
            u.REIDP_Return_App__c = null;
            update u;
        }
        
        List<REIDP_Community_Experience_Settings__mdt> appUrls = [SELECT Return_URL__c, Change_Password_Return_URL__c
                                                                  FROM REIDP_Community_Experience_Settings__mdt 
                                                                  WHERE Experience__c =: expId LIMIT 1]; 
        // (Return_URL__c != null OR Change_Password_Return_URL__c != null) cannot be filtered because disjunction is not supported for custom metadata obj
        
        if(appUrls.isEmpty()) {
            //Process retURL parameter if expId parameter is null and Expirience Id is not set
            String url = ApexPages.currentPage().getParameters().get('retURL');
            if(String.isEmpty(url)) {
                return pageRef;    
            }
            return new PageReference(url);
        }
        
        REIDP_Community_Experience_Settings__mdt expSettings = appUrls.get(0);
        
        //Redirect to Return_URL__c after Registration or Password Reset
        if(Site.isPasswordExpired() && !String.isEmpty(expSettings.Return_URL__c))
            return new PageReference(expSettings.Return_URL__c);
        
        //Redirect to Change_Password_Return_URL__c after successful Password Change
        if(!Site.isPasswordExpired() && !String.isEmpty(expSettings.Change_Password_Return_URL__c))
            return new PageReference(expSettings.Change_Password_Return_URL__c);

        // if expid is set but no Return_URL__c or Change_Password_Return_URL__c is not set, redirects to Home page of community.
        return pageRef;
    }
}