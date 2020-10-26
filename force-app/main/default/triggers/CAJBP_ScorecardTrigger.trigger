/**
 * @author 			Venkatesh Muniyasamy
 * @date 			30/01/2020
 * @group			CAJBP
 * @description     triggers on CAJBP_Scorecard__c object
 *
 * history
 * 30/01/2020	Venkatesh Muniyasamy			Created
 */
trigger CAJBP_ScorecardTrigger on CAJBP_Scorecard__c (before insert)
{
BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Scorecard__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}