/***********************************************************************************************
* @author           WuTong
* @date             2020/09/05
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_ProductTypeTree_CMP
* @test class       CHCRM_KAP_ProductTypeTree_CtlTest
* history
* 2020/09/05  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_ProductTypeTree_Ctl {
    
    @AuraEnabled(cacheable=true)
    public static Wrapper initData(){
        Wrapper wrapper = new Wrapper();
        List<CHCRM_Product_Structure__c> productList = [SELECT Id , Name From CHCRM_Product_Structure__c WHERE CHCRM_Parent_Product__c = '' Order By CHCRM_Priority__c];
        if(!productList.isEmpty()){
            Map<Id , List<CHCRM_Product_Structure__c>> productMap = new Map<Id , List<CHCRM_Product_Structure__c>>();
            for(CHCRM_Product_Structure__c pro : [SELECT Id , Name , CHCRM_Parent_Product__c FROM CHCRM_Product_Structure__c WHERE CHCRM_Parent_Product__c != '' Order By CHCRM_Priority__c]){
                if(productMap.containsKey(pro.CHCRM_Parent_Product__c)){
                    productMap.get(pro.CHCRM_Parent_Product__c).add(pro);
                }else{
                    productMap.put(pro.CHCRM_Parent_Product__c , new List<CHCRM_Product_Structure__c>{pro});
                }
            }
            List<WrapperItem> wrapperlist = new List<WrapperItem>();
            Map<String,String> mapping = new Map<String,String>();
            for(CHCRM_Product_Structure__c pro : productList){
                WrapperItem item = new WrapperItem();
                item.label = pro.Name;
                item.name = pro.Id;
                item.disabled = false;
                item.expanded = true;
                mapping.put(pro.Id , pro.Name);
                createProductTree(item,pro,productMap,mapping);
                wrapperlist.add(item);
            }
            wrapper.mapping = mapping;
            wrapper.items = wrapperlist;            
        }     
        return wrapper;
    }
     @AuraEnabled()
    public static Wrapper findSKUByProductId(String productId){
        Wrapper wrapper = new Wrapper();
        List<CHCRM_SKU_Detail__c> skuList = [SELECT Id,Name , CHCRM_SKU_Code__c FROM CHCRM_SKU_Detail__c WHERE CHCRM_Product_Brand_Variant__c =:productId];
        if(!skuList.isEmpty()){
            List<SKU> skus = new List<SKU>();
            for(CHCRM_SKU_Detail__c sku : skuList){
                SKU skuData = new SKU();
                skuData.label = sku.CHCRM_SKU_Code__c;
                skuData.value = sku.Id;
                skus.add(skuData);
            }
            wrapper.skuList = skus;
        }
        return wrapper;
    }
    
    private static void createProductTree(WrapperItem parentTtem , CHCRM_Product_Structure__c product , Map<Id , List<CHCRM_Product_Structure__c>> productMap ,Map<String,String> mapping){
        if(productMap.get(product.Id) != null){
            List<WrapperItem> wrapperlist = new List<WrapperItem>();
            for(CHCRM_Product_Structure__c pro : (List<CHCRM_Product_Structure__c>)productMap.get(product.Id)){
                WrapperItem item = new WrapperItem();
                item.label = pro.Name;
                item.name = pro.Id;
                item.disabled = false;
                item.expanded = true;
                mapping.put(pro.Id , pro.Name);
                createProductTree(item,pro,productMap,mapping);                
                wrapperlist.add(item);
            }
            parentTtem.items = wrapperlist;            
        }        
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/05
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_ProductTypeTree_CMP Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<WrapperItem> items{get;set;}
        @AuraEnabled
        public List<SKU> skuList{get;set;}
        @AuraEnabled
        public Map<String,String> mapping{get;set;}
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/05
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_ProductTypeTree_CMP Reture
    ************************************************************************************************/
    public with sharing class SKU{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/05
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_ProductTypeTree_CMP Reture
    ************************************************************************************************/
    public with sharing class WrapperItem{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public Boolean disabled{get;set;}
        @AuraEnabled
        public Boolean expanded{get;set;}
        @AuraEnabled
        public List<WrapperItem> items{get;set;}
    }
    
}