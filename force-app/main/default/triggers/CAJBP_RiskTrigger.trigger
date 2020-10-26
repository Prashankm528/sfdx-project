trigger CAJBP_RiskTrigger on CAJBP_Risk__c (before insert, before delete, after insert) {
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Risk__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}