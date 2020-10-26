/**
 * @author 			Jan Majling
 * @date 			22/08/2018
 * @group			CAJBP
 * @description		triggers on CAJBP_Objective__c object
 * 
 * history
 * 22/08/2018	Jan Majling			Created
 * 19/07/2019	Venkatesh Muniyasamy	Updated for Code Refactoring
 */
trigger CAJBP_ObjectiveTrigger on CAJBP_Objective__c (after insert, before insert, before delete)
{
	BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Objective__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}