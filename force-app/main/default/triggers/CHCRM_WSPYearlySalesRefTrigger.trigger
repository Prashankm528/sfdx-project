/*****************************************************************************************
*       Date:           2020-08-20
*       Author:         DK
*       Description:    The Generic Trigger on CHCRM_WSP_Yearly_SalesRef__c. Please add your product specific handler into the CHCRM_WSPYearlySalesRefTriggerHandler.cls
*                       If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
*       Modifications:  
****************************************************************************************/
trigger CHCRM_WSPYearlySalesRefTrigger on CHCRM_WSP_Yearly_SalesRef__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    BPG_Trigger_Handler_Utilities.handleEvent('CHCRM_WSP_Yearly_SalesRef__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}