trigger AITM_Location on AITM_Location__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AITM_TriggerFactory factory = new AITM_TriggerFactory(AITM_Location__c.sObjectType);
    factory.execute();
}