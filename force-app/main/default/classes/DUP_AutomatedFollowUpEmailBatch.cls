/*****************************************************************************************
*       Date:        14OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: batchable class for automated follow up email
*		Updated:	 Updated 30OCT2019 - Naglis Kazlauskas
*****************************************************************************************/
global with sharing  class DUP_AutomatedFollowUpEmailBatch implements Database.Batchable<sObject> {
    @TestVisible static Integer emailLimits;
    private static final String REMINDER_14_DAYS_TEMPLATE = 'DUP_Reminder15_VF_Template';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT DUP_Document_Request__c,
                                         DUP_Counterparty_Contact_Name__r.DUP_Email__c
                                         FROM DUP_Document_Store__c 
                                         WHERE DUP_Document_Status__c = 'Requested'                                         
                                        ]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DUP_Document_Store__c> docStoreList) {
        Set<Id> docRequestToBeProcessIdSet = new Set<Id>();
        Id firstremindertemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :REMINDER_14_DAYS_TEMPLATE].Id;

        for(DUP_Document_Store__c ds : docStoreList){
            docRequestToBeProcessIdSet.add(ds.DUP_Document_Request__c);            
        }
        DUP_DocumentRequestUtil.sendReminderEmailToCounterParty(docRequestToBeProcessIdSet, firstremindertemplateId,docStoreList);
        DUP_AutomatedFollowUpEmailBatch.emailLimits = Limits.getEmailInvocations();
    }
    
    global void finish(Database.BatchableContext BC) {}
}