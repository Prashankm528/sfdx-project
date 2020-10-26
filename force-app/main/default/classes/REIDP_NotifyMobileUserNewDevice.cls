/**
* @author Anna Mokhubova 
* @company Bluewolf, an IBM Company
* @date 21/09/2018 
* 
* User services class that notifies users about new device.
**/
public class REIDP_NotifyMobileUserNewDevice implements Queueable {
    private List<User> users;
    
    public REIDP_NotifyMobileUserNewDevice(List<User> users) {
        this.users = users;
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
            String customMessage = String.format(Label.IDPNewDevice,
                                                 new String[]{u.Name,
                                                     u.REIDP_Default_Community__c});
            
            messages.add(new REIDP_TwilioSendBulkSMS.SMSMessage(u.Username, customMessage));
        }
        
        if(messages.size() > 0 && !Test.isRunningTest()) {
            ID jobID = System.enqueueJob(new REIDP_TwilioSendBulkSMS(messages));
        }
    }
}