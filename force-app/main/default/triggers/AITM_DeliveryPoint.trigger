trigger AITM_DeliveryPoint on AITM_Delivery_Point__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AITM_TriggerFactory factory = new AITM_TriggerFactory(AITM_Delivery_Point__c.sObjectType);
    factory.execute();
}