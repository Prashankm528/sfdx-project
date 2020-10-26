/**
* @author Anna Mokhubova 
* @company Bluewolf, an IBM Company
* @date 18/09/2018 
* 
* User services class that notifies users about status of service they have requested access for.
**/

public class REIDP_NotifyMobileUserService implements Queueable {
    private List<User> users;
    private Boolean isServiceReject;
    
    public REIDP_NotifyMobileUserService(List<User> users) {
        this(users, false);
    }
    
    public REIDP_NotifyMobileUserService(List<User> users, Boolean isServiceReject) {
        this.users = users;
        this.isServiceReject = isServiceReject;
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
            String customMessage;
            if(isServiceReject) {
                customMessage = String.format(Label.IDPServiceRejectSMS,
                                              new String[]{'Application 1',
                                                  networkUrls.get(u.REIDP_Default_Community__c)});
            } else {
                customMessage = String.format(Label.IDPServiceAcceptSMS,
                                              new String[]{'Application 2',
                                                  networkUrls.get(u.REIDP_Default_Community__c)});
            }
            messages.add(new REIDP_TwilioSendBulkSMS.SMSMessage(u.Username, customMessage));
        }
        
        if(messages.size() > 0 && !Test.isRunningTest()) {
            ID jobID = System.enqueueJob(new REIDP_TwilioSendBulkSMS(messages));
        }
    }
}