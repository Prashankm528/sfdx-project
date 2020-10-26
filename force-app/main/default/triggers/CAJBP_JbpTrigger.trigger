/**
 * @author 			Jan Majling
 * @date 			26/07/2018
 * @group			CAJBP
 * @description     triggers on CAJBP_Joint_Business_Plan__c object
 *
 * history
 * 26/07/2018	Jan Majling				Created
 * 03/10/2018	Jan Majling				Updated to use instance of CAJBP_JbpTriggerHandler
 * 17/07/2019	Venkatesh Muniyasamy	Updated for code refactoring
 */
trigger CAJBP_JbpTrigger on CAJBP_Joint_Business_Plan__c (before insert, before update, after insert, after update, before delete) 
{
	BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Joint_Business_Plan__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);

}