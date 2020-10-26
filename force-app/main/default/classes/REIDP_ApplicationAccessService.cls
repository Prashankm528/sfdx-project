/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 10/07/2018
* 
*/
public with sharing class REIDP_ApplicationAccessService {
    
    public static void processApprovedRequests(List<REIDP_Application_Access_Request__c> newRecords, Map<Id, REIDP_Application_Access_Request__c> oldRecords) {
        Set<String> approvedRequests = new Set<String>();
        for(REIDP_Application_Access_Request__c  aar : newRecords) {
            if(aar.Status__c.equals('Approved') && (Trigger.isInsert || !oldRecords.get(aar.Id).Status__c.equals('Approved'))) {
                approvedRequests.add(aar.Id);
            } 
        }
        
        if(approvedRequests.size() > 0)
            processApprovedRequests(approvedRequests);
    }
    
    @future
    public static void processApprovedRequests(Set<String> requests) {
        Map<String, List<String>> approvedRequests = new Map<String, List<String>>();
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for(REIDP_Application_Access_Request__c aar : [SELECT Id, Application__c, User__c 
                                                       FROM REIDP_Application_Access_Request__c 
                                                       WHERE Id in :requests]) {
                                                           if(approvedRequests.get(aar.Application__c) == null)
                                                               approvedRequests.put(aar.Application__c, new List<String>());
                                                           approvedRequests.get(aar.Application__c).add(aar.User__c);
                                                       }
        
        for(REIDP_Application__c app : [SELECT Name, Permission_Set__c 
                                        FROM REIDP_Application__c 
                                        WHERE Id in :approvedRequests.keySet()]) {
                                            for(String userId : approvedRequests.get(app.Id)) {
                                                assignments.add(new PermissionSetAssignment(PermissionSetId = app.Permission_Set__c,
                                                                                            AssigneeId = userId));
                                            }
                                        }
        insert assignments;
    }

    public static void rejectExpiredRequests(Set<String> requests) {
        List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : [SELECT Id FROM ProcessInstanceWorkitem
                                                WHERE ProcessInstance.TargetObjectId in :requests]) {
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('Auto-Rejected');
			req.setAction('Reject');                                            
			req.setWorkitemId(workItem.Id);
			reqs.add(req);
		}
        Approval.process(reqs, true);
    }
    
    
    public static void sendSMSNotification(Set<String> approvedRequestsPhone, Boolean isRejected) {
        List<User> usersToProcess = new List<User>();
        // extracts Users with mobile suffix only for those apps which are triggered
        List<REIDP_Application_Access_Request__c> apps = [SELECT Id, Application__c, User__c, User__r.Username, User__r.REIDP_Default_Community__c
                                                          FROM REIDP_Application_Access_Request__c 
                                                          WHERE Id in :approvedRequestsPhone
                                                          AND User__r.Username LIKE : '%'+REIDP_Constants.MOBILE_USERS_SUFFIX];
        for(REIDP_Application_Access_Request__c aar : apps) {
            usersToProcess.add(aar.User__r);
        }
        if(usersToProcess.size() > 0) {
            REIDP_NotifyMobileUserService sendSMSServiceStatus = new REIDP_NotifyMobileUserService(usersToProcess, isRejected);
            ID jobID = System.enqueueJob(sendSMSServiceStatus);
        }
    }
}