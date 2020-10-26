/******************************************************************************************
 *  Date          : 19-Feb-2020
 *  Author        : Karishma Gurjar
 *  Description   : Calls platform trigger handler.
 *
 * 
 ******************************************************************************************/
trigger ICRM_ContentDocumentTrigger on ContentDocument (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /*  Trigger to populate Notes on custom Object ICRM_Notes__c  */
   // BPG_Trigger_Handler_Utilities.handleEvent('ContentDocument', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}