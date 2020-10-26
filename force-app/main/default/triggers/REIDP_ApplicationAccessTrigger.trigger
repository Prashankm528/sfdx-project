/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 10/07/2018
*
**/
trigger REIDP_ApplicationAccessTrigger on REIDP_Application_Access_Request__c (after insert, after update, before insert, before update) {

    REIDP_ApplicationAccessTriggerHandler handler = new REIDP_ApplicationAccessTriggerHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);
    
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