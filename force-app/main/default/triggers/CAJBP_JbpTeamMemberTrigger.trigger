/**
 * @author 			Jan Majling
 * @date 			17/08/2018
 * @group			CAJBP
 * @description		triggers on CAJBP_JbpTeamMemberTrigger__c object
 * 
 * history
 * 17/08/2018	Jan Majling				Created
 * 03/10/2018	Jan Majling				Updated to use an instance of CAJBP_JbpTeamMemberTriggerHandler
 * 19/07/2019	Venkatesh Muniyasamy	Updated for Code Refactoring
 * 26/08/2020	Abhinit Kohar			Updated to add Before Delete
 */
trigger CAJBP_JbpTeamMemberTrigger on CAJBP_JBP_Team_Member__c (before insert, after insert, before update, after update, before delete, after delete) {

	BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_JBP_Team_Member__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}