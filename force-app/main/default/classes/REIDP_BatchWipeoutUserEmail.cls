/**
*
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 04/2019
*
**/ 
global class REIDP_BatchWipeoutUserEmail implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Test.isRunningTest() ? Database.getQueryLocator([SELECT Id, REIDP_New_Email__c, Email, REIDP_Verified_Email__c, REIDP_New_Email_TimeStamp__c
                                                                FROM User 
                                                                WHERE Profile.Name LIKE 'RE IDP External Identity%'
                                                                AND (REIDP_New_Email_TimeStamp__c < LAST_N_DAYS:30) 
                                                                AND Username LIKE 'REIDP_BatchWipeoutUserEmailSchedulerTest%'])
                                    : Database.getQueryLocator([SELECT Id, REIDP_New_Email__c, Email, REIDP_Verified_Email__c, REIDP_New_Email_TimeStamp__c
                                                                FROM User 
                                                                WHERE Profile.Name LIKE 'RE IDP External Identity%'
                                                                AND (REIDP_New_Email_TimeStamp__c < LAST_N_DAYS:30)]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> users) {
        List<User> updateWipedOutUsers = new List<User>();
        
        for (User u : users){
            if (u.Email == u.REIDP_New_Email__c) {
                u.REIDP_New_Email__c = null;
                u.REIDP_New_Email_TimeStamp__c = null;
                updateWipedOutUsers.add(u);
            }
        }
        
        if(updateWipedOutUsers.size() > 0) {
            update updateWipedOutUsers;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}