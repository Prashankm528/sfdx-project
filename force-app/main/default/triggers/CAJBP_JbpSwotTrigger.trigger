/**
 * @author 			Venkatesh Muniyasamy
 * @date 			13/09/2019
 * @group			CAJBP
 * @description     triggers on CAJBP_SWOT__c object
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 31/10/2020   Venkatesh Muniyasamy            Updated for JBP Currency
 */
trigger CAJBP_JbpSwotTrigger on CAJBP_SWOT__c (before insert, before delete)
{
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_SWOT__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}