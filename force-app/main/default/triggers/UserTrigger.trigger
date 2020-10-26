/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 02/2018
 * 
 */
trigger UserTrigger on User (after insert, after update, before insert, before update) {
    
    UserTriggerHandler handler = new UserTriggerHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);
    
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