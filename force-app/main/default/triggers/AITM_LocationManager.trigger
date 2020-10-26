trigger AITM_LocationManager on AITM_Location_Manager__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AITM_TriggerFactory factory = new AITM_TriggerFactory(AITM_Location_Manager__c.sObjectType);
    factory.execute();
}