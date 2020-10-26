/**
 * 
 * @author Anna Mokhubova
 * @company Bluewolf, an IBM Company
 * @date 02/2019
 * 
 **/

public class REIDP_UserConsentTriggerHandler {

    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<REIDP_User_Consent__c> newRecords;
    final Map<Id, REIDP_User_Consent__c> oldRecords;
    
    public REIDP_UserConsentTriggerHandler(List<REIDP_User_Consent__c> newRecords, Map<Id, REIDP_User_Consent__c> newMap, Map<Id, REIDP_User_Consent__c> oldRecords) {
        System.debug('------------------'+newRecords);
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
        //Sets default owner on User Consent to External Identity user related to the consent
        REIDP_UserConsentHelper.setDefaultOwnerOnUserConsent(newRecords);
    }
    
    public void beforeUpdate() {
        if(bypassTrigger){return;}
        //Sets default owner on User Consent to External Identity user related to the consent
        REIDP_UserConsentHelper.setDefaultOwnerOnUserConsent(newRecords);
    }
    
    public void after() {
        if(bypassTrigger){return;}
    }
    
    public void afterInsert() {
        if(bypassTrigger){return;}
        //Update consents based on changes of user
        REIDP_UserConsentHelper.syncConsentToUser(newRecords, oldRecords);
        
        //Prepares User Consent event payload  
        REIDP_UserConsentHelper.getConsentPlatformEvent(newRecords, oldRecords);
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}
        //Prepares User Consent event payload  
        REIDP_UserConsentHelper.getConsentPlatformEvent(newRecords, oldRecords);
        
        //Update consents based on changes of user
        REIDP_UserConsentHelper.syncConsentToUser(newRecords, oldRecords);
        
    }
}