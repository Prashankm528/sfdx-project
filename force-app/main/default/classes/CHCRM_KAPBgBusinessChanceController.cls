/***********************************************************************************************
* @author           WuTong
* @date             2020/08/10
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAPBgBusinessChance
* @test class       CHCRM_KAPBgBusinessChanceControllerTest
* history
* 2020/08/10  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAPBgBusinessChanceController {
    // Inner Class CaltrolTableData attribute name
    final static public string ATTR_NAME_LAST_YEAR_3 = 'lastYear3';
    final static public string ATTR_NAME_LAST_YEAR_2 = 'lastYear2';
    final static public string ATTR_NAME_LAST_YEAR = 'lastYear';
    final static public string ATTR_NAME_CURR_YEAR = 'curYear';
    final static public string ATTR_NAME_NEXT_YEAR = 'nextYear';
    final static public string ATTR_NAME_NEXT_YEAR_2 = 'nextYear2';
    // Inner Class CaltrolTableData attribute name Id
    final static public string ATTR_NAME_LAST_YEAR_3_ID = 'lastYear3Id';
    final static public string ATTR_NAME_LAST_YEAR_2_ID = 'lastYear2Id';
    final static public string ATTR_NAME_LAST_YEAR_ID = 'lastYearId';
    final static public string ATTR_NAME_CURR_YEAR_ID = 'curYearId';
    final static public string ATTR_NAME_NEXT_YEAR_ID = 'nextYearId';
    final static public string ATTR_NAME_NEXT_YEAR_2_ID = 'nextYear2Id';
	//table <column-Index, column-header-name>
    final static public Map<integer, string> tableColConfig = new Map<integer, string>{0=>'CHCRM_GP_RMB__c',
        																			1=>'CHCRM_GM_RMB__c',
        																			2=>'Turnover_RMB__c',
        																			3=>'CHCRM_Volume_L__c',
        																			4=>'CHCRM_In_Store_Share_Percent__c',
        																			5=>'CHCRM_Coverage_Percent__c'};
    //table <row-Index, row-value>                                                                                   
	final static public Map<integer, string> tableRowConfig = new Map<integer, string>{0=>ATTR_NAME_LAST_YEAR_3,
        																			1=>ATTR_NAME_LAST_YEAR_2,
        																			2=>ATTR_NAME_LAST_YEAR,
        																			3=>ATTR_NAME_CURR_YEAR,
        																			4=>ATTR_NAME_NEXT_YEAR,
        																			5=>ATTR_NAME_NEXT_YEAR_2};
    
    @AuraEnabled
    public static Wrapper getKAPInformationById(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id , CHCRM_Year__c , CHCRM_Sub_Channel_Account__c FROM  CHCRM_Key_Account_Plan__c WHERE Id =:recordId limit 1];
        String kapYear = kap.CHCRM_Year__c.trim();
        Integer intKapYear =  Integer.valueOf(kapYear);
        // table year header
        List<Integer> years = new List<Integer>{
            intKapYear - 3,
            intKapYear - 2,
            intKapYear - 1,
            intKapYear,
            intKapYear + 1,
            intKapYear + 2
        };         
        List<String> yearStrList = new List<String>();
        for(Integer year : years){
            yearStrList.add(String.valueOf(year));
        }
        wrapper.yearHeader = yearStrList; 
        List<CHCRM_KAP_Business_Volume__c> businessVolumeList = createKAPBusinessVolumes(yearStrList,kap);
        List<CaltrolTableData> dataList = new List<CaltrolTableData>();
        CaltrolTableData data1 = new CaltrolTableData();
        data1.index = 0;
        data1.opTarget = 'Gross Profit (元)';   
        CaltrolTableData data2 = new CaltrolTableData();
        data2.index = 1;
        data2.opTarget = 'Gross Margin (元)';        
        CaltrolTableData data3 = new CaltrolTableData();
        data3.index = 2;
        data3.opTarget = 'Turnover (元)';        
        CaltrolTableData data4 = new CaltrolTableData();
        data4.index = 3;
        data4.opTarget = 'Volume (L)';
        CaltrolTableData data5 = new CaltrolTableData();
        data5.index = 4;
        data5.opTarget = 'In Store Share (VOL/%)';        
        CaltrolTableData data6 = new CaltrolTableData();
        data6.index = 5;
        data6.opTarget = 'Coverage (%)';
		dataList.add(data1);
        dataList.add(data2);
        dataList.add(data3);
        dataList.add(data4);
        dataList.add(data5);
        dataList.add(data6);        
        if(!businessVolumeList.IsEmpty()){ 
            for(CHCRM_KAP_Business_Volume__c volume : businessVolumeList){
                Integer indexColumn = yearStrList.IndexOf(volume.CHCRM_Year__c);
                updateFiledForData(dataList, volume, indexColumn);
            }            
        }
        
        wrapper.dataList = dataList;
        return wrapper;
    }
    
    @AuraEnabled
    public static void save(CaltrolTableData editRow){
        CHCRM_KAP_Business_Volume__c data1 = new CHCRM_KAP_Business_Volume__c();
        CHCRM_KAP_Business_Volume__c data2 = new CHCRM_KAP_Business_Volume__c();
        CHCRM_KAP_Business_Volume__c data3 = new CHCRM_KAP_Business_Volume__c();
        CHCRM_KAP_Business_Volume__c data4 = new CHCRM_KAP_Business_Volume__c();
        CHCRM_KAP_Business_Volume__c data5 = new CHCRM_KAP_Business_Volume__c();
        CHCRM_KAP_Business_Volume__c data6 = new CHCRM_KAP_Business_Volume__c();
        List<CHCRM_KAP_Business_Volume__c> updateBV = new List<CHCRM_KAP_Business_Volume__c>{data1 , data2 , data3 , data4 , data5 , data6};        
        mappingDataToField(updateBV , editRow);
        if(!updateBv.isEmpty()){
            update updateBV;
        }
    }
    
    private static void mappingDataToField(List<CHCRM_KAP_Business_Volume__c> updateBVList , CaltrolTableData editRow){
        Integer rowIndex = editRow.index;
        String field = tableColConfig.get(rowIndex);
        for(Integer index = 0 ; index < updateBVList.size() ; index ++){
            CHCRM_KAP_Business_Volume__c bv = updateBVList[index];
            bv.put('Id' , editRow.getId(index));
            bv.put(field , stringToDecimal(editRow.getValue(index)));            
        }
        if(rowIndex == 1 || rowIndex == 2 || rowIndex == 3){
            CHCRM_KAP_Business_Volume__c data1 = updateBVList[0];
            CHCRM_KAP_Business_Volume__c data2 = updateBVList[1];
            CHCRM_KAP_Business_Volume__c data3 = updateBVList[2];
            CHCRM_KAP_Business_Volume__c data4 = updateBVList[3];
            CHCRM_KAP_Business_Volume__c data5 = updateBVList[4];
            CHCRM_KAP_Business_Volume__c data6 = updateBVList[5];
            String growthField = getGrowthRateField(rowIndex);
            data1.put(growthField , 0.00);
            data2.put(growthField , getGrowthRate((Decimal)data1.get(field) , (Decimal)data2.get(field)));
            data3.put(growthField , getGrowthRate((Decimal)data2.get(field) , (Decimal)data3.get(field)));
            data4.put(growthField , getGrowthRate((Decimal)data3.get(field) , (Decimal)data4.get(field)));
            data5.put(growthField , getGrowthRate((Decimal)data4.get(field) , (Decimal)data5.get(field)));
            data6.put(growthField , getGrowthRate((Decimal)data5.get(field) , (Decimal)data6.get(field)));
        }
    }
    
    private static String getGrowthRateField(Integer index){
        String field = '';
        if(index == 1){
           field = 'CHCRM_Growth_Rate_GM__c'; 
        }else if(index == 2){
           field = 'CHCRM_Growth_Rate_Turnover__c'; 
        }else if(index == 3){
           field = 'CHCRM_Growth_Rate_Volume__c';  
        }
        return field;
    }
    
    private static Decimal stringToDecimal(String str){
       return Decimal.valueOf(String.isEmpty(str) ? 0 + '': str.replace('%','') ); 
    }
    
    @AuraEnabled
    public static Wrapper initStatus(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id  , CHCRM_Status__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId];
        wrapper.isDraftFlag = kap.CHCRM_Status__c == 'Draft'? true:false;
        return wrapper;
    }
    
    private static Decimal getGrowthRate(Decimal minYear , Decimal maxYear){
        if(minYear == 0.00){
            return 0.00;
        }
        return Double.valueOf(((maxYear - minYear)/minYear).setscale(3,System.RoundingMode.DOWN)*100);
    }
    
   private static List<CHCRM_KAP_Business_Volume__c> createKAPBusinessVolumes(List<String> yearStrList ,CHCRM_Key_Account_Plan__c kap){
        List<CHCRM_KAP_Business_Volume__c> businessVolumeList = [SELECT Id , CHCRM_GM_RMB__c , Turnover_RMB__c , CHCRM_Coverage_Percent__c , CHCRM_In_Store_Share_Percent__c , 
                                                                 CHCRM_GP_RMB__c,CHCRM_Volume_L__c,
                                                                 CHCRM_Year__c , Key_Account_Plan__c
                                                                 FROM CHCRM_KAP_Business_Volume__c WHERE CHCRM_Year__c in:yearStrList and Key_Account_Plan__c =:kap.Id Order By CHCRM_Year__c DESC];
        
        Set<String> businessVolumeAcYearSet = new Set<String>();
        Map<String , CHCRM_KAP_Business_Volume_Actual__c> businessVolumeAcYearMap = new Map<String , CHCRM_KAP_Business_Volume_Actual__c>();
        for(CHCRM_KAP_Business_Volume_Actual__c ac : [SELECT Id , CHCRM_Coverage_Percent__c , CHCRM_GM_RMB__c , CHCRM_GP_RMB__c , CHCRM_In_Store_Share_Percent__c , 
                                                                         CHCRM_Sub_Channel_Account__c , CHCRM_Turnover_RMB__c , CHCRM_Volume_L__c , CHCRM_Year__c FROM CHCRM_KAP_Business_Volume_Actual__c
                                                                         WHERE CHCRM_Sub_Channel_Account__c =:kap.CHCRM_Sub_Channel_Account__c]){
            businessVolumeAcYearSet.add(ac.CHCRM_Year__c);
            businessVolumeAcYearMap.put(ac.CHCRM_Year__c , ac);
        }
        Set<String> yearSet = new Set<String>();
        Map<String , CHCRM_KAP_Business_Volume__c> businessVolumeMap = new Map<String , CHCRM_KAP_Business_Volume__c>();
        for(CHCRM_KAP_Business_Volume__c ckbv : businessVolumeList){
           yearSet.add(ckbv.CHCRM_Year__c.trim());
           businessVolumeMap.put(ckbv.CHCRM_Year__c , ckbv);
        }
        Set<String> createYearSet = new Set<String>();
        List<CHCRM_KAP_Business_Volume__c> businessList = new List<CHCRM_KAP_Business_Volume__c>();
        for(String year : yearStrList){
            if(!yearSet.contains(year) && !businessVolumeAcYearSet.contains(year)){
                createYearSet.add(year);
            }else{
                CHCRM_KAP_Business_Volume_Actual__c ac = businessVolumeAcYearMap.get(year);
                if(ac != null && !businessVolumeMap.containsKey(year)){
                    CHCRM_KAP_Business_Volume__c bv = new CHCRM_KAP_Business_Volume__c();
                    createKAPBusinessVolumeItemHasValue(businessList,kap,year,bv,ac);
                }else if(ac != null && businessVolumeMap.containsKey(year)){
                    CHCRM_KAP_Business_Volume__c bv = businessVolumeMap.get(year);
                    createKAPBusinessVolumeItemHasValue(businessList,kap,year,bv,ac);
                }
            }
        }                
        if(!createYearSet.isEmpty()){            
            for(String year : createYearSet){
                createKAPBusinessVolumeItemNoValue(businessList , kap , year);
            }            
        }
        if(!businessList.isEmpty()){
            upsert businessList;
        }
        businessVolumeList = [SELECT Id , CHCRM_GM_RMB__c , Turnover_RMB__c , CHCRM_Coverage_Percent__c , CHCRM_In_Store_Share_Percent__c , 
                                                                 CHCRM_GP_RMB__c,CHCRM_Volume_L__c,
                                                                 CHCRM_Year__c , LastModifiedDate
                                                                 FROM CHCRM_KAP_Business_Volume__c WHERE CHCRM_Year__c in:yearStrList and Key_Account_Plan__c =:kap.Id Order By CHCRM_Year__c DESC ];
        return businessVolumeList;
    }
    
    private static void createKAPBusinessVolumeItemHasValue(List<CHCRM_KAP_Business_Volume__c> businessList ,CHCRM_Key_Account_Plan__c kap , String year ,CHCRM_KAP_Business_Volume__c bv , CHCRM_KAP_Business_Volume_Actual__c ac){
        if(String.isBlank(bv.Id)){
            bv.Key_Account_Plan__c = kap.Id;
        }        
        bv.CHCRM_GM_RMB__c = ac.CHCRM_GM_RMB__c;
        bv.CHCRM_Year__c = year;
        bv.Turnover_RMB__c = ac.CHCRM_Turnover_RMB__c;
        bv.CHCRM_GP_RMB__c = ac.CHCRM_GP_RMB__c;
        bv.CHCRM_Volume_L__c = ac.CHCRM_Volume_L__c;
        bv.CHCRM_Coverage_Percent__c = ac.CHCRM_Coverage_Percent__c;
        bv.CHCRM_In_Store_Share_Percent__c = ac.CHCRM_In_Store_Share_Percent__c;
        businessList.add(bv);       
    }
    
    private static void createKAPBusinessVolumeItemNoValue(List<CHCRM_KAP_Business_Volume__c> businessList ,CHCRM_Key_Account_Plan__c kap , String year ){
        CHCRM_KAP_Business_Volume__c bv = new CHCRM_KAP_Business_Volume__c();
        bv.Key_Account_Plan__c = kap.Id;
        bv.CHCRM_GM_RMB__c = 0;
        bv.CHCRM_Year__c = year;
        bv.Turnover_RMB__c = 0;
        bv.CHCRM_GP_RMB__c = 0;
        bv.CHCRM_Volume_L__c = 0;
        bv.CHCRM_Coverage_Percent__c = 0;
        bv.CHCRM_In_Store_Share_Percent__c = 0;
        businessList.add(bv);        
    }
   /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/10
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPBgBusinessChance Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<String> yearHeader { get; set; }
        
        @AuraEnabled
        public List<CaltrolTableData> dataList { get; set; }
        
        @AuraEnabled
        public Boolean isDraftFlag{get;set;}
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/10
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPBgBusinessChance Reture
    ************************************************************************************************/
    public with sharing class CaltrolTableData{
        //next year2 value Id
        @AuraEnabled public String nextYear2Id {get; set;}
        //next year2 value
        @AuraEnabled public String nextYear2 {get; set;}
        //next year value Id
        @AuraEnabled public String nextYearId {get; set;}
        //next year value
        @AuraEnabled public String nextYear {get; set;}
        //current year value Id
        @AuraEnabled public String curYearId {get; set;}
        //current year value
        @AuraEnabled public String curYear {get; set;}
        
        //last Year value Id
        @AuraEnabled public String lastYearId {get; set;}
         //last Year value
        @AuraEnabled public String lastYear {get; set;}        
        //last Year2 value Id
        @AuraEnabled public String lastYear2Id {get; set;}
        //last Year2 value
        @AuraEnabled public String lastYear2 {get; set;}
        //last Year3 value Id
        @AuraEnabled public String lastYear3Id {get; set;}
        //last Year3 value
        @AuraEnabled public String lastYear3 {get; set;}
        
        //row label
        @AuraEnabled public String opTarget {get; set;}
        //row index
        @AuraEnabled public Integer index {get; set;}
        
        public void put(string attrName, string attrValue, string attrId) {
            if(attrName == ATTR_NAME_LAST_YEAR_3) {
                this.lastYear3 = attrValue;
                this.lastYear3Id = attrId;
            }else if(attrName == ATTR_NAME_LAST_YEAR_2) {
                this.lastYear2 = attrValue;
                this.lastYear2Id = attrId;
            }else if(attrName == ATTR_NAME_LAST_YEAR) {
                this.lastYear = attrValue;
                this.lastYearId = attrId;
            }else if(attrName == ATTR_NAME_CURR_YEAR) {
                this.curYear = attrValue;
                this.curYearId = attrId;
            }else if(attrName == ATTR_NAME_NEXT_YEAR) {
                this.nextYear = attrValue;
                this.nextYearId = attrId;
            }else if(attrName == ATTR_NAME_NEXT_YEAR_2) {
                this.nextYear2 = attrValue;
                this.nextYear2Id = attrId;
            } 
        }
        
        public String getId(Integer index){
            String yearId = '';
            if(index == 0){
                yearId = this.lastYear3Id;
            }else if(index == 1){
                yearId = this.lastYear2Id;
            }else if(index == 2){
                yearId = this.lastYearId;
            }else if(index == 3){
                yearId = this.curYearId;
            }else if(index == 4){
                yearId = this.nextYearId;
            }else if(index == 5){
                yearId = this.nextYear2Id;
            }             
            return yearId;
        }
        
        public String getValue(Integer index){
            String value = '';
            if(index == 0){
                value = this.lastYear3;
            }else if(index == 1){
                value = this.lastYear2;
            }else if(index == 2){
                value = this.lastYear;
            }else if(index == 3){
                value = this.curYear;
            }else if(index == 4){
                value = this.nextYear;
            }else if(index == 5){
                value = this.nextYear2;
            }             
            return value;
        }
    }
    
    static public void updateFiledForData(list<CaltrolTableData> dataList, CHCRM_KAP_Business_Volume__c volume, Integer dataRowIndex) {
        string attrName = tableRowConfig.get(dataRowIndex);         
		//system.debug('attrName: '+attrName);    
        for(integer i = 0; i < dataList.size(); i++) {
            CaltrolTableData data = dataList[i];
            string colHeader = tableColConfig.get(i);
            string volumnValue = String.valueOf(volume.get(colHeader));
            if(i==4 || i==5) {
                volumnValue = volumnValue +'%';
            } 
            data.put(attrName, volumnValue, volume.Id);
        }
    }    
}