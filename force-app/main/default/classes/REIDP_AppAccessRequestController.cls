/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 12/06/2018
*
* Description: Without sharing is used to give external users access to records that manage requests and approvals.
**/

public without sharing class REIDP_AppAccessRequestController {
    
    public class Application {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String actionLabel;
        @AuraEnabled
        public String btnColor;
        @AuraEnabled
        public String request;
        @AuraEnabled
        public Boolean actionDisabled;
    }
    
    
    @AuraEnabled 
    public static List<Application> getListOfRestrictedApps(){
        List<Application> apps = new List<Application>();
        
        String community;
        
        if(Network.getNetworkId() != null) {
            community = [SELECT Id, UrlPathPrefix 
                         FROM Network 
                         WHERE Id = :Network.getNetworkId()].UrlPathPrefix;
        }
        
        if(Test.isRunningTest())
            community = 'Castrol';
        
        for(REIDP_Application__c app : [SELECT Id, Name,
                                        (SELECT Id, Status__c, Status_Reason__c 
                                         FROM REIDP_Application_Access_Requests__r 
                                         WHERE (Status__c = 'New' OR 
                                                (Status__c = 'Rejected' AND Status_Reason__c = 'Blocked'))
                                         AND User__c = :UserInfo.getUserId())
                                        FROM REIDP_Application__c
                                        WHERE Can_User_Request_Access__c = true 
                                        AND Is_Restricted__c = true 
                                        AND Is_Active__c = true
                                        AND Community__c = :community
                                        AND Id NOT IN (SELECT Application__c 
                                                       FROM REIDP_Application_Access_Request__c 
                                                       WHERE User__c = :UserInfo.getUserId() AND Status__c ='Approved')
                                        ORDER BY Name ASC
                                        LIMIT 50000]) {
			Boolean requestPending = FALSE;
			Boolean blocked = FALSE;
			for(REIDP_Application_Access_Request__c request : app.REIDP_Application_Access_Requests__r) {
                if(request.Status__c == 'New')
                    requestPending = TRUE;
                else if(request.Status__c == 'Rejected' && request.Status_Reason__c == 'Blocked') {
                    blocked = TRUE;
                    break;
                }
            }
			if(blocked)
                continue;
			Application appInfo = new Application();
            appInfo.Id = app.Id;
            appInfo.name = app.Name;
            appInfo.actionLabel = (requestPending) ? Label.REIDP_ApprovalPendingLabel : Label.REIDP_SubmitForApprovalLabel;
            appInfo.btnColor = 'btn';
            appInfo.request = 'requestApproval';
            appInfo.actionDisabled = requestPending;        	                                   
            apps.add(appInfo);
		}
        
        return apps;
    }
    
    // creation of a new Application Access Request record
    @AuraEnabled
    public static void createNewAccessRequest(String appId) {
        System.debug(appId);
        // setting current Contact
        User currentUser = [SELECT u.ContactId, u.Id FROM User u WHERE u.Id =: UserInfo.getUserId() LIMIT 1];
        
        REIDP_Application_Access_Request__c newAccessRequest = new REIDP_Application_Access_Request__c(Application__c = appId,
                                                                                                       Status__c = 'New',
                                                                                                       User__c = UserInfo.getUserId(),
                                                                                                       Contact__c = currentUser.ContactId);
        
        REIDP_Application__c app = [SELECT Id, Community__c, Approver__c FROM REIDP_Application__c WHERE Id = :appId];
        
        insert newAccessRequest;
        String accessRequest = String.valueOf(newAccessRequest.Id);
        
        String approvalName = ((app.Community__c == 'Castrol') ? 'CAIDP' : 'REIDP') + '_Access_Approval';
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(newAccessRequest.Id);
        req.setProcessDefinitionNameOrId(approvalName);
        req.setNextApproverIds(new List<ID>{app.Approver__c});
        Approval.ProcessResult result = Approval.process(req);
        
    }
}