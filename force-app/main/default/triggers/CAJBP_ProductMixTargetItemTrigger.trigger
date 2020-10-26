/**
 * @author 			Abhinit Kohar
 * @date 			26/06/2020
 * @group			CAJBP
 * @description     triggers on CAJBP_Product_Mix_Target_Item__c object
 */

trigger CAJBP_ProductMixTargetItemTrigger on CAJBP_Product_Mix_Target_Item__c (before insert, before update) {
    BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Product_Mix_Target_Item__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}