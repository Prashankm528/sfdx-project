/**
 * @author Ksenia Potapovich
 * @company Bluewolf, an IBM Company
 * @date 11/2017
 *
 */
public with sharing class CAIDP_ManageUsersController {

    //public static String DUPLICATE_USERS = 'Check user\'s Emails list. Some of them already exist in database.';
    public static final String INVITE_EMAIL_TYPE = 'Invite';
    public static final String MIGRATE_EMAIL_TYPE = 'Migrate';

    public class CAIDP_MemberWrapper {

        public CAIDP_MemberWrapper() {
            this.email = '';
            this.language = 'en_US';
            this.apps = getCastrolApps();
        }

        @AuraEnabled
        public String email { get;set; }
        @AuraEnabled
        public List<CastrolApp> apps { get;set; }
        @AuraEnabled
        public String language { get;set; }
    }

    public class CastrolApp {
        public CastrolApp(String label, Boolean autoAssigned) {
            this.autoAssigned = autoAssigned;
            this.label = label;
            this.enabled = autoAssigned;
        }

        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public Boolean autoAssigned { get;set; }
        @AuraEnabled
        public Boolean enabled { get;set; }
    }

    private static List<CastrolApp> getCastrolApps() {
        Set<Id> autoAssignedSet = new Set<Id>();
        for (REIDP_Auto_Assigned_Permission_Set__mdt autoAssigned : [
                SELECT Permission_Set_Id__c
                FROM REIDP_Auto_Assigned_Permission_Set__mdt
            ]) {
            autoAssignedSet.add(autoAssigned.Permission_Set_Id__c);
        }

        List<CastrolApp> castrolApps = new List<CastrolApp>();
        for (REIDP_Connected_App__mdt app : [
                SELECT Label, Index__c, Permission_Set_Id__c
                FROM REIDP_Connected_App__mdt
                WHERE Community_Name__c = :REIDP_Constants.CASTROL_COMMUNITY_NAME
                ORDER BY Index__c
            ]) {

            castrolApps.add(new CastrolApp(app.Label, autoAssignedSet.contains(app.Permission_Set_Id__c)));
        }
        return castrolApps;
    }

    @AuraEnabled
    public static List<CastrolApp> getApps() {

        return getCastrolApps();
    }

    @AuraEnabled
    public static List<CAIDP_MemberWrapper> createRows(Integer size) {

        List<CAIDP_MemberWrapper> wrappers = new List<CAIDP_MemberWrapper>();
        for (Integer i = 0; i < size; i++) {
            wrappers.add(new CAIDP_MemberWrapper());
        }
        return wrappers;
    }

    @AuraEnabled
    public static List<CAIDP_MemberWrapper> getMembers(String jsonMembers) {
        List<CAIDP_MemberWrapper> newMembers = (List<CAIDP_MemberWrapper>)JSON.deserialize(
            jsonMembers, List<CAIDP_MemberWrapper>.class
        );
        return newMembers;
    }

    @AuraEnabled
    public static String inviteMembers(String jsonMembers, Boolean isInvite) {

        //check emails on input unfocus + if not active
        List<CAIDP_MemberWrapper> newMembers = (List<CAIDP_MemberWrapper>)JSON.deserialize(
            jsonMembers, List<CAIDP_MemberWrapper>.class
        );

        Set<String> newMembersEmails = new Set<String>();
        for (CAIDP_MemberWrapper member : newMembers) {
            if (String.isNotEmpty(member.email)) {
                newMembersEmails.add(member.email);
            }     
        }

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(REIDP_Constants.PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
        Map<String, String> emailIdMap = new Map<String, String>();
        for (Account acc : [
            SELECT PersonEmail
            FROM Account
            WHERE PersonEmail IN :newMembersEmails
                AND RecordTypeId = :recordTypeId
        ]) {
            emailIdMap.put(acc.PersonEmail, acc.Id);
        }

        Profile castrolProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME
        ];

        for (User duplicateUser : [
            SELECT Email
            FROM User
            WHERE Email IN :newMembersEmails
                AND ProfileId = :castrolProfile.Id
        ]) {
            newMembersEmails.remove(duplicateUser.Email);
        }

        String emailType = (isInvite) ? INVITE_EMAIL_TYPE : MIGRATE_EMAIL_TYPE;

        REIDP_Community_Email_Template__mdt communityEmailTemplates = [
            SELECT DeveloperName, Organization_Wide_Address__c 
            FROM REIDP_Community_Email_Template__mdt 
            WHERE Community_Name__c = :REIDP_Constants.CASTROL_COMMUNITY_NAME AND Type__c = :emailType
        ];
        List<OrgWideEmailAddress> owa = [
            SELECT id, DisplayName, Address 
            FROM OrgWideEmailAddress 
            WHERE Address = :communityEmailTemplates.Organization_Wide_Address__c
        ];

        EmailTemplate emailTemplate = [
            SELECT DeveloperName
            FROM EmailTemplate 
            WHERE DeveloperName =: communityEmailTemplates.DeveloperName
        ];

        List<Account> accounts = new List<Account>();
        for (CAIDP_MemberWrapper member : newMembers) {
            if (String.isNotEmpty(member.email) && newMembersEmails.contains(member.email)) {

                Account acc = new Account(
                    Id = (emailIdMap.containsKey(member.email)) ? emailIdMap.get(member.email) : null,
                    RecordTypeId = recordTypeId,
                    PersonEmail = member.email,
                    LastName = member.email.split('@')[0],
                    CAIDP_Preferred_Language__pc = (String.isNotEmpty(member.language)) ? member.language : 'en_US'
                );

                List<CastrolApp> apps = member.apps;
                if (apps != null) {
                   for (CastrolApp app : apps) {
                        if (app.enabled && !app.autoAssigned) {
                            if (String.isEmpty(acc.CAIDP_Connected_Apps__pc)) {
                                acc.CAIDP_Connected_Apps__pc = '';
                            }
                            acc.CAIDP_Connected_Apps__pc += app.label + ';';
                        }
                    } 
                } 
                accounts.add(acc);
                newMembersEmails.remove(member.email);
            }
        }
        upsert accounts;

        List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();
        for (Account newMember : [
            SELECT PersonEmail, PersonContactId, CAIDP_Preferred_Language__pc
            FROM Account
            WHERE Id IN :accounts
        ]) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> {newMember.PersonEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(newMember.PersonContactId);
            if (!owa.isEmpty()) {
                mail.setOrgWideEmailAddressId(owa[0].id);
            }
            allMsg.add(mail);            
        }
        try {
            System.debug('###allMsg###' + allMsg);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(allMsg, false);
            for (Messaging.SendEmailResult er : results) {
                if(!er.isSuccess()) {
                    System.debug('###er.getErrors()###' + er.getErrors());
                } 
            }
            System.debug('###results###' + results);
        } 
        catch (Exception e) {
            REIDP_ErrorHandling.logWarningErrorLog(CAIDP_ManageUsersController.class, 'Error sending email during user invitation.', e);
        }
        return null;
    }
}