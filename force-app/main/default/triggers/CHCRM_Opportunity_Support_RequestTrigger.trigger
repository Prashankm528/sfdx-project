trigger CHCRM_Opportunity_Support_RequestTrigger on CHCRM_Opportunity_Support_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	BPG_Trigger_Handler_Utilities.handleEvent('CHCRM_Opportunity_Support_Request__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}