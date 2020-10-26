/*****************************************************************************************
*	    Date:		    2020-05-22
*       Author:         Xc
*       Description:    The Generic Trigger on Event. Please add your product specific handler into the EventTriggerHandler.cls
*                       If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
*       Modifications:  
****************************************************************************************/
trigger CHCRM_EventTrigger on CHCRM_Event__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    BPG_Trigger_Handler_Utilities.handleEvent('CHCRM_Event__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}