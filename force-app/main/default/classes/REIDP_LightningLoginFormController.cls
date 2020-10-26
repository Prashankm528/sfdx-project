/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 7/2017
*
*/
global without sharing class REIDP_LightningLoginFormController {
    
    public static final String PASSWORD_STATUS_LOCKOUT = 'Password Lockout';
    public static final String PASSWORD_STATUS_INCORRECT = 'Invalid Password';
    public static final String LOCKOUT_EMAIL_TYPE = 'Lockout';
    public static final String PASSWORD_POLICY = 'BPPasswordPolicy';
    
    public class LoginOptions {
        @AuraEnabled
        public Boolean email;
        @AuraEnabled
        public Boolean phone;
        @AuraEnabled
        public Boolean emailDefault;
        
        public LoginOptions(Boolean email, Boolean phone, Boolean emailDefault) {
            this.email = email;
            this.phone = phone;
            this.emailDefault = emailDefault;
        }
    }
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        if (String.isEmpty(username)) {
            return Label.IDPEnterUsername;
        }
        if (String.isEmpty(password)) {
            return Label.IDPEnterPassword;
        }
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            
            List<User> user = [SELECT Id, Email, IsActive FROM User WHERE Username =:username];
            
            if (!user.isEmpty()) {
                REIDP_Password_Policy__mdt passwordPolicy = [SELECT Lockout_Effective_Period__c, Maximum_Invalid_Login_Attempts__c 
                                                             FROM REIDP_Password_Policy__mdt 
                                                             WHERE DeveloperName =:PASSWORD_POLICY];
                List<UserLogin> loginInfo = [SELECT IsPasswordLocked, isFrozen, LastModifiedDate FROM UserLogin WHERE UserId =:user[0].Id LIMIT 1];
                Integer maxLoginAttempts = Integer.valueOf(passwordPolicy.Maximum_Invalid_Login_Attempts__c);
                List<LoginHistory> lhlist = [SELECT UserId, Status, LoginTime FROM LoginHistory
                                             WHERE UserId =:user[0].Id
                                             ORDER BY LoginTime DESC LIMIT :(maxLoginAttempts * 2)];
                
                String loginError = getLoginError(user[0], loginInfo, lhlist, passwordPolicy);
                if (loginError != null) {
                    return loginError;
                }
                else if (!user[0].IsActive) {
                    return Label.IDPUserInactive;
                }
            }
            return Label.IDPLoginError;
        }
    }
    
    @AuraEnabled
    public static String loginPhone(String countryCode, String phoneNumber, String password, String startUrl) {
        if (phoneNumber == null || String.isEmpty(phoneNumber)) {
            return Label.IDPPhoneNumberRequired;
        }
        if (countryCode == null || String.isEmpty(countryCode)) {
            return Label.IDPPhoneCountryCodeRequired;
        }
        return login(REIDP_UserServices.formatMobileUsername(countryCode, phoneNumber), password, startUrl);
    }
    
    public static String getLoginError(User u, List<UserLogin> loginInfo, List<LoginHistory> lhlist, REIDP_Password_Policy__mdt passwordPolicy) {
        
        if (loginInfo != null && !loginInfo.isEmpty() && loginInfo[0].IsPasswordLocked) {
            if (lhlist[0].Status == PASSWORD_STATUS_INCORRECT) {
                sendEmail(u.Id, u.Email);
            }
            return string.format(Label.IDPPasswordLockout, new String[]{String.valueOf(Integer.valueOf(passwordPolicy.Lockout_Effective_Period__c))});
        } 
        else if (lhlist != null && !lhlist.isEmpty() && lhlist[0].Status == PASSWORD_STATUS_INCORRECT) {
            
            // get the number of incorrect passwords in a row
            Integer totalNumOfFailedLogins = 0;
            for(LoginHistory lh : lhlist) {
                if(lh.Status != PASSWORD_STATUS_INCORRECT)
                    break;
                totalNumOfFailedLogins++;
            }
            
            Integer numOfFailedLogins = Math.mod(totalNumOfFailedLogins, Integer.valueOf(passwordPolicy.Maximum_Invalid_Login_Attempts__c));
            return string.format(Label.IDPInvalidPassword, new String[]{String.valueOf(Integer.valueOf(passwordPolicy.Maximum_Invalid_Login_Attempts__c-numOfFailedLogins))});
        }
        return null;
    }
    
    public static List<Messaging.SendEmailResult> sendEmail(Id userId, String userEmail) {
        
        List<Messaging.SendEmailResult> result;
        
        try {
            
            String networkName = 'BP';
            try {
                Network n = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
                networkName = n.UrlPathPrefix;
            } catch(Exception e){}
            
            REIDP_Community_Email_Template__mdt communityEmailTemplates = [SELECT DeveloperName, Organization_Wide_Address__c 
                                                                           FROM REIDP_Community_Email_Template__mdt 
                                                                           WHERE Community_Name__c = :networkName AND Type__c = :LOCKOUT_EMAIL_TYPE];
            
            List <Messaging.Email> emails = new List<Messaging.Email>();
            List <OrgWideEmailAddress> owas = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address = :communityEmailTemplates.Organization_Wide_Address__c];
            
            
            //User Lockout Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: communityEmailTemplates.DeveloperName];
            
            mail.setTemplateID(emailTemplate.Id);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(userId);
            if(owas.size() > 0)
                mail.setOrgWideEmailAddressId(owas[0].id);
            emails.add(mail);
            
            
            //Revoke User Tokens email
            List<User> uList = [SELECT Id FROM User WHERE Username = 'revokeusertoken@bp.com.reidpserviceuser'];
            if(uList.size() > 0) {
                Messaging.SingleEmailMessage tokenRevokeMail = new Messaging.SingleEmailMessage();
                tokenRevokeMail.setSaveAsActivity(false);
                tokenRevokeMail.setTargetObjectId(uList.get(0).Id);
                tokenRevokeMail.setPlainTextBody(userId);
                tokenRevokeMail.setHtmlBody('');
                tokenRevokeMail.setSubject(userId);
                
                if(owas.size() > 0)
                    tokenRevokeMail.setOrgWideEmailAddressId(owas[0].id);
                emails.add(tokenRevokeMail);    
            }
            else {
                REIDP_ErrorHandling.logCriticalErrorLog(REIDP_LightningLoginFormController.class, 'revokeusertoken@bp.com.reidpserviceuser does not exist');
            }
            
            
            result = Messaging.sendEmail(emails);
            
        } catch (Exception e) {
            REIDP_ErrorHandling.logWarningErrorLog(REIDP_LightningLoginFormController.class, 'Error sending email during user lockout', e);
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }
    
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        try {            
            REIDP_Community_Experience_Settings__mdt communityExpSettings = [SELECT Id, Experience__c, Hide_Registration_Link__c 
                                                                             FROM REIDP_Community_Experience_Settings__mdt 
                                                                             WHERE Experience__c = :Site.getExperienceId() 
                                                                             LIMIT 1];
            
            return communityExpSettings.Hide_Registration_Link__c != null ? !communityExpSettings.Hide_Registration_Link__c : authConfig.getSelfRegistrationEnabled();
            
        } catch (Exception e) {}
        
        return authConfig.getSelfRegistrationEnabled();
    }
    
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        String regUrl;
        try {            
            REIDP_Community_Experience_Settings__mdt communityExpSettings = [SELECT Id, Experience__c, Registration_Link__c 
                                                                             FROM REIDP_Community_Experience_Settings__mdt WHERE Experience__c = :Site.getExperienceId() 
                                                                             LIMIT 1];
            if (communityExpSettings.Registration_Link__c != null) {
                return communityExpSettings.Registration_Link__c;
            }
        } catch (Exception e) {}
        
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            regUrl = authConfig.getSelfRegistrationUrl();
        }
        return regUrl;
    }
    
    @AuraEnabled
    public static LoginOptions getLoginOption() {
        try {
            REIDP_Community_Experience_Settings__mdt communityExpSettings = [SELECT Id, 
                                                                             Experience__c, 
                                                                             Available_Login_Option__c
                                                                             FROM REIDP_Community_Experience_Settings__mdt 
                                                                             WHERE Experience__c = :Site.getExperienceId() 
                                                                             LIMIT 1];
            
            if(String.isBlank(communityExpSettings.Available_Login_Option__c))
                return null;
            
            LoginOptions loginOpt;
            
            if(communityExpSettings.Available_Login_Option__c.equals(REIDP_Constants.AvailableLoginOption.EMAIL_AND_PHONE.name())) {
                loginOpt = new LoginOptions(true, true, true);
            }
            else if(communityExpSettings.Available_Login_Option__c.equals(REIDP_Constants.AvailableLoginOption.EMAIL_ONLY.name())) {
                loginOpt = new LoginOptions(true, false, true);
            }
            else if(communityExpSettings.Available_Login_Option__c.equals(REIDP_Constants.AvailableLoginOption.PHONE_ONLY.name())) {
                loginOpt = new LoginOptions(false, true, false);
            }
            else if(communityExpSettings.Available_Login_Option__c.equals(REIDP_Constants.AvailableLoginOption.PHONE_AND_EMAIL.name())) {
                loginOpt = new LoginOptions(true, true, false);
            }
            return loginOpt;
            
        } catch (Exception e) {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig() {
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
}