trigger AITM_TenderAccount on AITM_Tender_Account__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	BPG_Trigger_Handler_Utilities.handleEvent('AITM_Tender_Account__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
    
}