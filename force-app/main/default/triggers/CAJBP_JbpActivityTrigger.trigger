/**
 * @author 			Jana Cechova
 * @date 			26/07/2018
 * @group			CAJBP
 * @description     triggers on CAJBP_JbpActivity__c object
 *
 * history
 * 26/07/2018	Jana Cechova			Created
 * 03/10/2018	Jan Majling				Updated to use instance of CAJBP_JbpActivityTriggerHandler
 * 18/07/2019   Venkatesh Muniyasamy    Updated for Code Refactoring
 */
trigger CAJBP_JbpActivityTrigger on CAJBP_JBP_Activity__c(before insert, after insert, before update, after update, before delete, after delete)
{
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_JBP_Activity__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}