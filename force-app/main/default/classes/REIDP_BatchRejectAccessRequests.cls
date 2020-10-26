/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 3/2019
*
*/
global class REIDP_BatchRejectAccessRequests implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM REIDP_Application_Access_Request__c 
                                         WHERE CreatedDate < LAST_N_DAYS:15
                                         AND Status__c != 'Rejected']);
    }
    
    global void execute(Database.BatchableContext BC, List<REIDP_Application_Access_Request__c> requests) {
        Set<String> requestsToAutoReject = new Set<String>();
        
        for(REIDP_Application_Access_Request__c  aar : requests) {
            requestsToAutoReject.add(aar.Id);
        }
        
        REIDP_ApplicationAccessService.rejectExpiredRequests(requestsToAutoReject);
    }
    
    global void finish(Database.BatchableContext BC) {}
}