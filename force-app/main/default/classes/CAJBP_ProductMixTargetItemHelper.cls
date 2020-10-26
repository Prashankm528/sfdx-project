/**
 * @author			Abhinit Kohar
 * @date			29/06/2020
 * @group			CAJBP
 * @description		helper class for CAJBP_Product_Mix_Target_Item__c
 */

public with sharing class CAJBP_ProductMixTargetItemHelper {

    public static void updateJBPId(list<CAJBP_Product_Mix_Target_Item__c> productMixTargetItems) {

        set<Id> productMixTargetIds = new set<Id>();

        if (!productMixTargetItems.isEmpty()) {
            for (CAJBP_Product_Mix_Target_Item__c pmti : productMixTargetItems) {
                if (pmti.CAJBP_Product_Mix_Target__c != null || pmti.CAJBP_Product_Mix_Target__c != '') {
                    productMixTargetIds.add(pmti.CAJBP_Product_Mix_Target__c);
                }
            }

            if (!productMixTargetIds.isEmpty()) {
                map<Id, CAJBP_Product_Mix_Target__c> pmtMap = new map<Id, CAJBP_Product_Mix_Target__c>([select Id, CAJBP_Joint_Business_Plan__c from CAJBP_Product_Mix_Target__c where id in : productMixTargetIds]);

                for (CAJBP_Product_Mix_Target_Item__c pmtItem : productMixTargetItems) {
                    if (pmtItem.CAJBP_Product_Mix_Target__c != null || pmtItem.CAJBP_Product_Mix_Target__c != '') {
                        pmtItem.CAJBP_Joint_Business_Plan__c = pmtMap.get(pmtItem.CAJBP_Product_Mix_Target__c).CAJBP_Joint_Business_Plan__c;
                    }
                }
            }
        }
    }

    public static void updateProductMixTargetItemJBPId(list<CAJBP_Product_Mix_Target_Item__c> productMixTargetItems) {
        list<CAJBP_Product_Mix_Target_Item__c> pmtiList = new list<CAJBP_Product_Mix_Target_Item__c>();
        if (!productMixTargetItems.isEmpty()) {
            for (CAJBP_Product_Mix_Target_Item__c pmti : productMixTargetItems) {
                if (pmti.CAJBP_Joint_Business_Plan__c == null) {
                    pmtiList.add(pmti);
                }
            }
        }

        if(!pmtiList.isEmpty()){
            updateJBPId(pmtiList);
        }
    }
}