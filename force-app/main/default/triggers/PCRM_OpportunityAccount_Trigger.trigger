/*****************************************************************************************
*   Date: 06/06/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Trigger is used to add or remove opportunity line item after undelete or delete
*   Version 1.1 
****************************************************************************************/
trigger PCRM_OpportunityAccount_Trigger on PCRM_Opportunity_Account__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     
    BPG_Trigger_Handler_Utilities.handleEvent('PCRM_Opportunity_Account__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    
}