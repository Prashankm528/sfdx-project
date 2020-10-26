trigger Managed_ClauseBothTrigger on APXT_Redlining__Managed_Clause__c (after insert, before insert, before update, after update, before delete, after delete) { 
    FSTR.COTriggerHandler.handleBothTrigger();
}