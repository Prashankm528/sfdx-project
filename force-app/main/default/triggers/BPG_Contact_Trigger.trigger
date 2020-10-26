/******************************************************************************************
 *  Date          : 06-Dec-2019
 *  Author        : Karishma Gurjar
 *  Description   : Calls platform trigger handler.
 *
 * 
 *
 ******************************************************************************************/
 
trigger BPG_Contact_Trigger on Contact(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('Contact', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}