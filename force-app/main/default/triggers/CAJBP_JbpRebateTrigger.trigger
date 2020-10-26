/* @description     triggers on CAJBP_Rebate__c object
 *
 * history
  * 22/07/2019   Venkatesh Muniyasamy    Created
 */
trigger CAJBP_JbpRebateTrigger on CAJBP_Rebate__c (before insert, before delete) 
{
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Rebate__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}