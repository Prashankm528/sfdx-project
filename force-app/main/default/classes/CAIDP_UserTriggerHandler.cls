public with sharing class CAIDP_UserTriggerHandler {
    
    private static String COMMUNITY_PROFILE = 'RE IDP External Identity';
    public static final String EMAIL_TYPE = 'Deactivated';
    
    private static Profile castrolProfile {
        get {
            if(castrolProfile == null)
                castrolProfile = [SELECT Id FROM Profile WHERE Name = :COMMUNITY_PROFILE LIMIT 1];
            return castrolProfile;
        }
        set;
    }
    
    static public void handleAfterUpdate(List<User> newUsers, Map<Id, User> oldUsers) {
        
        List<User> toUsers = new List<User>();
        Map<String, List<Id>> communityMap = new Map<String, List<Id>>();
        
        for (User currUser : newUsers) {
            if (currUser.ProfileId == castrolProfile.Id 
                && String.isNotEmpty(currUser.REIDP_Default_Community__c)
                && !currUser.IsActive 
                && currUser.IsActive != oldUsers.get(currUser.Id).IsActive) {
                    toUsers.add(currUser);
                    if (!communityMap.containsKey(currUser.REIDP_Default_Community__c)) {
                        communityMap.put(currUser.REIDP_Default_Community__c, new Id[2]);
                    }
                }
        }
        
        if (!toUsers.isEmpty()) {
            
            Map<String, String> emailTemplateMap = new Map<String, String>();
            Map<String, String> addressTemplateMap = new Map<String, String>();
            for (REIDP_Community_Email_Template__mdt emailSetting : [
                SELECT DeveloperName, Community_Name__c, Organization_Wide_Address__c
                FROM REIDP_Community_Email_Template__mdt
                WHERE Community_Name__c IN :communityMap.keySet()
                AND Type__c = :EMAIL_TYPE
            ]) {
                emailTemplateMap.put(emailSetting.DeveloperName, emailSetting.Community_Name__c);
                addressTemplateMap.put(emailSetting.Organization_Wide_Address__c, emailSetting.Community_Name__c);
            }
            
            for (EmailTemplate template : [
                SELECT Id, DeveloperName
                FROM EmailTemplate 
                WHERE DeveloperName IN :emailTemplateMap.keySet()
            ]) {
                communityMap.get(emailTemplateMap.get(template.DeveloperName)).set(1, template.Id);
            }
            
            for (OrgWideEmailAddress owa : [
                SELECT Id, Address 
                FROM OrgWideEmailAddress 
                WHERE Address IN :addressTemplateMap.keySet()
            ]) {
                communityMap.get(addressTemplateMap.get(owa.Address)).set(0, owa.Id);
            }
            
            List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();
            for (User toUser : toUsers) {
                
                Id templateId = communityMap.get(toUser.REIDP_Default_Community__c).get(1);
                Id owaId = communityMap.get(toUser.REIDP_Default_Community__c).get(0);
                if (String.isNotEmpty(templateId) && String.isNotEmpty(owaId)) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId);
                    mail.setToAddresses(new List<String> {String.valueOf(toUser.Email)});
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owaId);
                    mail.setTargetObjectId(toUser.Id);
                    mail.setWhatId(toUser.Id);
                    allMsg.add(mail);
                }      
            }
            try {
                Messaging.SendEmailResult [] results = Messaging.sendEmail(allMsg, false);
            } catch (Exception e) {
                REIDP_ErrorHandling.logWarningErrorLog(CAIDP_UserTriggerHandler.class, 'Error sending email during user deactivation', e);
            }
        }
        
    }
    
    static public void handleBeforeUpdate(List<User> newUsers, Map<Id, User> oldUsers) {
        
        for (User currUser : newUsers) {
            //if (currUser.Username != currUser.Email && currUser.Email != oldUsers.get(currUser.Id).Email) {
            //    currUser.Username = currUser.Email;
            //}
            if (currUser.LanguageLocaleKey != currUser.CAIDP_Language__c && (Trigger.isInsert || currUser.LanguageLocaleKey != oldUsers.get(currUser.Id).LanguageLocaleKey)) {
                currUser.CAIDP_Language__c = currUser.LanguageLocaleKey;
            }
        }
    }
}