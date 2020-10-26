trigger CHCRM_LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    BPG_Trigger_Handler_Utilities.handleEvent('Lead', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}