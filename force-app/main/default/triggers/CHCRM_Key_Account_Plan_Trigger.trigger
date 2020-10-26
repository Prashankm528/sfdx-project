trigger CHCRM_Key_Account_Plan_Trigger on CHCRM_Key_Account_Plan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    BPG_Trigger_Handler_Utilities.handleEvent('CHCRM_Key_Account_Plan__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}