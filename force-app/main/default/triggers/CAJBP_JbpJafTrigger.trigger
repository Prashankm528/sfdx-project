/**
 * @author 			Venkatesh Muniyasamy
 * @date 			13/09/2019
 * @group			CAJBP
 * @description     triggers on CAJBP_Distributor_Joint_Activity_Fund__c object
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 30/01/2020	Venkatesh Muniyasamy			Updated for JBP Currency
 */
trigger CAJBP_JbpJafTrigger on CAJBP_Distributor_Joint_Activity_Fund__c (before insert, before delete)
{
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Distributor_Joint_Activity_Fund__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}