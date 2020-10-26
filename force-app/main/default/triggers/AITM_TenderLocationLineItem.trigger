/*trigger AITM_TenderLocationLineItem on AITM_Tender_Location_Line_Item__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(AITM_DeactivateTriggerSetting__c.getInstance() != null && !AITM_DeactivateTriggerSetting__c.getInstance().AITM_IsActive__c) {
        return;
    }
    AITM_TriggerFactory factory = new AITM_TriggerFactory(AITM_Tender_Location_Line_Item__c.sObjectType);
    factory.execute();  
}*/
trigger AITM_TenderLocationLineItem on AITM_Tender_Location_Line_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   BPG_Trigger_Handler_Utilities.handleEvent('AITM_Tender_Location_Line_Item__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
}