/*****************************************************************************************
*	    Date:		    10APR2018
*       Author:         Maros Zilka
*       Description:    The Generic Trigger on Event. Please add your product specific handler into the EventTriggerHandler.cls
*                       If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
*       Modifications:  25NOV2019 Rahma Belghouti - Refactor the trigger to use the trigger handler framework
****************************************************************************************/
 
trigger EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    BPG_Trigger_Handler_Utilities.handleEvent('Event', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}