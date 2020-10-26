/**
 * 
 * @author Anna Mokhubova
 * @company Bluewolf, an IBM Company
 * @date 02/2019
 * 
 **/

trigger REIDP_UserConsentTrigger on REIDP_User_Consent__c (after insert, after update, before insert, before update) {
    
    REIDP_UserConsentTriggerHandler handler = new REIDP_UserConsentTriggerHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);
    
    if(Trigger.isBefore) {
        handler.before();
        if(Trigger.isInsert)
            handler.beforeInsert();
        else if(Trigger.isUpdate)
            handler.beforeUpdate();
    }
    else if(Trigger.isAfter) {
        handler.after();
        if(Trigger.isInsert)
            handler.afterInsert();
        else if(Trigger.isUpdate)
            handler.afterUpdate();
    }
}