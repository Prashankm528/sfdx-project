/*****************************************************************************************
*   Date:           07JULY20
*   Author:         Abhishek Sharma – TCS (Tata Consultancy Services Ltd.)
*   Description:    Server-side controller sends list of Product and Insert the selected Products in an Opportunity
*   Modifications:  
****************************************************************************************/
public with sharing class GEFUE_Branded_Fetch_Product {
    
/*
 * Method call to fetch products based on terminal
 */
    
    @AuraEnabled
    public static List<OLIWrapperCls> fetchData(String recordId,String terminalId) {
        List<OLIWrapperCls> OLIWrapListObj = new List<OLIWrapperCls>();
        List<GEFUE_Product_Terminal__c> listProdTerm = new List<GEFUE_Product_Terminal__c>();
        
        Decimal UnitPrice  = 0;
        Decimal Quantity = 0.0;
        Boolean isTrue = true;
        String  productId = '';
        String  productName = '';
        String  productCode = '';
        String  brandedUnbranded = '';
        String  productDescription = '';
       
        
        if(terminalId != NULL){
            
            listProdTerm = [SELECT GEFUE_Product__c,GEFUE_Product_Name__c, GEFUE_Product_Code__c,GEFUE_Branded_Unbranded__c,GEFUE_Product_Description__c from GEFUE_Product_Terminal__c where GEFUE_Terminal__c=:terminalId ORDER BY GEFUE_Product_Description__c NULLS FIRST];
            
        }  
        
        for(GEFUE_Product_Terminal__c pt : listProdTerm){
            OLIWrapperCls wrapObject = new OLIWrapperCls();
            wrapObject.UnitPrice = 1;
            wrapObject.Quantity =  null;
            wrapObject.isTrue  = true;
            wrapObject.productId =  pt.GEFUE_Product__c;
            wrapObject.productName = pt.GEFUE_Product_Name__c;
            wrapObject.productCode = pt.GEFUE_Product_Code__c;
            wrapObject.brandedUnbranded =  pt.GEFUE_Branded_Unbranded__c;
            wrapObject.productDescription = pt.GEFUE_Product_Description__c;
            OLIWrapListObj.add(wrapObject);   
        }
        
        return OLIWrapListObj;
        
    }
 /* Created wrapper class to pass the list of fields belongs to different object.
 */   
    public with sharing class OLIWrapperCls {
        @AuraEnabled
        public Decimal UnitPrice;
        @AuraEnabled
        public Decimal Quantity;
        @AuraEnabled
        public Boolean isTrue;
        @AuraEnabled
        public String	productId;
        @AuraEnabled
        public String  productName;
        @AuraEnabled
        public String  productCode;
        @AuraEnabled
        public String brandedUnbranded;
        @AuraEnabled
        public String productDescription;
        
    }
    
/*
 * Method call to insert Products record in an Opportunity
 */    
    
    @AuraEnabled
    public static void insertOppLineItem(String productList,String draftedValues, String oppId){
        
  
        List<OLIWrapperCls> lstProduct = (List<OLIWrapperCls>)JSON.deserialize(productList, List<OLIWrapperCls>.class);
        List<OLIWrapperCls> lstDraftValue = (List<OLIWrapperCls>)JSON.deserialize(draftedValues, List<OLIWrapperCls>.class);
        
        Map<String,Decimal> mapProductAmount = new  Map<String,Decimal>();
        
        for(OLIWrapperCls draftObject : lstDraftValue){
            mapProductAmount.put(draftObject.productId,draftObject.Quantity);
        }
        
        String priceBookId =[Select id from PriceBook2 where Pricebook2.Name = 'Fuels NA Price Book'].Id;
        Id stdPricebookId = [select id, name from Pricebook2 where isStandard = true limit 1].Id;
        
        Map<Id,Id> mapPriceBookId = new Map<Id,Id>();
        
        Map<Id,PricebookEntry> mapProdIdPbEntryId = new Map<Id,PricebookEntry>();
        
        Set<Id> setProductId = new Set<Id>();
        
        for(OLIWrapperCls draftRecord : lstDraftValue){
            setProductId.add(draftRecord.productId);
        }
        
        Map<Id, PricebookEntry> test = new Map<Id, PricebookEntry>([Select Id, Product2Id, Pricebook2Id FROM PricebookEntry where Product2Id =:setProductId AND Pricebook2.Id =:priceBookId ]);
		
        for(PricebookEntry obj : test.values()){
            mapPriceBookId.put(obj.Product2Id, obj.Id);
        }
        
        List<PricebookEntry> lstStandardPriceBookEntry = new List<PricebookEntry>();
        
        for(Id prodId : setProductId){
            if(mapPriceBookId.get(prodId) == null){
                PricebookEntry pbStdEntry = new PricebookEntry(Pricebook2Id=stdPricebookId,Product2Id = prodId,UnitPrice = 1.00,IsActive = true);
                PricebookEntry pbCustEntry = new PricebookEntry(Pricebook2Id=priceBookId,Product2Id = prodId,UnitPrice = 1.00,IsActive = true);
                lstStandardPriceBookEntry.add(pbStdEntry);
                mapProdIdPbEntryId.put(prodId,pbCustEntry);
            }
        }
        
        insert lstStandardPriceBookEntry;
        insert mapProdIdPbEntryId.values();
        
        for(OLIWrapperCls prodTemp : lstProduct){
            for(OLIWrapperCls draftTemp : lstDraftValue){
                if(prodTemp.productId == draftTemp.productId){
                   prodTemp.UnitPrice = draftTemp.UnitPrice;
                    prodTemp.Quantity = draftTemp.Quantity;
                    
                }
            }
        }
        
        Pricebook2 standardPb=[select id from Pricebook2 where isStandard=true];
        Pricebook2 customPb=[Select id from Pricebook2 where Pricebook2.Name = 'Fuels NA Price Book'];
        
        
        List<PricebookEntry> lstStdPriceBookEntry = new List<PricebookEntry>();
 
        List<OpportunityLineItem> lstOpptyLineItem =  new  List<OpportunityLineItem>();
        for(OLIWrapperCls wrapObject : lstProduct ){
            if(mapPriceBookId.get(wrapObject.productId)!=Null){
            OpportunityLineItem objectOLI = new OpportunityLineItem(OpportunityId=oppId,PriceBookEntryId=mapPriceBookId.get(wrapObject.productId), Quantity=mapProductAmount.get(wrapObject.productId), Unitprice=1);
            lstOpptyLineItem.add(objectOLI);
            }
            else{
             OpportunityLineItem objectOLI = new OpportunityLineItem(OpportunityId=oppId,PriceBookEntryId=mapProdIdPbEntryId.get(wrapObject.productId).Id, Quantity=mapProductAmount.get(wrapObject.productId), Unitprice=1);   
            lstOpptyLineItem.add(objectOLI);
            }
          
            
        }
        
        insert lstOpptyLineItem;
        
    }
    
    
}