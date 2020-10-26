/**
 * @author			Abhinit Kohar
 * @date			29/06/2020
 * @group			CAJBP
 * @description		handles triggers of CAJBP_Product_Mix_Target_Item__c object
 */

public with sharing class CAJBP_ProductMixTargetItemTriggerHandler extends BPG_Trigger_Handler_Utilities {

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        CAJBP_ProductMixTargetItemHelper.updateJBPId((list<CAJBP_Product_Mix_Target_Item__c>) newList);
    }

    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        CAJBP_ProductMixTargetItemHelper.updateProductMixTargetItemJBPId((list<CAJBP_Product_Mix_Target_Item__c>) newList);
    }
}