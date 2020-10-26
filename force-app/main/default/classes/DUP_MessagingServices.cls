/*****************************************************************************************
*       Date:        1OCT2019
*       Author:      Naglis Jonas Kazlauskas
*       Description: Class for creating and sending emails
*****************************************************************************************/
public class DUP_MessagingServices {
    
    /**
* @description creates email message
* @param  targetObjId of type Id
* @param  emailTemplate of type emailTemplate
* @param  objectToPopulateId of type Id
* @param  senderDisplayName of type String
* @param  ccAddresses of type List collection
* @return Messaging.SingleEmailMessage
*/
    public static Messaging.SingleEmailMessage createEmailMessage(Id targetObjId, Id emailTemplateId, Id objectToPopulateId, 
                                                                    Id emailAddressId, List<String> toAddresses, List<String> ccAddresses ){
                                                                      
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(emailTemplateId != Null) { message.setTemplateID(emailTemplateId);}
        message.setSaveAsActivity(false);
        //message.setSaveAsActivity(true);
        message.setTargetObjectId(targetObjId);
        //message.setTargetObjectId('0038E000018NiOqQAK');
        message.setWhatId(objectToPopulateId);
        //message.setWhatId('a2q8E0000011y1WQAQ');
        if(emailAddressId != null){
            message.setOrgWideEmailAddressId(emailAddressId);
        }
        if(toAddresses.size() > 0) {
            message.setToAddresses(toAddresses);
        }		
        if(ccAddresses.size() > 0) {
            message.setCcAddresses(ccAddresses);
        }		
        return message;
    }  
    
    /**
* @description creates email message
* @param  message of type Messaging.SingleEmailMessage
* @return void
*/
    public static void sendEmail(Messaging.SingleEmailMessage message){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(message);
        try {
            Messaging.sendEmail(mails);
        } catch(Exception e) {
            System.debug('Send emails bug: ' + e);
        }
    } 
    /**
* @description sends emails
* @param  mails of type List<Messaging.SingleEmailMessage>
* @return void
*/
    public static void sendEmails(List<Messaging.SingleEmailMessage> mails){
        try {
            Messaging.sendEmail(mails);           
        } catch(Exception e) {
            System.debug('Send emails bug: ' + e);
            
        }
    } 
}