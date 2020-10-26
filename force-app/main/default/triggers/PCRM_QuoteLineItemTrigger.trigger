/*****************************************************************************************
*   Date: 11/07/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Trigger is used to sync quoteline item custom field with OLI fieldsete
*   Version 1.1 
****************************************************************************************/
trigger PCRM_QuoteLineItemTrigger on QuoteLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     
    BPG_Trigger_Handler_Utilities.handleEvent('QuoteLineItem', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    
}