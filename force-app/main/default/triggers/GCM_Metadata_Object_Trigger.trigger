/******************************************************************************************
 *  Date          : 22-MAR-2019
 *  Author        : Sunny Yap
 *  Description   : Calls platform trigger handler.
 *
 * Modifications  : 22-MAR-2019 SYAP - Initial
 *
 ******************************************************************************************/
trigger GCM_Metadata_Object_Trigger on GCM_Metadata_Object__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   BPG_Trigger_Handler_Utilities.handleEvent('GCM_Metadata_Object__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}