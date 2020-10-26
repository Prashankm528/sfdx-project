/******************************************************************************************
 *  Date          : 05-March-2020
 *  Author        : Santosh Verma
 *  Description   : Calls platform trigger handler on Campaign object 
 *
 * Modifications  :  
 *
 ******************************************************************************************/
trigger BPG_Campaign_Trigger on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('Campaign', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}