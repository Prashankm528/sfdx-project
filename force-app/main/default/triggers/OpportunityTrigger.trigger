/************************************************************************************************************
* Description : Apex trigger for the Opportunity object. This trigger will send Chatter message whenever there
*               is inactive product and the opportunity is moved from closed to open stage.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-01   1.0                 Maros Zilka         Initial version 
*
*************************************************************************************************************/

trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    BPG_Trigger_Handler_Utilities.handleEvent('Opportunity', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}