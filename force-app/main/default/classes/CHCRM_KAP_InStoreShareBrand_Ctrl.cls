/***********************************************************************************************
* @author           WuTong
* @date             2020/09/12
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_InStoreShareBrand_CMP
* @test class       CHCRM_KAP_InStoreShareBrand_CtrlTest
* history
* 2020/09/12  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_InStoreShareBrand_Ctrl {
    
    public static final Id CHCRM_RECORDTYPE = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('CHCRM_Competitor').getRecordTypeId();
    
    @AuraEnabled
    public static Wrapper initInShoreShareBrand(String kapId){
        Wrapper wrapper = new Wrapper();
        List<Competitor__c> competitorList = [SELECT Id FROM Competitor__c WHERE CHCRM_Main_Stream__c = true AND RecordTypeId =:CHCRM_RECORDTYPE LIMIT 10];
        Set<Id> allCompetitorIdSet = new Set<Id>();
        for(Competitor__c c : competitorList){
            allCompetitorIdSet.add(c.Id);
        }
        List<CHCRM_KAP_In_Store_Share_Brand__c> inStoreShareList = findInStoreShareBrandListByKapId(kapId);
        Set<Id> competitorIdSet = new Set<Id>();
        if(!inStoreShareList.isEmpty()){                
            for(CHCRM_KAP_In_Store_Share_Brand__c inStoreShare : inStoreShareList){
                competitorIdSet.add(inStoreShare.CHCRM_Supplier__c);
            }
            createInStoreShare(allCompetitorIdSet , competitorIdSet , kapId);
        }else{
            createInStoreShare(allCompetitorIdSet , competitorIdSet , kapId);
        }
        wrapper.inStoreShareList = createWrapperList(findInStoreShareBrandListByKapId(kapId));
        CHCRM_Key_Account_Plan__c kap = [SELECT Id  , CHCRM_Status__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:kapId];
        wrapper.isDraftFlag = kap.CHCRM_Status__c == 'Draft'? true:false;
        return wrapper;
    }
    
    
    private static void createInStoreShare(Set<Id> allCompetitorIdSet , Set<Id> competitorIdSet  , Id kapId){
        List<CHCRM_KAP_In_Store_Share_Brand__c> inStoreShareList = new List<CHCRM_KAP_In_Store_Share_Brand__c>();
        for(Id cId : allCompetitorIdSet){
            System.debug('cId : ' + cId);
            System.debug(!competitorIdSet.contains(cId));
            if(!competitorIdSet.contains(cId)){
                CHCRM_KAP_In_Store_Share_Brand__c inStoreShare = new CHCRM_KAP_In_Store_Share_Brand__c();
                inStoreShare.CHCRM_Supplier__c = cId;
                inStoreShare.CHCRM_Share_of_wallet_VOL__c = 0.00;
                inStoreShare.Key_Account_Plan__c = kapId;
                inStoreShareList.add(inStoreShare);
            }
        }
        
        if(!inStoreShareList.isEmpty()){
            insert inStoreShareList;
        }
    }
    
    @AuraEnabled
    public static void updateRecords(List<WrapperItem> records){
        List<CHCRM_KAP_In_Store_Share_Brand__c> updateRecords = new List<CHCRM_KAP_In_Store_Share_Brand__c>();
        for(WrapperItem item : records){
            CHCRM_KAP_In_Store_Share_Brand__c inStoreShare = new CHCRM_KAP_In_Store_Share_Brand__c();
            inStoreShare.Id = item.id;
            if(item.shareOfWalletVol != null){
                inStoreShare.CHCRM_Share_of_wallet_VOL__c = item.shareOfWalletVol; 
            }
            if(String.isNotBlank(item.productCategory)){
                inStoreShare.CHCRM_Product_Category__c = item.productCategory; 
            }
            if(String.isNotBlank(item.validityOfContract)){
                inStoreShare.CHCRM_Validity_of_contract__c = item.validityOfContract; 
            }            
            updateRecords.add(inStoreShare);
        }
        if(!updateRecords.isEmpty()){
            update updateRecords;       
        }
    }
    
    private static List<CHCRM_KAP_In_Store_Share_Brand__c> findInStoreShareBrandListByKapId(Id kapId){
        return [SELECT Id ,Name , 
                CHCRM_Comment__c , CHCRM_Competitors_Business_Overview__c ,
                CHCRM_Product_Category__c , CHCRM_Share_of_wallet_VOL__c,
                CHCRM_Supplier__c , CHCRM_Supplier__r.Name ,CHCRM_Validity_of_contract__c,
                Key_Account_Plan__c
                FROM CHCRM_KAP_In_Store_Share_Brand__c WHERE Key_Account_Plan__c =:kapId];
    }
    
    private static List<WrapperItem> createWrapperList(List<CHCRM_KAP_In_Store_Share_Brand__c> inStoreShareList){
        List<WrapperItem> inStoreShareWrapperList = new List<WrapperItem>();
        for(CHCRM_KAP_In_Store_Share_Brand__c inStoreShare : inStoreShareList){
            WrapperItem item = new WrapperItem();
            item.id = inStoreShare.Id;
            item.supplier = inStoreShare.CHCRM_Supplier__c == null?'':inStoreShare.CHCRM_Supplier__r.Name;
            item.supplierUrl = '/'+inStoreShare.CHCRM_Supplier__c;
            item.shareOfWalletVol = inStoreShare.CHCRM_Share_of_wallet_VOL__c;
            //item.competitorsOverview = inStoreShare.CHCRM_Competitors_Business_Overview__c;
            item.productCategory = inStoreShare.CHCRM_Product_Category__c;
            item.validityOfContract = inStoreShare.CHCRM_Validity_of_contract__c;
            inStoreShareWrapperList.add(item);
        }
        return inStoreShareWrapperList;
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/12
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_InStoreShareBrand_CMP Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<WrapperItem> inStoreShareList {set;get;}
        @AuraEnabled
        public Boolean isDraftFlag{get;set;}        
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/12
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_InStoreShareBrand_CMP Reture
    ************************************************************************************************/
    public with sharing class WrapperItem{
        @AuraEnabled
        public String id {set;get;}
        @AuraEnabled
        public String supplier {set;get;}
        @AuraEnabled
        public String supplierUrl {set;get;}
        @AuraEnabled
        public Decimal shareOfWalletVol {set;get;}
        @AuraEnabled
        public String competitorsOverview {set;get;}
        @AuraEnabled
        public String productCategory {set;get;}
        @AuraEnabled
        public String validityOfContract {set;get;}
    }
    
    
    
    
    
}