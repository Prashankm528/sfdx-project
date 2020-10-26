/**
* @author Ksenia Potapovich
* @company Bluewolf, an IBM Company
* @date 02/2018
*
*/
public with sharing class CAIDP_ManagePermissionSetsController {
    
    private static String COMMUNITY_PROFILE = 'RE IDP External Identity';
    private static String NEW_APPS_EMAIL_TYPE = 'NewPermissions';
    private static String REMOVE_APPS_EMAIL_TYPE = 'RemovedPermissions';
    private static String DEFAULT_COMMUNITY = 'BP';
    
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
    }
    
    private static String getCommunityName(Id accId) {
        
        Profile castrolProfile = [
            SELECT Id 
            FROM Profile 
            WHERE Name = :COMMUNITY_PROFILE 
            LIMIT 1
        ];
        
        /*Adams fix */
        Account acc = [SELECT REIDP_User__pc FROM Account WHERE Id = :accId];
        List<User> users = [
            SELECT REIDP_Default_Community__c
            FROM User
            WHERE Id IN (:acc.REIDP_User__pc)
            AND ProfileId = :castrolProfile.Id
        ];
        /*Adams fix */
        
        /*
        List<User> users = [
            SELECT REIDP_Default_Community__c
            FROM User
            WHERE Id IN (SELECT REIDP_User__pc FROM Account WHERE Id = :accId)
            AND ProfileId = :castrolProfile.Id
        ];
        */
        system.debug('users found --> ' + users);
        
        String communityName = DEFAULT_COMMUNITY;
        if (!users.isEmpty() && String.isNotEmpty(users[0].REIDP_Default_Community__c)) {
            communityName = users[0].REIDP_Default_Community__c;
        }
        return communityName;
    }
    
    private static Set<Id> getCommunityPermissionSet(String communityName) {
        Set<Id> permissionSet = new Set<Id>();
        for (REIDP_Connected_App__mdt app : [
            SELECT Permission_Set_Id__c
            FROM REIDP_Connected_App__mdt
            WHERE Community_Name__c = :communityName
        ]) {
            permissionSet.add(app.Permission_Set_Id__c);
        }
        return permissionSet;
    }
    
    @AuraEnabled
    public static String getOrgUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    @AuraEnabled
    public static List<SelectOption> getAppPermissions(Id accId) {
        
        Set<Id> permissionSet = getCommunityPermissionSet(getCommunityName(accId));
        System.debug(permissionSet);
        System.debug(getCommunityName(accId));
        List<SelectOption> options = new List<SelectOption>();
        for (PermissionSet permission : [
            SELECT Label, Name
            FROM PermissionSet
            WHERE Id IN :permissionSet
        ]) {
            options.add(new SelectOption(permission.Id, permission.Label));
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getAssignedPermissionIds(Id accId) {
        
        Set<Id> permissionSet = getCommunityPermissionSet(getCommunityName(accId));
        
        List<String> assignedIds = new List<String>();
        
        List<Account> accs = [
            SELECT REIDP_User__pc 
            FROM Account
            WHERE Id = :accId
        ];
        
        for (PermissionSet permission : [
            SELECT Label, Name
            FROM PermissionSet
            WHERE Id IN :permissionSet
            AND Id IN (
                SELECT PermissionSetId 
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :accs[0].REIDP_User__pc 
            )
        ]) {
            assignedIds.add(permission.Id);
        }
        
        return assignedIds;
    }
    
    @AuraEnabled
    public static List<PermissionSet> getAssignedPermissions(Id accId) {
        
        Set<Id> permissionSet = getCommunityPermissionSet(getCommunityName(accId));
        
        List<Account> accs = [
            SELECT REIDP_User__pc 
            FROM Account
            WHERE Id = :accId
        ];
        
        return [
            SELECT Label, Name, Description
            FROM PermissionSet
            WHERE Id IN :permissionSet
            AND Id IN (
                SELECT PermissionSetId 
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :accs[0].REIDP_User__pc 
            )
        ];
    }
    
    @AuraEnabled
    public static void managePermissions(Id accId, List<String> currPermissions, List<PermissionSet> prevPermissions) {
        
        Boolean isPhoneNumberUser = false;
        
        List<Account> accs = [
            SELECT REIDP_User__pc 
            FROM Account
            WHERE Id = :accId
        ];
        
        if (!accs.isEmpty() && accs[0].REIDP_User__pc != null) {
            
            String disabledApps = '';
            String enabledApps = '';
            Set<String> currPermissionsSet = new Set<String>(currPermissions);
            Set<String> prevPermissionsSet = new Set<String>();
            for (Integer i = 0; i < prevPermissions.size(); i++) {
                if (currPermissionsSet.contains(prevPermissions[i].Id)) {
                    currPermissionsSet.remove(prevPermissions[i].Id);
                }
                else {
                    disabledApps += prevPermissions[i].Label + '<br/>';
                    prevPermissionsSet.add(prevPermissions[i].Id);
                }
            }
            
            List<PermissionSetAssignment> assignmentsToDelete = [
                SELECT PermissionSetId, AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSetId IN :prevPermissionsSet
                AND AssigneeId = :accs[0].REIDP_User__pc
            ];
            if (!assignmentsToDelete.isEmpty()) {
                delete assignmentsToDelete;
                
                // send SMS/Email to user based on their username
                if (isPhoneNumberUser(accs[0].REIDP_User__pc)) {
                    sendSMSNotification(accs[0].REIDP_User__pc, disabledApps);
                } else {
                    sendEmailNotification(accs[0].REIDP_User__pc, disabledApps, REMOVE_APPS_EMAIL_TYPE);
                }
                
            }
            
            List<PermissionSetAssignment> assignmentsToUpsert = new List<PermissionSetAssignment>();
            for (PermissionSet currPerm : [
                SELECT Label
                FROM PermissionSet
                WHERE Id IN :currPermissionsSet
            ]) {
                enabledApps += currPerm.Label + '<br/>';
                assignmentsToUpsert.add(
                    new PermissionSetAssignment(
                        PermissionSetId = currPerm.Id,
                        AssigneeId = accs[0].REIDP_User__pc
                    )
                );
            }
            if (!assignmentsToUpsert.isEmpty()) {
                upsert assignmentsToUpsert;
                sendEmailNotification(accs[0].REIDP_User__pc, enabledApps, NEW_APPS_EMAIL_TYPE);
            }
        }
    }
    
    private static void sendEmailNotification(String userId, String webServices, String emailType) {
        
        Profile castrolProfile = [
            SELECT Id 
            FROM Profile 
            WHERE Name = :COMMUNITY_PROFILE 
            LIMIT 1
        ];
        
        List<User> users = [
            SELECT Name, Email, REIDP_Default_Community__c
            FROM User
            WHERE Id = :userId
            AND ProfileId = :castrolProfile.Id
        ];
        
        if (!users.isEmpty()) {
            
            String communityName = (String.isNotEmpty(users[0].REIDP_Default_Community__c)) ? 
                users[0].REIDP_Default_Community__c :
            DEFAULT_COMMUNITY;
            
            List<REIDP_Community_Email_Template__mdt> templateMtd = [
                SELECT DeveloperName, Organization_Wide_Address__c
                FROM REIDP_Community_Email_Template__mdt
                WHERE Community_Name__c = :communityName
                AND Type__c = :emailType
            ];
            
            if (!templateMtd.isEmpty()) {
                
                EmailTemplate template = [
                    SELECT DeveloperName, Markup, TemplateType, Name, FolderId, IsActive, ApiVersion
                    FROM EmailTemplate 
                    WHERE DeveloperName = :templateMtd[0].DeveloperName
                    LIMIT 1];
                
                List<OrgWideEmailAddress> owas = [
                    SELECT Id, DisplayName, Address
                    FROM OrgWideEmailAddress 
                    WHERE Address = :templateMtd[0].Organization_Wide_Address__c
                ];
                
                List<Network> community = [
                    SELECT Name, UrlPathPrefix 
                    FROM Network 
                    WHERE Name = :communityName
                ];
                
                if (!owas.isEmpty() && !community.isEmpty()) {
                    REIDP_CommunityEmailController.customMergeFields.put('webservice', webServices.stripHtmlTags());
                    
                    List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(template.Id);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(users[0].Id);
                    mail.setOrgWideEmailAddressId(owas[0].Id);
                    allMsg.add(mail);
                    
                    try {
                        Messaging.SendEmailResult [] results = Messaging.sendEmail(allMsg, false);
                    } catch (Exception e) {
                        REIDP_ErrorHandling.logWarningErrorLog(CAIDP_ManagePermissionSetsController.class, 'Error sending email during permissions management.', e);
                    }
                }
            }  
        }
    }
    
    private static void sendSMSNotification(String userId, String webServices) {
        List<User> usersToProcess = [SELECT Id, Username, Name, REIDP_Default_Community__c FROM User WHERE Id = :userId];
        
        webServices = webServices.replace('<br/>', '');
        
        if(usersToProcess.size() > 0) {
            REIDP_NotifyMobileUserRevoke sendSMS = new REIDP_NotifyMobileUserRevoke(usersToProcess, webServices, true);
            ID jobID = System.enqueueJob(sendSMS);
        }
    }
    
    @TestVisible
    private static Boolean isPhoneNumberUser(String userId) {
        User u = [SELECT Username FROM User WHERE Id = :userId];
        List<String> phoneNumberList = u.Username.split('@').get(0).split('\\.');
        
        if (phoneNumberList.get(0).isNumeric() && phoneNumberList.get(1).isNumeric()) {
            return true;
        } else {
            return false;
        }
        
    }
}