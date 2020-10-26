/***********************************************************************************************
* @author           WuTong
* @date             2020/08/11
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAPSalesTarget
* @test class       CHCRM_KAPSalesTargetControllerTest
* history
* 2020/08/11  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAPSalesTargetController {
    
    @AuraEnabled
    public static Wrapper initData(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT ID , CHCRM_Sub_Channel_Account__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId];
        wrapper.subChannelAccountId = kap.CHCRM_Sub_Channel_Account__c;
        List<CHCRM_Sub_Channel_Sub_Account__c> subAccountList = [SELECT Id , Name ,CHCRM_Bill_To__c ,CHCRM_Sub_Channel_Sub_Account_Code__c FROM CHCRM_Sub_Channel_Sub_Account__c WHERE CHCRM_Sub_Channel_Account__c =:kap.CHCRM_Sub_Channel_Account__c];
        if(!subAccountList.isEmpty()){
            List<SubChannelSubAccount> subAccountDataList = new List<SubChannelSubAccount>();
            for(CHCRM_Sub_Channel_Sub_Account__c sub : subAccountList){
                SubChannelSubAccount subAccount = new SubChannelSubAccount();
                subAccount.Id = sub.Id;
                subAccount.Name = sub.CHCRM_Sub_Channel_Sub_Account_Code__c;
                subAccount.billToName = sub.CHCRM_Bill_To__c;
                subAccountDataList.add(subAccount);                
            }
            wrapper.subChannleSubAccountList = subAccountDataList;
        }
        List<CHCRM_KAP_Sales_Target__c> productBrandVarianceList = [Select c.CHCRM_1_Month_Business_Volume__c, c.CHCRM_1_Month_Gross_Margin__c, c.CHCRM_1_Month_Gross_Profit__c, c.CHCRM_1_Month_Sales_Target__c, c.CHCRM_1_Month_Turnover__c,
                                                                    c.CHCRM_10_Month_Business_Volume__c, c.CHCRM_10_Month_Gross_Margin__c, c.CHCRM_10_Month_Gross_Profit__c, c.CHCRM_10_Month_Sales_Target__c, c.CHCRM_10_Month_Turnover__c, 
                                                                    c.CHCRM_11_Month_Business_Volume__c, c.CHCRM_11_Month_Gross_Margin__c, c.CHCRM_11_Month_Gross_Profit__c, c.CHCRM_11_Month_Sales_Target__c, c.CHCRM_11_Month_Turnover__c,
                                                                    c.CHCRM_12_Month_Business_Volume__c, c.CHCRM_12_Month_Gross_Margin__c, c.CHCRM_12_Month_Gross_Profit__c, c.CHCRM_12_Month_Sales_Target__c, c.CHCRM_12_Month_Turnover__c,
                                                                    c.CHCRM_2_Month_Business_Volume__c, c.CHCRM_2_Month_Gross_Margin__c, c.CHCRM_2_Month_Gross_Profit__c, c.CHCRM_2_Month_Sales_Target__c, c.CHCRM_2_Month_Turnover__c, 
                                                                    c.CHCRM_3_Month_Business_Volume__c, c.CHCRM_3_Month_Gross_Margin__c, c.CHCRM_3_Month_Gross_Profit__c, c.CHCRM_3_Month_Sales_Target__c, c.CHCRM_3_Month_Turnover__c, 
                                                                    c.CHCRM_4_Month_Business_Volume__c, c.CHCRM_4_Month_Gross_Margin__c, c.CHCRM_4_Month_Gross_Profit__c, c.CHCRM_4_Month_Sales_Target__c, c.CHCRM_4_Month_Turnover__c, 
                                                                    c.CHCRM_5_Month_Business_Volume__c, c.CHCRM_5_Month_Gross_Margin__c, c.CHCRM_5_Month_Gross_Profit__c, c.CHCRM_5_Month_Sales_Target__c, c.CHCRM_5_Month_Turnover__c, 
                                                                    c.CHCRM_6_Month_Business_Volume__c, c.CHCRM_6_Month_Gross_Margin__c, c.CHCRM_6_Month_Gross_Profit__c, c.CHCRM_6_Month_Sales_Target__c, c.CHCRM_6_Month_Turnover__c, 
                                                                    c.CHCRM_7_Month_Business_Volume__c, c.CHCRM_7_Month_Gross_Margin__c, c.CHCRM_7_Month_Gross_Profit__c, c.CHCRM_7_Month_Sales_Target__c, c.CHCRM_7_Month_Turnover__c, 
                                                                    c.CHCRM_8_Month_Business_Volume__c, c.CHCRM_8_Month_Gross_Margin__c, c.CHCRM_8_Month_Gross_Profit__c, c.CHCRM_8_Month_Sales_Target__c, c.CHCRM_8_Month_Turnover__c, 
                                                                    c.CHCRM_9_Month_Business_Volume__c, c.CHCRM_9_Month_Gross_Margin__c, c.CHCRM_9_Month_Gross_Profit__c, c.CHCRM_9_Month_Sales_Target__c, c.CHCRM_9_Month_Turnover__c, 
                                                                    c.CHCRM_1_Month_GTO__c , c.CHCRM_2_Month_GTO__c ,  c.CHCRM_3_Month_GTO__c , c.CHCRM_4_Month_GTO__c , c.CHCRM_5_Month_GTO__c , c.CHCRM_6_Month_GTO__c,
                                                                    c.CHCRM_7_Month_GTO__c , c.CHCRM_8_Month_GTO__c , c.CHCRM_9_Month_GTO__c , c.CHCRM_10_Month_GTO__c , c.CHCRM_11_Month_GTO__c , c.CHCRM_12_Month_GTO__c , 
                                                                    c.CHCRM_Category__c, c.CHCRM_Coverage_Percent__c, c.CHCRM_Full_Year_Business_Volume__c, c.CHCRM_Full_Year_Gross_Margin__c, c.CHCRM_Full_Year_Gross_Profit__c, 
                                                                    c.CHCRM_Full_Year_Business_Volume_Input__c , c.CHCRM_Full_Year_Gross_Margin_Input__c , c.CHCRM_Full_Year_Gross_Profit_Input__c , c.CHCRM_Full_Year_GTO_Input__c,
                                                                    c.CHCRM_Full_Year_Target_Input__c , c.CHCRM_Full_Year_Turnover_Input__c ,
                                                                    c.CHCRM_Full_Year_GTO__c,c.CHCRM_Full_Year_Target__c, c.CHCRM_Full_Year_Turnover__c, c.CHCRM_In_Store_Share_Percent__c, c.CHCRM_Sales_Model__c, 
                                                                    c.CreatedDate, c.Id,c.CHCRM_Key_Account_Plan__c,
                                                                    c.CHCRM_SKU_Detail__c,c.CHCRM_PBV__c ,c.CHCRM_Sub_Channel_Sub_Account__c,
                                                                    c.CHCRM_Sub_Channel_Sub_Account__r.Name , c.CHCRM_Sub_Channel_Sub_Account__r.CHCRM_Bill_To__c , c.CHCRM_Sub_Channel_Sub_Account__r.CHCRM_Sub_Channel_Sub_Account_Code__c,
                                                                    c.CHCRM_SKU_Detail__r.CHCRM_SKU_Code__c , c.CHCRM_SKU_Detail__r.CHCRM_API__c , c.CHCRM_SKU_Detail__r.CHCRM_Product_Brand_Variant__c ,
										                            c.CHCRM_SKU_Detail__r.CHCRM_Product_Brand_Variant__r.Name , c.CHCRM_SKU_Detail__r.CHCRM_SKU_Description_EN__c ,
										                            c.CHCRM_SKU_Detail__r.CHCRM_Viscosity_Grade__c,
                                                                    c.CHCRM_PBV__r.Name , c.CHCRM_PBV__r.CHCRM_Parent_PBV_Name__c
                                                                    from CHCRM_KAP_Sales_Target__c c WHERE c.CHCRM_Key_Account_Plan__c =:recordId Order By c.CreatedDate DESC];
        if(!productBrandVarianceList.isEmpty()){
            List<CHCRM_KAP_Sales_Target__c> targetList = new List<CHCRM_KAP_Sales_Target__c>();
            List<CHCRM_KAP_Sales_Target__c> otherList = new List<CHCRM_KAP_Sales_Target__c>();
            for(CHCRM_KAP_Sales_Target__c cpbv : productBrandVarianceList){
                if(cpbv.CHCRM_Category__c == 'PBV'){
                    targetList.add(cpbv);
                }
                if(cpbv.CHCRM_Category__c == 'SKU'){
                    otherList.add(cpbv);
                }
            }
            if(!targetList.isEmpty()){
                List<TableData> targetViewList = convertObjectToView(targetList);
                wrapper.targetSetList = targetViewList;
            }
            if(!otherList.isEmpty()){
                List<TableData> otherViewList = convertObjectToView(otherList);
                wrapper.otherSetList = otherViewList;
            }
        }
        return wrapper;
    }
    
    @AuraEnabled
    public static void deleteRecord(String recordId){
        CHCRM_KAP_Sales_Target__c obj = new CHCRM_KAP_Sales_Target__c(Id = recordId);
        delete obj;
    }
    
    @AuraEnabled
    public static Wrapper initStatus(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id  , CHCRM_Status__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId];
        wrapper.isDraftFlag = kap.CHCRM_Status__c == 'Draft'? true:false;
        return wrapper;
    }
    
    
    
    
    private static List<TableData> convertObjectToView(List<CHCRM_KAP_Sales_Target__c> objList){
        List<TableData> resultList = new List<TableData>();
        for(CHCRM_KAP_Sales_Target__c obj : objList){
            TableData data = new TableData();
            data.id = obj.Id;
            //data.channel = obj.CHCRM_Channel__c;
            //data.sub_channel = obj.CHCRM_Sub_Channel__c;
            //data.accountName = obj.CHCRM_Account__c != null ? obj.CHCRM_Account__r.Name : '';
            //data.year = obj.CHCRM_Year__c;            
            data.salesModel = obj.CHCRM_Sales_Model__c;
            //data.billToName = obj.CHCRM_Bill_To__c != null ? obj.CHCRM_Bill_To__r.Name : '';
            //data.billToId = obj.CHCRM_Bill_To__c;
            data.Month01SalesTarget = obj.CHCRM_1_Month_Sales_Target__c;
            data.Month01BusinessVolume = obj.CHCRM_1_Month_Business_Volume__c;
            data.Month01GrossProfit = obj.CHCRM_1_Month_Gross_Profit__c;
            data.Month01GrossMargin = obj.CHCRM_1_Month_Gross_Margin__c;
            data.Month01Turnover = obj.CHCRM_1_Month_Turnover__c;
            data.Month01GTO = obj.CHCRM_1_Month_GTO__c;
            data.Month02SalesTarget = obj.CHCRM_2_Month_Sales_Target__c;
            data.Month02BusinessVolume = obj.CHCRM_2_Month_Business_Volume__c;
            data.Month02GrossProfit = obj.CHCRM_2_Month_Gross_Profit__c;
            data.Month02GrossMargin = obj.CHCRM_2_Month_Gross_Margin__c;
            data.Month02Turnover = obj.CHCRM_2_Month_Turnover__c;
            data.Month02GTO = obj.CHCRM_2_Month_GTO__c;
            data.Month03SalesTarget = obj.CHCRM_3_Month_Sales_Target__c;
            data.Month03BusinessVolume = obj.CHCRM_3_Month_Business_Volume__c;
            data.Month03GrossProfit = obj.CHCRM_3_Month_Gross_Profit__c;
            data.Month03GrossMargin = obj.CHCRM_3_Month_Gross_Margin__c;
            data.Month03Turnover = obj.CHCRM_3_Month_Turnover__c;
            data.Month03GTO = obj.CHCRM_3_Month_GTO__c;
            data.Month04SalesTarget = obj.CHCRM_4_Month_Sales_Target__c;
            data.Month04BusinessVolume = obj.CHCRM_4_Month_Business_Volume__c;
            data.Month04GrossProfit = obj.CHCRM_4_Month_Gross_Profit__c;
            data.Month04GrossMargin = obj.CHCRM_4_Month_Gross_Margin__c;
            data.Month04Turnover = obj.CHCRM_4_Month_Turnover__c;
            data.Month04GTO = obj.CHCRM_4_Month_GTO__c;
            data.Month05SalesTarget = obj.CHCRM_5_Month_Sales_Target__c;
            data.Month05BusinessVolume = obj.CHCRM_5_Month_Business_Volume__c;
            data.Month05GrossProfit = obj.CHCRM_5_Month_Gross_Profit__c;
            data.Month05GrossMargin = obj.CHCRM_5_Month_Gross_Margin__c;
            data.Month05Turnover = obj.CHCRM_5_Month_Turnover__c;
            data.Month05GTO = obj.CHCRM_5_Month_GTO__c;
            data.Month06SalesTarget = obj.CHCRM_6_Month_Sales_Target__c;
            data.Month06BusinessVolume = obj.CHCRM_6_Month_Business_Volume__c;
            data.Month06GrossProfit = obj.CHCRM_6_Month_Gross_Profit__c;
            data.Month06GrossMargin = obj.CHCRM_6_Month_Gross_Margin__c;
            data.Month06Turnover = obj.CHCRM_6_Month_Turnover__c;
            data.Month06GTO = obj.CHCRM_6_Month_GTO__c;
            data.Month07SalesTarget = obj.CHCRM_7_Month_Sales_Target__c;
            data.Month07BusinessVolume = obj.CHCRM_7_Month_Business_Volume__c;
            data.Month07GrossProfit = obj.CHCRM_7_Month_Gross_Profit__c;
            data.Month07GrossMargin = obj.CHCRM_7_Month_Gross_Margin__c;
            data.Month07Turnover = obj.CHCRM_7_Month_Turnover__c;
            data.Month07GTO = obj.CHCRM_7_Month_GTO__c;
            data.Month08SalesTarget = obj.CHCRM_8_Month_Sales_Target__c;
            data.Month08BusinessVolume = obj.CHCRM_8_Month_Business_Volume__c;
            data.Month08GrossProfit = obj.CHCRM_8_Month_Gross_Profit__c;
            data.Month08GrossMargin = obj.CHCRM_8_Month_Gross_Margin__c;
            data.Month08Turnover = obj.CHCRM_8_Month_Turnover__c;
            data.Month08GTO = obj.CHCRM_8_Month_GTO__c;
            data.Month09SalesTarget = obj.CHCRM_9_Month_Sales_Target__c;
            data.Month09BusinessVolume = obj.CHCRM_9_Month_Business_Volume__c;
            data.Month09GrossProfit = obj.CHCRM_9_Month_Gross_Profit__c;
            data.Month09GrossMargin = obj.CHCRM_9_Month_Gross_Margin__c;
            data.Month09Turnover = obj.CHCRM_9_Month_Turnover__c;
            data.Month09GTO = obj.CHCRM_9_Month_GTO__c;
            data.Month10SalesTarget = obj.CHCRM_10_Month_Sales_Target__c;
            data.Month10BusinessVolume = obj.CHCRM_10_Month_Business_Volume__c;
            data.Month10GrossProfit = obj.CHCRM_10_Month_Gross_Profit__c;
            data.Month10GrossMargin = obj.CHCRM_10_Month_Gross_Margin__c;
            data.Month10Turnover = obj.CHCRM_10_Month_Turnover__c;
            data.Month10GTO = obj.CHCRM_10_Month_GTO__c;
            data.Month11SalesTarget = obj.CHCRM_11_Month_Sales_Target__c;
            data.Month11BusinessVolume = obj.CHCRM_11_Month_Business_Volume__c;
            data.Month11GrossProfit = obj.CHCRM_11_Month_Gross_Profit__c;
            data.Month11GrossMargin = obj.CHCRM_11_Month_Gross_Margin__c;
            data.Month11Turnover = obj.CHCRM_11_Month_Turnover__c;
            data.Month11GTO = obj.CHCRM_11_Month_GTO__c;
            data.Month12SalesTarget = obj.CHCRM_12_Month_Sales_Target__c;
            data.Month12BusinessVolume = obj.CHCRM_12_Month_Business_Volume__c;
            data.Month12GrossProfit = obj.CHCRM_12_Month_Gross_Profit__c;
            data.Month12GrossMargin = obj.CHCRM_12_Month_Gross_Margin__c;
            data.Month12Turnover = obj.CHCRM_12_Month_Turnover__c;
            data.Month12GTO = obj.CHCRM_12_Month_GTO__c;
            /*data.fullYearSalesTarget = obj.CHCRM_Full_Year_Target__c;
data.fullYearBusinessVolume = obj.CHCRM_Full_Year_Business_Volume__c;
data.fullYearGrossProfit = obj.CHCRM_Full_Year_Gross_Profit__c;
data.fullYearGrossMargin = obj.CHCRM_Full_Year_Gross_Margin__c;
data.fullYearTurnover = obj.CHCRM_Full_Year_Turnover__c;
data.fullYearGTO = obj.CHCRM_Full_Year_GTO__c;*/
            data.fullYearSalesTarget = obj.CHCRM_Full_Year_Target_Input__c;
            data.fullYearBusinessVolume = obj.CHCRM_Full_Year_Business_Volume_Input__c;
            data.fullYearGrossProfit = obj.CHCRM_Full_Year_Gross_Profit_Input__c;
            data.fullYearGrossMargin = obj.CHCRM_Full_Year_Gross_Margin_Input__c;
            data.fullYearTurnover = obj.CHCRM_Full_Year_Turnover_Input__c;
            data.fullYearGTO = obj.CHCRM_Full_Year_GTO_Input__c;
            data.inStareShare = obj.CHCRM_In_Store_Share_Percent__c;
            data.coverage = obj.CHCRM_Coverage_Percent__c;
            data.subId = obj.CHCRM_Sub_Channel_Sub_Account__c;
            if(obj.CHCRM_Sub_Channel_Sub_Account__c != null){
                data.subCode = obj.CHCRM_Sub_Channel_Sub_Account__r.CHCRM_Sub_Channel_Sub_Account_Code__c;
                data.billToName = obj.CHCRM_Sub_Channel_Sub_Account__r.CHCRM_Bill_To__c;
            }            
            if(obj.CHCRM_Category__c == 'PBV' && !String.isBlank(obj.CHCRM_PBV__c)){                
                data.productName = obj.CHCRM_PBV__r.Name;
                data.productId = obj.CHCRM_PBV__c;
                data.productBrand = obj.CHCRM_PBV__r.CHCRM_Parent_PBV_Name__c;
            }
            if(obj.CHCRM_Category__c == 'SKU' && !String.isBlank(obj.CHCRM_SKU_Detail__c)){
                data.skuId = obj.CHCRM_SKU_Detail__c;
                data.skuCode = obj.CHCRM_SKU_Detail__r.CHCRM_SKU_Code__c;
                data.skuDesp = obj.CHCRM_SKU_Detail__r.CHCRM_SKU_Description_EN__c;
                data.productName = obj.CHCRM_SKU_Detail__r.CHCRM_Product_Brand_Variant__c != null ? obj.CHCRM_SKU_Detail__r.CHCRM_Product_Brand_Variant__r.Name : '';
            }
            resultList.add(data);
        }
        return resultList;
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/11
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSalesTargetController Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<TableData> targetSetList { get; set; }
        
        @AuraEnabled
        public List<TableData> otherSetList { get; set; }
        
        @AuraEnabled
        public Boolean isDraftFlag{get;set;}
        
        @AuraEnabled
        public List<SubChannelSubAccount> subChannleSubAccountList { get; set; }
        
        @AuraEnabled
        public String subChannelAccountId { get; set; }
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/11
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSalesTargetController Reture
    ************************************************************************************************/
    public with sharing class SubChannelSubAccount{
        @AuraEnabled
        public String Id{ get; set; }
        @AuraEnabled
        public String Name{ get; set; }
        @AuraEnabled
        public String selected{ get; set; }
        @AuraEnabled
        public String billToName{ get; set; }
        
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/11
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSalesTargetController Reture
    ************************************************************************************************/
    public with sharing class TableData{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String channel { get; set; }
        @AuraEnabled
        public String sub_channel { get; set; }
        @AuraEnabled
        public String skuId { get; set; }
        @AuraEnabled
        public String skuCode { get; set; }
       
        @AuraEnabled
        public String skuDesp { get; set; }
        @AuraEnabled
        public String productName { get; set; }
        @AuraEnabled
        public String productId { get; set; }
        @AuraEnabled
        public String accountName { get; set; }
        @AuraEnabled
        public String year { get; set; }
        @AuraEnabled
        public String salesModel { get; set; }
        @AuraEnabled
        public String billToName { get; set; }
        @AuraEnabled
        public String billToId { get; set; }
        @AuraEnabled
        public Decimal Month01SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month01BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month01GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month01GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month01Turnover { get; set; }
        @AuraEnabled
        public Decimal Month01GTO { get; set; }
        @AuraEnabled
        public Decimal Month02SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month02BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month02GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month02GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month02Turnover { get; set; }
        @AuraEnabled
        public Decimal Month02GTO { get; set; }
        @AuraEnabled
        public Decimal Month03SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month03BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month03GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month03GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month03Turnover { get; set; }
        @AuraEnabled
        public Decimal Month03GTO { get; set; }
        @AuraEnabled
        public Decimal Month04SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month04BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month04GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month04GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month04Turnover { get; set; }
        @AuraEnabled
        public Decimal Month04GTO { get; set; }
        @AuraEnabled
        public Decimal Month05SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month05BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month05GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month05GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month05Turnover { get; set; }
        @AuraEnabled
        public Decimal Month05GTO { get; set; }
        @AuraEnabled
        public Decimal Month06SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month06BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month06GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month06GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month06Turnover { get; set; }
        @AuraEnabled
        public Decimal Month06GTO { get; set; }
        @AuraEnabled
        public Decimal Month07SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month07BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month07GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month07GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month07Turnover { get; set; }
        @AuraEnabled
        public Decimal Month07GTO { get; set; }
        @AuraEnabled
        public Decimal Month08SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month08BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month08GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month08GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month08Turnover { get; set; }
        @AuraEnabled
        public Decimal Month08GTO { get; set; }
        @AuraEnabled
        public Decimal Month09SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month09BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month09GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month09GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month09Turnover { get; set; }
        @AuraEnabled
        public Decimal Month09GTO { get; set; }
        @AuraEnabled
        public Decimal Month10SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month10BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month10GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month10GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month10Turnover { get; set; }
        @AuraEnabled
        public Decimal Month10GTO { get; set; }
        @AuraEnabled
        public Decimal Month11SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month11BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month11GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month11GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month11Turnover { get; set; }
        @AuraEnabled
        public Decimal Month11GTO { get; set; }
        @AuraEnabled
        public Decimal Month12SalesTarget { get; set; }
        @AuraEnabled
        public Decimal Month12BusinessVolume { get; set; }
        @AuraEnabled
        public Decimal Month12GrossProfit { get; set; }
        @AuraEnabled
        public Decimal Month12GrossMargin { get; set; }
        @AuraEnabled
        public Decimal Month12Turnover { get; set; }
        @AuraEnabled
        public Decimal Month12GTO { get; set; }
        @AuraEnabled
        public Decimal fullYearSalesTarget { get; set; }
        @AuraEnabled
        public Decimal fullYearBusinessVolume { get; set; }
        @AuraEnabled
        public Decimal fullYearGrossProfit { get; set; }
        @AuraEnabled
        public Decimal fullYearGrossMargin { get; set; }
        @AuraEnabled
        public Decimal fullYearTurnover { get; set; }
        @AuraEnabled
        public Decimal fullYearGTO { get; set; }
        @AuraEnabled
        public Decimal inStareShare { get; set; }
        @AuraEnabled
        public Decimal coverage { get; set; }
        @AuraEnabled
        public String space{get; set;}
        @AuraEnabled
        public String masterBrand{get; set;}
        @AuraEnabled
        public String productType{get; set;}
        @AuraEnabled
        public String brandType{get; set;}
        @AuraEnabled
        public String productBrand{get; set;}
        @AuraEnabled
        public String api{get; set;}
        @AuraEnabled
        public String viscosityGrade{get; set;}
        @AuraEnabled
        public String subCode{get; set;}
        @AuraEnabled
        public String subId{get; set;}
        
    }
    
}