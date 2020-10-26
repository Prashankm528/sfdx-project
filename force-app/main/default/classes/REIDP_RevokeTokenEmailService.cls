/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 11/2017
 * 
 * Email Service that takes User ID from plainTextBody and revokes all user tokens
 */
global class REIDP_RevokeTokenEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try {
            REIDP_OAuthHelper.revokeTokensForUser(email.plainTextBody);   
        } catch(Exception ex){}
        return result;
    }
}