/******************************************************************************************
 *  Date          : 2-SEP-2019
 *  Author        : Simon Alexander
 *  Description   : Calls platform trigger handler.
 *
 * Modifications  : 2-SEP-2019 - Initial
 *
 ******************************************************************************************/
trigger BPG_FeedComment_Trigger on FeedComment (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('FeedComment', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}