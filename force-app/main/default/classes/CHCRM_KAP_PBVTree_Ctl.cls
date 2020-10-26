/***********************************************************************************************
* @author           WuTong
* @date             2020/09/05
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_PBVTree_CMP
* @test class       CHCRM_KAP_PBVTree_CtlTest
* history
* 2020/09/05  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_PBVTree_Ctl {
    
    @AuraEnabled(cacheable=true)
    public static Wrapper initData(){
        Wrapper wrapper = new Wrapper();
        List<CHCRM_PBV_Detail__c> pbvList = [SELECT Id , Name From CHCRM_PBV_Detail__c WHERE CHCRM_Parent_PBV__c = ''];
        if(!pbvList.isEmpty()){
            Map<Id , List<CHCRM_PBV_Detail__c>> pbvMap = new Map<Id , List<CHCRM_PBV_Detail__c>>();
            for(CHCRM_PBV_Detail__c pro : [SELECT Id , Name , CHCRM_Parent_PBV__c FROM CHCRM_PBV_Detail__c WHERE CHCRM_Parent_PBV__c != '']){
                if(pbvMap.containsKey(pro.CHCRM_Parent_PBV__c)){
                    pbvMap.get(pro.CHCRM_Parent_PBV__c).add(pro);
                }else{
                    pbvMap.put(pro.CHCRM_Parent_PBV__c , new List<CHCRM_PBV_Detail__c>{pro});
                }
            }
            List<WrapperItem> wrapperlist = new List<WrapperItem>();
            Map<String,String> mapping = new Map<String,String>();
            for(CHCRM_PBV_Detail__c pro : pbvList){
                WrapperItem item = new WrapperItem();
                item.label = pro.Name;
                item.name = pro.Id;
                item.disabled = false;
                item.expanded = true;
                mapping.put(pro.Id , pro.Name);
                //createpbvTree(item,pro,pbvMap,mapping);
                wrapperlist.add(item);
            }
            wrapper.mapping = mapping;
            wrapper.items = wrapperlist;            
        }     
        return wrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static Wrapper findPBVByPBCode(String pbId){
        Wrapper wrapper = new Wrapper();
        List<CHCRM_PBV_Detail__c> pbvList = [SELECT Id , Name From CHCRM_PBV_Detail__c WHERE CHCRM_Parent_PBV__c = :pbId];
        if(!pbvList.isEmpty()){
            List<WrapperItem> wrapperlist = new List<WrapperItem>();
            for(CHCRM_PBV_Detail__c pbv : pbvList){
                WrapperItem item = new WrapperItem();
                item.label = pbv.Name;
                item.value = pbv.Id;
                wrapperlist.add(item);
            }
            wrapper.items = wrapperlist;
            System.debug('wrapperlist : ' + wrapperlist);
        }
        return wrapper;
    }
    
    /*private static void createpbvTree(WrapperItem parentTtem , CHCRM_PBV_Detail__c pbv , Map<Id , List<CHCRM_PBV_Detail__c>> pbvMap ,Map<String,String> mapping){
        if(pbvMap.get(pbv.Id) != null){
            List<WrapperItem> wrapperlist = new List<WrapperItem>();
            for(CHCRM_PBV_Detail__c pro : (List<CHCRM_PBV_Detail__c>)pbvMap.get(pbv.Id)){
                WrapperItem item = new WrapperItem();
                item.label = pro.Name;
                item.name = pro.Id;
                item.disabled = false;
                item.expanded = true;
                mapping.put(pro.Id , pro.Name);
                createpbvTree(item,pro,pbvMap,mapping);                
                wrapperlist.add(item);
            }
            parentTtem.items = wrapperlist;            
        }        
    }*/
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/05
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_PBVTree_CMP Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<WrapperItem> items{get;set;}
        @AuraEnabled
        public Map<String,String> mapping{get;set;}
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/09/05
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_PBVTree_CMP Reture
    ************************************************************************************************/
    public with sharing class WrapperItem{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public Boolean disabled{get;set;}
        @AuraEnabled
        public Boolean expanded{get;set;}
        @AuraEnabled
        public List<WrapperItem> items{get;set;}
    }
    
}