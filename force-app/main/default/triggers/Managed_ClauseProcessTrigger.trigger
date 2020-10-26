trigger Managed_ClauseProcessTrigger on APXT_Redlining__Managed_Clause__c (after insert, before insert, before update, after update, before delete){
    FSTR.COTriggerHandler.handleProcessObjectTrigger();
}