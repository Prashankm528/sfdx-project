/******************************************************************************************
 *  Date          : 05-March-2020
 *  Author        : Santosh Verma
 *  Description   : Calls platform trigger handler.
 *
 * Modifications  :  
 *
 ******************************************************************************************/
trigger BPG_Relationship_Trigger on ICRM_Contact_Relationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{ 

      BPG_Trigger_Handler_Utilities.handleEvent('ICRM_Contact_Relationship__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
 
}