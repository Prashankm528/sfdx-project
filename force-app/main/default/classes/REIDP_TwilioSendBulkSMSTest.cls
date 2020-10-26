/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 03/09/2018
*
**/
@isTest
public with sharing class REIDP_TwilioSendBulkSMSTest {
    
    @isTest
    public static void testExecutePhone() {
        List<REIDP_TwilioSendBulkSMS.SMSMessage> messages = new List<REIDP_TwilioSendBulkSMS.SMSMessage>();
        for (Integer i = 0; i < 200; i++) {
            REIDP_TwilioSendBulkSMS.SMSMessage testMessage = new REIDP_TwilioSendBulkSMS.SMSMessage('1', '234567890', 'test message');
            messages.add(testMessage);
        }
        
        Test.startTest();
        REIDP_TwilioSendBulkSMS smsBulkSMS = new REIDP_TwilioSendBulkSMS(messages);
        ID jobId = System.enqueueJob(smsBulkSMS);
        
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
    @isTest
    public static void testExecuteUsername() {
        List<REIDP_TwilioSendBulkSMS.SMSMessage> messages = new List<REIDP_TwilioSendBulkSMS.SMSMessage>();
        for (Integer i = 0; i < 200; i++) {
            REIDP_TwilioSendBulkSMS.SMSMessage testMessage = new REIDP_TwilioSendBulkSMS.SMSMessage('1.234567890', 'test message');
            messages.add(testMessage);
        }
        Test.startTest();        
        REIDP_TwilioSendBulkSMS smsBulkSMS = new REIDP_TwilioSendBulkSMS(messages);
        ID jobId = System.enqueueJob(smsBulkSMS);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}