/**
 * @author Ksenia Potapovich
 * @company Bluewolf, an IBM Company
 * @date 11/2017
 *
 */
public with sharing class CAIDP_IdentityHeaderController {

    private static String COMMUNITY_NAME = 'Castrol';
    private static String ACTIVATED_EMAIL_TYPE = 'Activated';
    private static String COMMUNITY_PROFILE = 'RE IDP External Identity';

    @AuraEnabled
    public static String fetchUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static String fetchUserName() {
        String userName = null;
        List<User> users = [
            SELECT Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        if (!users.isEmpty()) {
            userName = users[0].Name;
        }
        return userName;
    }

    @AuraEnabled
    public static String fetchCommunityHomeUrl() {
        return Network.getNetworkId() == null ? '' : Network.communitiesLanding().getUrl();
    }

    @AuraEnabled
    public static void sendActivationEmail() {

        Profile castrolProfile = [
            SELECT Id 
            FROM Profile 
            WHERE Name = :COMMUNITY_PROFILE 
            LIMIT 1
        ];

        List<User> users = [
            SELECT Email, CAIDP_User_Activated__c, ProfileId
            FROM User
            WHERE Id = :UserInfo.getUserId()
                AND ProfileId = :castrolProfile.Id
        ];

        if (!users.isEmpty() && !users[0].CAIDP_User_Activated__c) {  

            List<REIDP_Community_Email_Template__mdt> templateMtd = [
                SELECT DeveloperName, Community_Name__c, Organization_Wide_Address__c
                FROM REIDP_Community_Email_Template__mdt
                WHERE Community_Name__c = :COMMUNITY_NAME
                    AND Type__c = :ACTIVATED_EMAIL_TYPE
            ];

            if (!templateMtd.isEmpty()) {

                List<EmailTemplate> templates = [
                    SELECT Id, DeveloperName
                    FROM EmailTemplate 
                    WHERE DeveloperName = :templateMtd[0].DeveloperName
                ];

                List<OrgWideEmailAddress> owas = [
                    SELECT Id, DisplayName, Address
                    FROM OrgWideEmailAddress 
                    WHERE Address = :templateMtd[0].Organization_Wide_Address__c
                ];

                if (!templates.isEmpty() && !owas.isEmpty()) {

                    List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templates[0].Id);
                    mail.setToAddresses(new List<String> {String.valueOf(users[0].Email)});
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owas[0].Id);
                    mail.setTargetObjectId(users[0].Id);
                    mail.setWhatId(users[0].Id);
                    allMsg.add(mail);
            
                    try {
                        Messaging.SendEmailResult [] results = Messaging.sendEmail(allMsg, false);
                        users[0].CAIDP_User_Activated__c = true;
                        update users;
                    } catch (DMLException e) {
                        REIDP_ErrorHandling.logWarningErrorLog(CAIDP_IdentityHeaderController.class, 'Error updating user during user activation', e);
                    } catch (Exception e) {
                        REIDP_ErrorHandling.logWarningErrorLog(CAIDP_IdentityHeaderController.class, 'Error sending email during user activation', e);
                    }
                } 
            }                   
        }
    }
}