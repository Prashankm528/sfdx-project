trigger ContentVersionTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    BPG_Trigger_Handler_Utilities.handleEvent('ContentVersion', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}