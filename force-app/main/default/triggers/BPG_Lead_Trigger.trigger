/****************************************************************************************************
 *  Date          : 08-OCT-2019
 *  Author        : Ajay Konathala
 *  Description   : Calls platform trigger handler.
 *
 ****************************************************************************************************/
trigger BPG_Lead_Trigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    // Call Triggers Framework
    BPG_Trigger_Handler_Utilities.handleEvent('Lead', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}