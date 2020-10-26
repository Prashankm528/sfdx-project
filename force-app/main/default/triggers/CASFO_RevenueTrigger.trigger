/************************************************************************************************************
* Description : Apex trigger for the Opportunity Revenue object.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2020-July-01   1.0                SFO Team           Initial version 
*
*************************************************************************************************************/

trigger CASFO_RevenueTrigger on Revenue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    BPG_Trigger_Handler_Utilities.handleEvent('Revenue__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}