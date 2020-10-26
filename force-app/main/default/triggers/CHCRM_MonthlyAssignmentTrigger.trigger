/*****************************************************************************************
*       Date:           2020-08-14
*       Author:         Xc
*       Description:    The Generic Trigger on CHCRM_HQ_Monthly_Assgmnt__c. Please add your product specific handler into the CHCRM_HQMonthlyAssignmentTriggerHandler.cls
*                       If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
*       Modifications:  
****************************************************************************************/
trigger CHCRM_MonthlyAssignmentTrigger on CHCRM_HQ_Monthly_Assgmnt__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    BPG_Trigger_Handler_Utilities.handleEvent('CHCRM_HQ_Monthly_Assgmnt__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}