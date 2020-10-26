/**
* @author Anna Mokhubova 
* @company Bluewolf, an IBM Company
* @date 25/09/2018 
* 
* User services class that notifies users about services being revoked.
**/
public class REIDP_NotifyMobileUserRevoke implements Queueable {
    private List<User> users;
    private Boolean isServiceRevoked = false;
    private String webServices;
    
    public REIDP_NotifyMobileUserRevoke(List<User> users, String webServices, Boolean isServiceRevoked) {
        this.users = users;
        this.webServices = webServices;
        this.isServiceRevoked = isServiceRevoked;
    }
    
    public void execute(QueueableContext context) {
        if(users == null)
            return;
        
        Map<String, String> networkUrls = new Map<String, String>();
        
        for(Network n : [SELECT Id, UrlPathPrefix FROM Network LIMIT 10000]) {
            networkUrls.put(n.UrlPathPrefix, Network.getLoginUrl(n.Id));
        }
        
        List<REIDP_TwilioSendBulkSMS.SMSMessage> messages = new List<REIDP_TwilioSendBulkSMS.SMSMessage>();
        for(User u : users) {
            if(isServiceRevoked) {
                System.debug('is serviced revoked? ' + isServiceRevoked);
                String customMessage = String.format(Label.IDPRevokedServices,
                                                     new String[]{u.Name,
                                                         webServices,
                                                         networkUrls.get(u.REIDP_Default_Community__c)});
                
                messages.add(new REIDP_TwilioSendBulkSMS.SMSMessage(u.Username, customMessage));
            }
        }
        
        if(messages.size() > 0 && !Test.isRunningTest()) {
            ID jobID = System.enqueueJob(new REIDP_TwilioSendBulkSMS(messages));
        }
    }
}