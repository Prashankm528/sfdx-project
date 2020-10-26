/**
 * @author 			Venkatesh Muniyasamy
 * @date 			31/10/2020
 * @group			CAJBP
 * @description     triggers on CAJBP_Ways_of_Working_Target__c object
 *
 * history
 * 31/10/2020	Venkatesh Muniyasamy			Created
 */

trigger CAJBP_WaysOfWorkingTrigger on CAJBP_Ways_of_Working_Target__c (before insert)
{
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Ways_of_Working_Target__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}