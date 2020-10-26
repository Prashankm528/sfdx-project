/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 8/2018
*
* User services class that resets users password and forces password change on next login
* 
*/
public class REIDP_ResetMobileUserPassword implements Queueable {
    
    private List<User> users;
    private Boolean isPasswordReset;
    
    public REIDP_ResetMobileUserPassword(List<User> users) {
        this(users, false);
    }
    
    public REIDP_ResetMobileUserPassword(List<User> users, Boolean isPasswordReset) {
        this.users = users;
        this.isPasswordReset = isPasswordReset;
    }
    
    public void execute(QueueableContext context) {
        if(users == null)
            return;
        
        List<REIDP_TwilioSendBulkSMS.SMSMessage> messages = new List<REIDP_TwilioSendBulkSMS.SMSMessage>();
        for(User u : users) {
            String customMessage;
            ResetPasswordResult resetResult = System.resetPasswordWithEmailTemplate(u.Id, false, null);

            if(isPasswordReset) {
                customMessage = String.format(Label.IDPPasswordReset,
                                              new String[]{resetResult.getPassword()});
            } else {
                customMessage = String.format(Label.IDPWelcomeSMS,
                                              new String[]{u.REIDP_Default_Community__c, 
                                                  resetResult.getPassword()});
            }
            messages.add(new REIDP_TwilioSendBulkSMS.SMSMessage(u.Username, customMessage));
        }
        
        if(messages.size() > 0 && !Test.isRunningTest()) {
            ID jobID = System.enqueueJob(new REIDP_TwilioSendBulkSMS(messages));
        }
    }
}