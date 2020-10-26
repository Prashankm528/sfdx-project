/******************************************************************************************
 *  Date          : 2-SEP-2019
 *  Author        : Simon Alexander
 *  Description   : Calls platform trigger handler.
 *
 * Modifications  : 17-Oct-2019 - Initial
 *
 ******************************************************************************************/
trigger BPG_ContentVersion_Trigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('ContentVersion', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}