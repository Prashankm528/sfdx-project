/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 8/2018
 *
 * Twilio services class that is used to send bulk sms to Users asynchronously
 * 
 */
public class REIDP_TwilioSendBulkSMS implements Queueable, Database.AllowsCallouts {
    
    private List<REIDP_TwilioSendBulkSMS.SMSMessage> messages;
    
    public REIDP_TwilioSendBulkSMS(List<REIDP_TwilioSendBulkSMS.SMSMessage> messages) {
        this.messages = messages;
    }
    
    public void execute(QueueableContext context) {
        REIDP_TwilioCustomSMS customSMS = new REIDP_TwilioCustomSMS();
        
        List<REIDP_TwilioSendBulkSMS.SMSMessage> messagesOverLimit = new List<REIDP_TwilioSendBulkSMS.SMSMessage>();
        
        for(REIDP_TwilioSendBulkSMS.SMSMessage msg : messages) {

            //Check if we are within Callout Limit. If not, then create a list of messages that are over the limit and enqueue another job
            if(Limits.getCallouts() < Limits.getLimitCallouts())
                REIDP_TwilioCustomSMS.Response resp = customSMS.send(msg.getPhoneNumber(), msg.getCountryCode(), msg.getMessage());
            else
                messagesOverLimit.add(msg);
        }
        
        if(messagesOverLimit.size() > 0) {
            ID jobID = System.enqueueJob(new REIDP_TwilioSendBulkSMS(messages));
        }
    }
    
    public class SMSMessage {
        private String countryCode;
        private String phoneNumber;
        private String message;
        
        //Input username format: "countryCode.PhoneNumber@idp.bp.com" => "44.12345678@idp.bp.com"
        public SMSMessage(String username, String message) {

            List<String> phoneNumberList = username.split('@').get(0).split('\\.');
            
            this.countryCode = phoneNumberList.get(0);
            this.phoneNumber = phoneNumberList.get(1);
            this.message = message;
        }
        
        public SMSMessage(String countryCode, String phoneNumber, String message) {
            this.countryCode = countryCode;
            this.phoneNumber = phoneNumber;
            this.message = message;
        }
        
        public String getCountryCode() {
            return countryCode;
        }
        
        public String getPhoneNumber() {
            return phoneNumber;
        }
        
        public String getMessage() {
            return message;
        }
    }

}