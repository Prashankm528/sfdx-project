/**
 * @author srnandan
 * @date 04/11/2019
 * @description triggers on AITM_Tender_Location_Taxes_and_Fees__c object
 * 
 */
trigger AITM_TenderLocationTaxFeesTrigger on AITM_Tender_Location_Taxes_and_Fees__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   BPG_Trigger_Handler_Utilities.handleEvent('AITM_Tender_Location_Taxes_and_Fees__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
}