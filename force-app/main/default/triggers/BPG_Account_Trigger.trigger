/******************************************************************************************
 *  Date          : 25-JUN-2019
 *  Author        : Sunny Yap
 *  Description   : Calls platform trigger handler.
 *
 * Modifications  : 25-JUN-2019 SYAP - Initial
 *
 ******************************************************************************************/
trigger BPG_Account_Trigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('Account', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}