/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * REIDP_EmailVerification Class that generates verification codes and sends emails
 * 
 */
public class REIDP_EmailVerification {
    public static Map<String, String> usersWithEmailChange {public get; public set;}

    @future
    public static void sendVerificationCode(Map<String, String> userEmail) { 
        try {
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            List <OrgWideEmailAddress> owas = [SELECT id FROM OrgWideEmailAddress WHERE Address = :REIDP_Constants.FROM_EMAIL_ADDRESS LIMIT 1];
            EmailTemplate template = [Select id from EmailTemplate where DeveloperName = 'REIDP_New_Email_Verification'];
            for(String uid : userEmail.keySet()) {
                Messaging.SingleEmailMessage templateEmail = Messaging.renderStoredEmailTemplate(template.Id, uid, null);
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setToAddresses(new List<String> {userEmail.get(uid)});
                msg.setPlainTextBody(templateEmail.getPlainTextBody());
                msg.setHTMLBody(templateEmail.getHTMLBody());
                msg.setSubject(templateEmail.getSubject());
                if(owas.size() > 0)
	                msg.setOrgWideEmailAddressId(owas[0].Id);
                emailMessages.add(msg);
            }
            Messaging.sendEmail(emailMessages, true);
        }
        catch(Exception ex) {
            REIDP_ErrorHandling.logCriticalErrorLog(REIDP_EmailVerification.class, 'Error sending email verification code', ex);
        }
    }
    
    
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}