trigger BPG_EmailMessage_Trigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  BPG_Trigger_Handler_Utilities.handleEvent('EmailMessage', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
  
}