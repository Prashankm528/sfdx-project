/*****************************************************************************************
*   Date:           07SEPT20
*   Author:         Danish Memon – TCS (Tata Consultancy Services Ltd.)
*   Description:    Batchable class for sending users email notification
*   Modifications:  
****************************************************************************************/
global with sharing class GEFUE_SendEmailUserBatchable implements Database.Batchable<SObject> {
    
    //public DateTime dtFourteenDays = Date.today()-14;
    public String query = !Test.isRunningTest() ? 'SELECT FirstName, LastLoginDate, Email, Id From User WHERE IsActive = true AND Profile.Name IN (\'GEFUE Fuels NA Sales\', \'GEFUE Fuels NA Sales - Branded Direct\', \'GEFUE Fuels NA Sales - Support\', \'GEFUE Fuels Dev Ops\') AND LastLoginDate= N_DAYS_AGO:14' : 'SELECT FirstName, LastLoginDate , Email, Id From User WHERE IsActive = true AND Profile.Name=\'System Administrator\' LIMIT 1';
    
    global Database.querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {
        List<User> UserList = (List<User>) scopeList;
        if(!UserList.isEmpty()) {
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress owea = [Select Id from OrgWideEmailAddress where Address = 'do-not-reply@bp.com' limit 1];
            for (User act : UserList) {               
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setSubject('Reminder: Salesforce User Login');
                message.setPlainTextBody('Hi ' +act.FirstName+',\n\nThis is a friendly reminder that you have not logged into Salesforce within the last 14 days.');
                Message.setTargetObjectId(act.id);
                Message.setOrgWideEmailAddressId(owea.id);
                String[] toAddresses = new String[] {act.Email};
                Message.setToAddresses(toAddresses); 
                Message.SaveAsActivity = false;
                mailList.add(Message);
            }
            if(!mailList.isEmpty()) {
                try{
                    Messaging.sendEmail(mailList);
                    System.debug('Mail Sent to the user');
                }
                catch (Exception ex) {
                    System.debug('Unable to send email'+ ex.getMessage());
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}