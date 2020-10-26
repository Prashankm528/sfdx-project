/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 02/2018
 * 
 */
trigger REIDP_PlatformEventTrigger on REIDP_Platform_Event__e (after insert) {
    REIDP_PlatformEventTriggerHandler handler = new REIDP_PlatformEventTriggerHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);
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