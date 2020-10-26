/**
 * @Who     Platform Team - Customer Org <adam.walker1@bp.com>
 * @when    10-04-2018
 * @what    The Generic Trigger on ContentDocumentLink. Please add your product specific handler into the ContentDocumentLinkTriggerHandler.cls
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/


trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    system.debug('Trigger.operationType :'+Trigger.operationType);
    BPG_Trigger_Handler_Utilities.handleEvent('ContentDocumentLink', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}