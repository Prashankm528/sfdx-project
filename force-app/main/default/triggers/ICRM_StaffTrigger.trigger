trigger ICRM_StaffTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
// To populate ICRM Staff Object
BPG_Trigger_Handler_Utilities.handleEvent('User', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);

}