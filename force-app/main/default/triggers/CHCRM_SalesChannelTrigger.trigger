/*****************************************************************************************
*	    Date:		    2020-06-19
*       Author:         Xc
*       Description:    The Generic Trigger on CHCRM_Sales_Channel__c. Please add your product specific handler into the CHCRM_SalesChannelTriggerHandler.cls
*                       If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
*       Modifications:  
****************************************************************************************/
trigger CHCRM_SalesChannelTrigger on CHCRM_Sales_Channel__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    BPG_Trigger_Handler_Utilities.handleEvent('CHCRM_Sales_Channel__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}