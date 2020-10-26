/******************************************************************************************
 * Date           : 03-JAN-2020
 * Author         : Sunny Yap
 * Description    : Calls platform trigger handler.
 * Modifications  : 03-JAN-2020 SYAP - Initial
 ******************************************************************************************/
trigger BPG_Service_Request_Trigger on GCM_Service_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 
  BPG_Trigger_Handler_Utilities.handleEvent('GCM_Service_Request__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}