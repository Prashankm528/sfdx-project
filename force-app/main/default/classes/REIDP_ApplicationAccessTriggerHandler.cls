/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 10/07/2018
* 
*/

public with sharing class REIDP_ApplicationAccessTriggerHandler {
    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<REIDP_Application_Access_Request__c> newRecords;
    final Map<Id, REIDP_Application_Access_Request__c> oldRecords;
    
    public REIDP_ApplicationAccessTriggerHandler(List<REIDP_Application_Access_Request__c> newRecords, 
                                                 Map<Id, REIDP_Application_Access_Request__c> newMap, 
                                                 Map<Id, REIDP_Application_Access_Request__c> oldRecords) {
                                                     this.newRecords = newRecords;
                                                     this.oldRecords = oldRecords;
                                                     if(newMap != null)
                                                         this.newIds = newMap.keySet();
                                                 }
    
    public void before() {
        if(bypassTrigger){return;}
    }
    
    public void beforeInsert() {
        if(bypassTrigger){return;}
    }
    
    public void beforeUpdate() {
        if(bypassTrigger){return;}
    }
    
    public void after() {
        if(bypassTrigger){return;}
        
        //Process Approved Requests
        REIDP_ApplicationAccessService.processApprovedRequests(newRecords, oldRecords);
        
    }
    
    public void afterInsert() {
        if(bypassTrigger){return;}
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}        
        
        //Send SMS notification when an access to service is granted/rejected
        Set<String> approvedRequestsPhone = new Set<String>();
        Boolean isRejected;
        
        for(REIDP_Application_Access_Request__c  aar : newRecords) {
            if((oldRecords.get(aar.Id).Status__c != aar.Status__c) && (aar.Status__c.equals('Approved'))) {
                approvedRequestsPhone.add(aar.Id);
                isRejected = false;
            } else if(aar.Status__c.equals('Rejected') && (oldRecords.get(aar.Id).Status__c != aar.Status__c) ) {
                approvedRequestsPhone.add(aar.Id);
                isRejected = true;
            }
        }
        REIDP_ApplicationAccessService.sendSMSNotification(approvedRequestsPhone, isRejected);
    }
    
}