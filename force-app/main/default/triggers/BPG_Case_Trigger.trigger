/******************************************************************************************
 *  Date          : 22-MAR-2019
 *  Author        : Sunny Yap
 *  Description   : Calls platform trigger handler.
 *
 * Modifications  : 22-MAR-2019 SYAP - Initial
 *
 ******************************************************************************************/
trigger BPG_Case_Trigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('Case', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);

    
}