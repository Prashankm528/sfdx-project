trigger PCRM_opportunityLineItemTrigger on OpportunityLineItem (after insert, before insert) {
    
    BPG_Trigger_Handler_Utilities.handleEvent('OpportunityLineItem', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);

}