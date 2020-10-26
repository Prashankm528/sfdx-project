/**
* @author Irfan Ahmed
* @date 19-06-2020
* @description triggers on CapEx object
* 
*/
trigger ICRM_CapExTrigger on ICRM_CapEx__c (before insert, after insert, before update, after update, before delete, after delete) { 
	BPG_Trigger_Handler_Utilities.handleEvent('ICRM_CapEx__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
}