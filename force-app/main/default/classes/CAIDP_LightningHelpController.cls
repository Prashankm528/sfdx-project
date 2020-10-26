/**
 * @author Ksenia Potapovich
 * @company Bluewolf, an IBM Company
 * @date 04/2018
 *
 */
global without sharing class CAIDP_LightningHelpController {

    public static String ERROR = 'ERROR';
    public static String EMAIL_TYPE = 'Support';
    public static String NETWORK_URL_PATH_PREFIX = 'Castrol';

	@AuraEnabled
    public static String getUserEmail() {
        return UserInfo.getUserEmail();
    }

    @AuraEnabled
    public static String sendMailToSupport(String toEmail, String fromEmail, String subject, String body) {

        List<Network> communities = [
            SELECT UrlPathPrefix
            FROM Network
            WHERE Id = :Network.getNetworkId()
        ];

        String communityName = (!communities.isEmpty()) ? communities[0].UrlPathPrefix : NETWORK_URL_PATH_PREFIX;

        List<REIDP_Community_Email_Template__mdt> templateMtd = [
            SELECT DeveloperName
            FROM REIDP_Community_Email_Template__mdt
            WHERE Community_Name__c = :communityName
                AND Type__c = :EMAIL_TYPE
        ];

        if (templateMtd.isEmpty()) {
            return ERROR;
        }

        List<EmailTemplate> templates = [
            SELECT HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName = :templateMtd[0].DeveloperName
        ];

        if (templates.isEmpty()) {
            return ERROR;
        }

        String username = UserInfo.getName();
        String userId = UserInfo.getUserId();

        String htmlBody = templates[0].HtmlValue;
        htmlBody = htmlBody.replace('{!communityUser}', username);
        htmlBody = htmlBody.replace('{!userId}', userId);
        htmlBody = htmlBody.replace('{!messageBody}', body);

        String plainText = templates[0].Body;
        plainText = plainText.replace('{!communityUser}', username);
        plainText = plainText.replace('{!userId}', userId);
        plainText = plainText.replace('{!messageBody}', body);

        List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> {String.valueOf(toEmail)});
        mail.setReplyTo(fromEmail);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(plainText);
        allMsg.add(mail);

        try {
            Messaging.SendEmailResult [] results = Messaging.sendEmail(allMsg, false);
            return null;
        } catch (Exception e) {
            REIDP_ErrorHandling.logWarningErrorLog(CAIDP_LightningHelpController.class, 'Error sending email to Castrol support team.', e);
            return ERROR;
        }
    }   
}