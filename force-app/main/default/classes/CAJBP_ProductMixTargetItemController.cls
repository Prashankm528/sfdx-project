/**
 * @author			Venkatesh Muniyasamy
 * @date			13/08/2020
 * @group			CAJBP
 * @description		Edit Product Brands for Product Mix Target Item.
 *
 * history
 * 13/08/2020	Venkatesh Muniyasamy	    Edit Product Brands
 */
public with sharing class CAJBP_ProductMixTargetItemController {

    public static Map<string,List<option>> result = new Map<string,List<option>>();
    public static set<id> productId = new set<id>();

    //To get the Product Brand Options from the Picklist entry
    @AuraEnabled(Cacheable = false)
    public static Map<string,List<option>> getProductBrandOptions(Id pmtId) {
        try
        {
            Schema.DescribeFieldResult fieldResult = CAJBP_Product_Mix_Target_Item__c.CAJBP_Product_Brand__c.getDescribe();
            List<Schema.PicklistEntry> productBrandList = fieldResult.getPicklistValues();
            List<Option> optionList = new List<Option>();

            for(schema.PicklistEntry pickValue : productBrandList )
            {
                optionList.add(new Option(pickValue));  
            }
            result.put('Options',optionList);

            List<Option> selectedList = new List<Option>();
            for(CAJBP_Product_Mix_Target_Item__c selectedValue : getProductMixTargetItems(pmtId) )
            {
                selectedList.add(new Option(selectedValue));
            }
            result.put('Selected',selectedList);
            return result;
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //To retrieve the Product Mix Target items for the given Product Mix Target
    public static List<CAJBP_Product_Mix_Target_Item__c> getProductMixTargetItems(Id pmtId)
    {
        return [SELECT Id, CAJBP_Product_Brand__c,CAJBP_Product_Variant__r.Name FROM CAJBP_Product_Mix_Target_Item__c
        WHERE CAJBP_Product_Mix_Target__c = :pmtId and CAJBP_Product_Brand__c !=null];
    }

    // Save the Product Brand Options selected for the Product Mix Target Item
    @AuraEnabled
    public static void saveProductBrands(Id pmtId,List<string> selected)
    {
       try
       {
            List<CAJBP_Product_Mix_Target_Item__c> productItemsToDelete = new List<CAJBP_Product_Mix_Target_Item__c>();
            List<CAJBP_Product_Mix_Target_Item__c> productItemsToInsert = new List<CAJBP_Product_Mix_Target_Item__c>();
            List<CAJBP_Product_Mix_Target_Item__c> productBrands =  getProductMixTargetItems(pmtId);
            List<String> currentProductBrands = new List<string>();

            for(CAJBP_Product_Mix_Target_Item__c items : productBrands)
            {
                currentProductBrands.add(items.CAJBP_Product_Brand__c);

                if(! selected.contains(items.CAJBP_Product_Brand__c))
                {
                    productItemsToDelete.add(items);
                }
            }

            if(productItemsToDelete.size()>0)
            {
                delete  productItemsToDelete;
            }

            for(string selectedProductBrand : selected)
            {
                if(! currentProductBrands.contains(selectedProductBrand))
                {
                    productItemsToInsert.add(new CAJBP_Product_Mix_Target_Item__c (CAJBP_Product_Mix_Target__c = pmtId, CAJBP_Product_Brand__c = selectedProductBrand));
                }
            }

            if(productItemsToInsert.size() > 0)
            {
                insert productItemsToInsert;
            }
        }
        catch(Exception ex)
        {
            throw new AuraHandledException('Records didn\'t save. ' + ex.getMessage());
        }

    }

    public class Option {
        @AuraEnabled
        public string label {get; set;}
        @AuraEnabled
        public string value {get; set;}

        public Option(CAJBP_Product_Mix_Target_Item__c item) {
            this.value = item.CAJBP_Product_Brand__c;
        }

        public Option(Schema.PicklistEntry item) {
            this.label = item.label;
            this.value = item.value;
        }
    }
}