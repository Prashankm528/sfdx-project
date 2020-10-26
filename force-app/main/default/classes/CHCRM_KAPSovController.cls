/***********************************************************************************************
* @author           WuTong
* @date             2020/08/12
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAPSov
* @test class       CHCRM_KAPSovControllerTest
* history
* 2020/08/12  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAPSovController {
    
    
    @AuraEnabled
    public static Wrapper initData(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id , CHCRM_Year__c , CHCRM_Sub_Channel_Account__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId limit 1];
        List<CHCRM_KAP_Sov_AUTO_Title__c> sovTitleList = findSovListByKapId(recordId);
        if(!sovTitleList.isEmpty()){
            String kapYear = kap.CHCRM_Year__c.trim();
            // table year header
            List<Integer> years = new List<Integer>();
            years.add(Integer.valueOf(kapYear) - 3);
            years.add(Integer.valueOf(kapYear) - 2);
            years.add(Integer.valueOf(kapYear) - 1);
            years.add(Integer.valueOf(kapYear));
            years.add(Integer.valueOf(kapYear) + 1);
            years.add(Integer.valueOf(kapYear) + 2);               
            List<String> yearStrList = new List<String>();
            for(Integer year : years){
                yearStrList.add(String.valueOf(year));
            }
            List<WrapperItem> itemList = new List<WrapperItem>();
            List<CHCRM_KAP_Business_Volume_Actual__c> bvAcList = getKAPBusinessVolumeActualList(kap);
            List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessList = new List<CHCRM_KAP_Sov_AUTO_Business_Volume__c>();
            Map<Id , WrapperItem> sovTitleMap = new Map<Id , WrapperItem>();
            for(CHCRM_KAP_Sov_AUTO_Title__c sovTitle : sovTitleList){
                WrapperItem item = new WrapperItem();
                item.sovTitleId = sovTitle.Id;
                item.yearHeader = yearStrList;
                List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> sovBVList = sovTitle.CHCRM_KAP_Sov_AUTO_Business_Volumes__r;
                List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessItemList = createKAPSovAutoBVObject(yearStrList , sovTitle ,sovBVList ,bvAcList);
                if(!businessItemList.isEmpty()){
                    businessList.addAll(businessItemList);
                }
                sovTitleMap.put(sovTitle.Id , item);          
                if(!sovTitle.CHCRM_KAP_Sov_AUTO_Project_Informations__r.isEmpty()){
                    List<AssignedProject> assignedProjectTableData = new List<AssignedProject>();
                    for(CHCRM_KAP_Sov_AUTO_Project_Information__c project : sovTitle.CHCRM_KAP_Sov_AUTO_Project_Informations__r){
                        AssignedProject assProject = new AssignedProject();
                        assProject.id = project.Id;
                        assProject.projectName = project.CHCRM_Sov_Assigned_Project__c;
                        assProject.projectTarget = project.CHCRM_Assigned_Target__c;
                        assProject.projectCompleteDate = project.CHCRM_Complete_Date__c;
                        assProject.projectEndDate = project.CHCRM_End_Date__c;
                        assProject.projectOwner = project.CHCRM_Sales_Principal__c != null?project.CHCRM_Sales_Principal__r.Name:'';
                        assProject.projectOwnerId = project.CHCRM_Sales_Principal__c;
                        //assProject.status = project.CHCRM_Status_Light__c;
                        assProject.status = getColorStatus(project.CHCRM_Complete_Date__c , project.CHCRM_End_Date__c);
                        assignedProjectTableData.add(assProject);
                    }
                    item.projectList = assignedProjectTableData;
                }
                itemList.add(item);                
            }
            if(!businessList.isEmpty()){
                upsert businessList;
            }
            //refresh sovList
            sovTitleList = findSovListByKapId(recordId);
            for(CHCRM_KAP_Sov_AUTO_Title__c sovTitle : sovTitleList){
                WrapperItem item = sovTitleMap.get(sovTitle.Id);
                List<Finance> financeDatatable = createFinanceList(yearStrList , sovTitle.CHCRM_KAP_Sov_AUTO_Business_Volumes__r);
                item.financeList = financeDatatable;
            }
            wrapper.wrapperItemList = itemList;
        }
        return wrapper;
    }
    
    @AuraEnabled
    public static void createSOV(String recordId){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id , CHCRM_Year__c , CHCRM_Sub_Channel_Account__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId limit 1];
        String kapYear = kap.CHCRM_Year__c;
        // table year header
        List<Integer> yearList = new List<Integer>();
        yearList.add(Integer.valueOf(kapYear.trim()) - 3);
        yearList.add(Integer.valueOf(kapYear.trim()) - 2);
        yearList.add(Integer.valueOf(kapYear.trim()) - 1);
        yearList.add(Integer.valueOf(kapYear.trim()));
        yearList.add(Integer.valueOf(kapYear.trim()) + 1);
        yearList.add(Integer.valueOf(kapYear.trim()) + 2);               
        List<String> yearStrList = new List<String>();
        for(Integer year : yearList){
            yearStrList.add(String.valueOf(year));
        }
        CHCRM_KAP_Sov_AUTO_Title__c title = new CHCRM_KAP_Sov_AUTO_Title__c(CHCRM_Key_Account_Plan__c = recordId);
        insert title;
        List<CHCRM_KAP_Business_Volume_Actual__c> bvAcList = getKAPBusinessVolumeActualList(kap);
        List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessItemList = createKAPSovAutoBVObject(yearStrList , title ,null ,bvAcList);
        if(!businessItemList.isEmpty()){
            upsert businessItemList;
        }
    }
    
    private static List<CHCRM_KAP_Sov_AUTO_Title__c> findSovListByKapId(String recordId){
        return [SELECT Id,CHCRM_SOV_Name__c,CHCRM_Join_Mode__c,CHCRM_SOV_Principal__c,CHCRM_SOV_Principal__r.Name,CHCRM_SOV_Title__c ,CHCRM_Product_Type__c,CHCRM_Priority__c,
                                                          (SELECT Id,CHCRM_KAP_Sov_AUTO_Title__c,CHCRM_GM_RMB__c,CHCRM_GP_RMB__c,CHCRM_Return_On_Investment__c,
                                                           CHCRM_Turnover_RMB__c,CHCRM_Volume_L__c,CHCRM_Year__c FROM CHCRM_KAP_Sov_AUTO_Business_Volumes__r Order by CHCRM_Year__c DESC),
                                                          (SELECT Id,CHCRM_Assigned_Target__c,CHCRM_End_Date__c,CHCRM_KAP_Sov_AUTO_Title__c,CHCRM_Sales_Principal__c,
                                                           CHCRM_Sales_Principal__r.Name , CHCRM_Sov_Assigned_Project__c , CHCRM_Status__c ,CHCRM_Status_Light__c , CHCRM_Complete_Date__c FROM CHCRM_KAP_Sov_AUTO_Project_Informations__r)
                                                          FROM  CHCRM_KAP_Sov_AUTO_Title__c WHERE CHCRM_Key_Account_Plan__c =:recordId Order by CHCRM_Priority__c ,CreatedDate ASC];
    }
    
    private static List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> createKAPSovAutoBVObject(List<String> yearStrList ,CHCRM_KAP_Sov_AUTO_Title__c title , List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> sovBVList , List<CHCRM_KAP_Business_Volume_Actual__c> bvAcList){
        Set<String> businessVolumeAcYearSet = new Set<String>();
        Map<String , CHCRM_KAP_Business_Volume_Actual__c> businessVolumeAcYearMap = new Map<String , CHCRM_KAP_Business_Volume_Actual__c>();
        if(!bvAcList.isEmpty()){
            for(CHCRM_KAP_Business_Volume_Actual__c ac : bvAcList){
                businessVolumeAcYearSet.add(ac.CHCRM_Year__c);
                businessVolumeAcYearMap.put(ac.CHCRM_Year__c , ac);
            }
        }        
        Set<String> yearSet = new Set<String>();
        Map<String , CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessVolumeMap = new Map<String , CHCRM_KAP_Sov_AUTO_Business_Volume__c>();
        if(sovBVList!= null && !sovBVList.isEmpty()){
            for(CHCRM_KAP_Sov_AUTO_Business_Volume__c ckbv : sovBVList){
                yearSet.add(ckbv.CHCRM_Year__c.trim());
                businessVolumeMap.put(ckbv.CHCRM_Year__c , ckbv);
            }
        }
        Set<String> createYearSet = new Set<String>();
        List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessList = new List<CHCRM_KAP_Sov_AUTO_Business_Volume__c>();
        for(String year : yearStrList){
            if(!yearSet.contains(year) && !businessVolumeAcYearSet.contains(year)){
                createYearSet.add(year);
            }else{
                CHCRM_KAP_Business_Volume_Actual__c ac = businessVolumeAcYearMap.get(year);
                if(ac != null && !businessVolumeMap.containsKey(year)){
                    CHCRM_KAP_Sov_AUTO_Business_Volume__c bv = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
                    createKAPBusinessVolumeItemHasValue(businessList , title.Id , year , bv , ac);
                }else if(ac != null && businessVolumeMap.containsKey(year)){
                    CHCRM_KAP_Sov_AUTO_Business_Volume__c bv = businessVolumeMap.get(year);
                    createKAPBusinessVolumeItemHasValue(businessList , title.Id , year , bv , ac);
                }
            }
        }
        if(!createYearSet.isEmpty()){            
            for(String year : createYearSet){
                createKAPBusinessVolumeItemNoValue(businessList , title.Id , year);
            }            
        }
        return businessList;
    }
    
    private static void createKAPBusinessVolumeItemHasValue(List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessList ,String titleId , String year ,CHCRM_KAP_Sov_AUTO_Business_Volume__c bv , CHCRM_KAP_Business_Volume_Actual__c ac){        
        if(String.isBlank(bv.Id)){
            bv.CHCRM_KAP_Sov_AUTO_Title__c = titleId; 
        }                     
        bv.CHCRM_GM_RMB__c = ac.CHCRM_GM_RMB__c;
        bv.CHCRM_Year__c = year;
        bv.CHCRM_Turnover_RMB__c = ac.CHCRM_Turnover_RMB__c;
        bv.CHCRM_GP_RMB__c = ac.CHCRM_GP_RMB__c;
        bv.CHCRM_Volume_L__c = ac.CHCRM_Volume_L__c;
        bv.CHCRM_Return_On_Investment__c = ac.CHCRM_Return_On_Investment__c;
        businessList.add(bv);       
    }
    
    private static void createKAPBusinessVolumeItemNoValue(List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> businessList ,String titleId , String year ){
        CHCRM_KAP_Sov_AUTO_Business_Volume__c bv = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        bv.CHCRM_KAP_Sov_AUTO_Title__c = titleId;      
        bv.CHCRM_GM_RMB__c = 0;
        bv.CHCRM_Year__c = year;
        bv.CHCRM_Turnover_RMB__c = 0;
        bv.CHCRM_GP_RMB__c = 0;
        bv.CHCRM_Volume_L__c = 0;
        bv.CHCRM_Return_On_Investment__c = 0;
        businessList.add(bv);       
    }
    
    private static List<CHCRM_KAP_Business_Volume_Actual__c> getKAPBusinessVolumeActualList(CHCRM_Key_Account_Plan__c kap){
        return [SELECT Id , CHCRM_Coverage_Percent__c , CHCRM_GM_RMB__c , CHCRM_GP_RMB__c , CHCRM_In_Store_Share_Percent__c , 
                                                                         CHCRM_Sub_Channel_Account__c , CHCRM_Turnover_RMB__c , CHCRM_Volume_L__c , CHCRM_Year__c , CHCRM_Return_On_Investment__c FROM CHCRM_KAP_Business_Volume_Actual__c
                                                                         WHERE CHCRM_Sub_Channel_Account__c =:kap.CHCRM_Sub_Channel_Account__c];
    }
    
    @AuraEnabled
    public static void deleteSOV(String titleId){
        CHCRM_KAP_Sov_AUTO_Title__c title = new CHCRM_KAP_Sov_AUTO_Title__c(Id = titleId);
        delete title;
    }
    
    @AuraEnabled
    public static WrapperItem saveSOVFinance(Finance editRow , String titleId , List<String> yearStrList){
        WrapperItem result = new WrapperItem();
        List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> updateBV = new List<CHCRM_KAP_Sov_AUTO_Business_Volume__c>();
        CHCRM_KAP_Sov_AUTO_Business_Volume__c data1 = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        CHCRM_KAP_Sov_AUTO_Business_Volume__c data2 = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        CHCRM_KAP_Sov_AUTO_Business_Volume__c data3 = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        CHCRM_KAP_Sov_AUTO_Business_Volume__c data4 = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        CHCRM_KAP_Sov_AUTO_Business_Volume__c data5 = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        CHCRM_KAP_Sov_AUTO_Business_Volume__c data6 = new CHCRM_KAP_Sov_AUTO_Business_Volume__c();
        if(editRow.index == 0){
            data1.Id = editRow.lastYear3Id;
            data1.CHCRM_Volume_L__c = Decimal.valueOf(String.isEmpty(editRow.lastYear3) ? 0 + '': editRow.lastYear3 );
            data2.Id = editRow.lastYear2Id;
            data2.CHCRM_Volume_L__c = Decimal.valueOf(String.isEmpty(editRow.lastYear2) ? 0 + '': editRow.lastYear2 );
            data3.Id = editRow.lastYearId;
            data3.CHCRM_Volume_L__c = Decimal.valueOf(String.isEmpty(editRow.lastYear) ? 0 + '': editRow.lastYear );
            data4.Id = editRow.curYearId;
            data4.CHCRM_Volume_L__c = Decimal.valueOf(String.isEmpty(editRow.curYear) ? 0 + '': editRow.curYear );
            data5.Id = editRow.nextYearId;
            data5.CHCRM_Volume_L__c = Decimal.valueOf(String.isEmpty(editRow.nextYear) ? 0 + '': editRow.nextYear );
            data6.Id = editRow.nextYear2Id;
            data6.CHCRM_Volume_L__c = Decimal.valueOf(String.isEmpty(editRow.nextYear2) ? 0 + '': editRow.nextYear2 );            
        }else if(editRow.index == 1){                
            data1.Id = editRow.lastYear3Id;
            data1.CHCRM_GM_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear3) ? 0 + '': editRow.lastYear3 );
            data2.Id = editRow.lastYear2Id;
            data2.CHCRM_GM_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear2) ? 0 + '': editRow.lastYear2 );
            data3.Id = editRow.lastYearId;
            data3.CHCRM_GM_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear) ? 0 + '': editRow.lastYear );
            data4.Id = editRow.curYearId;
            data4.CHCRM_GM_RMB__c = Decimal.valueOf(String.isEmpty(editRow.curYear) ? 0 + '': editRow.curYear );
            data5.Id = editRow.nextYearId;
            data5.CHCRM_GM_RMB__c = Decimal.valueOf(String.isEmpty(editRow.nextYear) ? 0 + '': editRow.nextYear );
            data6.Id = editRow.nextYear2Id;
            data6.CHCRM_GM_RMB__c = Decimal.valueOf(String.isEmpty(editRow.nextYear2) ? 0 + '': editRow.nextYear2 );            
        }else if(editRow.index == 2){
            data1.Id = editRow.lastYear3Id;
            data1.CHCRM_GP_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear3) ? 0 + '': editRow.lastYear3 );
            data2.Id = editRow.lastYear2Id;
            data2.CHCRM_GP_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear2) ? 0 + '': editRow.lastYear2 );
            data3.Id = editRow.lastYearId;
            data3.CHCRM_GP_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear) ? 0 + '': editRow.lastYear );
            data4.Id = editRow.curYearId;
            data4.CHCRM_GP_RMB__c = Decimal.valueOf(String.isEmpty(editRow.curYear) ? 0 + '': editRow.curYear );
            data5.Id = editRow.nextYearId;
            data5.CHCRM_GP_RMB__c = Decimal.valueOf(String.isEmpty(editRow.nextYear) ? 0 + '': editRow.nextYear );
            data6.Id = editRow.nextYear2Id;
            data6.CHCRM_GP_RMB__c = Decimal.valueOf(String.isEmpty(editRow.nextYear2) ? 0 + '': editRow.nextYear2 );              
        }else if(editRow.index == 3){
            data1.Id = editRow.lastYear3Id;
            data1.CHCRM_Turnover_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear3) ? 0 + '': editRow.lastYear3 );
            data2.Id = editRow.lastYear2Id;
            data2.CHCRM_Turnover_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear2) ? 0 + '': editRow.lastYear2 );
            data3.Id = editRow.lastYearId;
            data3.CHCRM_Turnover_RMB__c = Decimal.valueOf(String.isEmpty(editRow.lastYear) ? 0 + '': editRow.lastYear );
            data4.Id = editRow.curYearId;
            data4.CHCRM_Turnover_RMB__c = Decimal.valueOf(String.isEmpty(editRow.curYear) ? 0 + '': editRow.curYear );
            data5.Id = editRow.nextYearId;
            data5.CHCRM_Turnover_RMB__c = Decimal.valueOf(String.isEmpty(editRow.nextYear) ? 0 + '': editRow.nextYear );
            data6.Id = editRow.nextYear2Id;
            data6.CHCRM_Turnover_RMB__c = Decimal.valueOf(String.isEmpty(editRow.nextYear2) ? 0 + '': editRow.nextYear2 ); 
        }else if(editRow.index == 4){
            data1.Id = editRow.lastYear3Id;
            data1.CHCRM_Return_On_Investment__c = Decimal.valueOf(String.isEmpty(editRow.lastYear3) ? 0 + '': editRow.lastYear3.replace('%','') );
            data2.Id = editRow.lastYear2Id;
            data2.CHCRM_Return_On_Investment__c = Decimal.valueOf(String.isEmpty(editRow.lastYear2) ? 0 + '': editRow.lastYear2.replace('%','') );
            data3.Id = editRow.lastYearId;
            data3.CHCRM_Return_On_Investment__c = Decimal.valueOf(String.isEmpty(editRow.lastYear) ? 0 + '': editRow.lastYear.replace('%','') );
            data4.Id = editRow.curYearId;
            data4.CHCRM_Return_On_Investment__c = Decimal.valueOf(String.isEmpty(editRow.curYear) ? 0 + '': editRow.curYear.replace('%','') );
            data5.Id = editRow.nextYearId;
            data5.CHCRM_Return_On_Investment__c = Decimal.valueOf(String.isEmpty(editRow.nextYear) ? 0 + '': editRow.nextYear.replace('%','') );
            data6.Id = editRow.nextYear2Id;
            data6.CHCRM_Return_On_Investment__c = Decimal.valueOf(String.isEmpty(editRow.nextYear2) ? 0 + '': editRow.nextYear2.replace('%','') );
        }
        updateBV.add(data1);
        updateBV.add(data2);
        updateBV.add(data3);
        updateBV.add(data4);
        updateBV.add(data5);
        updateBV.add(data6);   
        if(!updateBv.isEmpty()){
            update updateBV;
        }
        return refreshFinance(titleId,yearStrList);
    }
    
    @AuraEnabled  
    public static WrapperItem refreshFinance(String titleId , List<String> yearStrList){
        WrapperItem result = new WrapperItem();
        List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> sovBuVoList = [SELECT Id,CHCRM_KAP_Sov_AUTO_Title__c,CHCRM_GM_RMB__c,CHCRM_GP_RMB__c,CHCRM_Return_On_Investment__c,
                                                                   CHCRM_Turnover_RMB__c,CHCRM_Volume_L__c,CHCRM_Year__c FROM CHCRM_KAP_Sov_AUTO_Business_Volume__c 
                                                                   WHERE CHCRM_KAP_Sov_AUTO_Title__c =:titleId  Order by CHCRM_Year__c DESC];
        result.financeList = createFinanceList(yearStrList , sovBuVoList);
        return result;
    }
    
    @AuraEnabled  
    public static WrapperItem refreshProject(String titleId){
        WrapperItem result = new WrapperItem();
        List<AssignedProject> assignedProjectTableData = new List<AssignedProject>();
        for(CHCRM_KAP_Sov_AUTO_Project_Information__c project : [SELECT Id,CHCRM_Assigned_Target__c,CHCRM_End_Date__c,CHCRM_KAP_Sov_AUTO_Title__c,CHCRM_Sales_Principal__c,
                                                           CHCRM_Sales_Principal__r.Name , CHCRM_Sov_Assigned_Project__c , CHCRM_Status__c , CHCRM_Status_Light__c , CHCRM_Complete_Date__c  FROM CHCRM_KAP_Sov_AUTO_Project_Information__c WHERE CHCRM_KAP_Sov_AUTO_Title__c =:titleId]){
            AssignedProject assProject = new AssignedProject();
            assProject.id = project.Id;
            assProject.projectName = project.CHCRM_Sov_Assigned_Project__c;
            assProject.projectTarget = project.CHCRM_Assigned_Target__c;
            assProject.projectCompleteDate = project.CHCRM_Complete_Date__c;                                                   
            assProject.projectEndDate = project.CHCRM_End_Date__c;
            assProject.projectOwner = project.CHCRM_Sales_Principal__c != null?project.CHCRM_Sales_Principal__r.Name:'';
            assProject.projectOwnerId = project.CHCRM_Sales_Principal__c;
            //assProject.status = project.CHCRM_Status_Light__c;
            assProject.status = getColorStatus(project.CHCRM_Complete_Date__c , project.CHCRM_End_Date__c);
            assignedProjectTableData.add(assProject);
        }
        result.projectList = assignedProjectTableData;
        return result;
    }
    
    @AuraEnabled  
    public static void delereProject(String recordId){
        CHCRM_KAP_Sov_AUTO_Project_Information__c project = new CHCRM_KAP_Sov_AUTO_Project_Information__c(Id = recordId);
        delete project;
    }
    
    @AuraEnabled
    public static Wrapper initStatus(String recordId){
        Wrapper wrapper = new Wrapper();
        CHCRM_Key_Account_Plan__c kap = [SELECT Id  , CHCRM_Status__c FROM CHCRM_Key_Account_Plan__c WHERE Id =:recordId];
        wrapper.isDraftFlag = kap.CHCRM_Status__c == 'Draft'? true:false;
        return wrapper;
    }
    
    private static List<Finance> createFinanceList(List<String> yearStrList , List<CHCRM_KAP_Sov_AUTO_Business_Volume__c> sovBuVoList){
        List<Finance> financeDatatable = new List<Finance>();
        Finance data1 = new Finance();
        data1.index = 0;
        data1.financeTarget = 'Vol (L)';
        Finance data2 = new Finance();
        data2.index = 1;
        data2.financeTarget = 'Gross Margin (元)';
        Finance data3 = new Finance();
        data3.index = 2;
        data3.financeTarget = 'Gross Profit (元)';
        Finance data4 = new Finance();
        data4.index = 3;
        data4.financeTarget = 'Turnover（元）';
        Finance data5 = new Finance();
        data5.index = 4;
        data5.financeTarget = 'Return On Investment (%)';
        if(!sovBuVoList.isEmpty()){
            for(CHCRM_KAP_Sov_AUTO_Business_Volume__c sovBuVo :  sovBuVoList){
                Integer indexColumn = yearStrList.IndexOf(sovBuVo.CHCRM_Year__c);
                if(indexColumn == 0){
                    data1.lastYear3 = String.valueOf(sovBuVo.CHCRM_Volume_L__c == null ? 0 : sovBuVo.CHCRM_Volume_L__c);
                    data1.lastYear3Id = sovBuVo.Id;
                    data2.lastYear3 = String.valueOf(sovBuVo.CHCRM_GM_RMB__c == null ? 0 : sovBuVo.CHCRM_GM_RMB__c);
                    data2.lastYear3Id = sovBuVo.Id;
                    data3.lastYear3 = String.valueOf(sovBuVo.CHCRM_GP_RMB__c == null ? 0 : sovBuVo.CHCRM_GP_RMB__c);
                    data3.lastYear3Id = sovBuVo.Id;
                    data4.lastYear3 = String.valueOf(sovBuVo.CHCRM_Turnover_RMB__c == null ? 0 : sovBuVo.CHCRM_Turnover_RMB__c);
                    data4.lastYear3Id = sovBuVo.Id;
                    data5.lastYear3 = String.valueOf(sovBuVo.CHCRM_Return_On_Investment__c == null ? 0 : sovBuVo.CHCRM_Return_On_Investment__c)+'%';
                    data5.lastYear3Id = sovBuVo.Id;
                }else if(indexColumn == 1){
                    data1.lastYear2 = String.valueOf(sovBuVo.CHCRM_Volume_L__c == null ? 0 : sovBuVo.CHCRM_Volume_L__c);
                    data1.lastYear2Id = sovBuVo.Id;
                    data2.lastYear2 = String.valueOf(sovBuVo.CHCRM_GM_RMB__c == null ? 0 : sovBuVo.CHCRM_GM_RMB__c);
                    data2.lastYear2Id = sovBuVo.Id;
                    data3.lastYear2 = String.valueOf(sovBuVo.CHCRM_GP_RMB__c == null ? 0 : sovBuVo.CHCRM_GP_RMB__c);
                    data3.lastYear2Id = sovBuVo.Id;
                    data4.lastYear2 = String.valueOf(sovBuVo.CHCRM_Turnover_RMB__c == null ? 0 : sovBuVo.CHCRM_Turnover_RMB__c);
                    data4.lastYear2Id = sovBuVo.Id;
                    data5.lastYear2 = String.valueOf(sovBuVo.CHCRM_Return_On_Investment__c == null ? 0 : sovBuVo.CHCRM_Return_On_Investment__c)+'%';
                    data5.lastYear2Id = sovBuVo.Id;
                }else if(indexColumn == 2){
                    data1.lastYear = String.valueOf(sovBuVo.CHCRM_Volume_L__c == null ? 0 : sovBuVo.CHCRM_Volume_L__c);
                    data1.lastYearId = sovBuVo.Id;
                    data2.lastYear = String.valueOf(sovBuVo.CHCRM_GM_RMB__c == null ? 0 : sovBuVo.CHCRM_GM_RMB__c);
                    data2.lastYearId = sovBuVo.Id;
                    data3.lastYear = String.valueOf(sovBuVo.CHCRM_GP_RMB__c == null ? 0 : sovBuVo.CHCRM_GP_RMB__c);
                    data3.lastYearId = sovBuVo.Id;
                    data4.lastYear = String.valueOf(sovBuVo.CHCRM_Turnover_RMB__c == null ? 0 : sovBuVo.CHCRM_Turnover_RMB__c);
                    data4.lastYearId = sovBuVo.Id;
                    data5.lastYear = String.valueOf(sovBuVo.CHCRM_Return_On_Investment__c == null ? 0 : sovBuVo.CHCRM_Return_On_Investment__c)+'%';
                    data5.lastYearId = sovBuVo.Id;
                }else if(indexColumn == 3){
                    data1.curYear = String.valueOf(sovBuVo.CHCRM_Volume_L__c == null ? 0 : sovBuVo.CHCRM_Volume_L__c);
                    data1.curYearId = sovBuVo.Id;
                    data2.curYear = String.valueOf(sovBuVo.CHCRM_GM_RMB__c == null ? 0 : sovBuVo.CHCRM_GM_RMB__c);
                    data2.curYearId = sovBuVo.Id;
                    data3.curYear = String.valueOf(sovBuVo.CHCRM_GP_RMB__c == null ? 0 : sovBuVo.CHCRM_GP_RMB__c);
                    data3.curYearId = sovBuVo.Id;
                    data4.curYear = String.valueOf(sovBuVo.CHCRM_Turnover_RMB__c == null ? 0 : sovBuVo.CHCRM_Turnover_RMB__c);
                    data4.curYearId = sovBuVo.Id;
                    data5.curYear = String.valueOf(sovBuVo.CHCRM_Return_On_Investment__c == null ? 0 : sovBuVo.CHCRM_Return_On_Investment__c)+'%';
                    data5.curYearId = sovBuVo.Id;
                }else if(indexColumn == 4){
                    data1.nextYear = String.valueOf(sovBuVo.CHCRM_Volume_L__c == null ? 0 : sovBuVo.CHCRM_Volume_L__c);
                    data1.nextYearId = sovBuVo.Id;
                    data2.nextYear = String.valueOf(sovBuVo.CHCRM_GM_RMB__c == null ? 0 : sovBuVo.CHCRM_GM_RMB__c);
                    data2.nextYearId = sovBuVo.Id;
                    data3.nextYear = String.valueOf(sovBuVo.CHCRM_GP_RMB__c == null ? 0 : sovBuVo.CHCRM_GP_RMB__c);
                    data3.nextYearId = sovBuVo.Id;
                    data4.nextYear = String.valueOf(sovBuVo.CHCRM_Turnover_RMB__c == null ? 0 : sovBuVo.CHCRM_Turnover_RMB__c);
                    data4.nextYearId = sovBuVo.Id;
                    data5.nextYear = String.valueOf(sovBuVo.CHCRM_Return_On_Investment__c == null ? 0 : sovBuVo.CHCRM_Return_On_Investment__c)+'%';
                    data5.nextYearId = sovBuVo.Id;
                }else if(indexColumn == 5){
                    data1.nextYear2 = String.valueOf(sovBuVo.CHCRM_Volume_L__c == null ? 0 : sovBuVo.CHCRM_Volume_L__c);
                    data1.nextYear2Id = sovBuVo.Id;
                    data2.nextYear2 = String.valueOf(sovBuVo.CHCRM_GM_RMB__c == null ? 0 : sovBuVo.CHCRM_GM_RMB__c);
                    data2.nextYear2Id = sovBuVo.Id;
                    data3.nextYear2 = String.valueOf(sovBuVo.CHCRM_GP_RMB__c == null ? 0 : sovBuVo.CHCRM_GP_RMB__c);
                    data3.nextYear2Id = sovBuVo.Id;
                    data4.nextYear2 = String.valueOf(sovBuVo.CHCRM_Turnover_RMB__c == null ? 0 : sovBuVo.CHCRM_Turnover_RMB__c);
                    data4.nextYear2Id = sovBuVo.Id;
                    data5.nextYear2 = String.valueOf(sovBuVo.CHCRM_Return_On_Investment__c == null ? 0 : sovBuVo.CHCRM_Return_On_Investment__c)+'%';
                    data5.nextYear2Id = sovBuVo.Id;
                }
            }
        }
        financeDatatable.add(data1);
        financeDatatable.add(data2);
        financeDatatable.add(data3);
        financeDatatable.add(data4);
        financeDatatable.add(data5);
        return getCAGRByFinance(financeDatatable);
    }
    
    private static String getColorStatus(Date completeDate , Date endDate){
        String color = '' ;
        if(completeDate == null){
            color = 'my-red';
        }else if(completeDate <= endDate){
            color = 'my-green';
        }else{
            color = 'my-yellow';
        }
        return color;
    }
    
    private static List<Finance> getCAGRByFinance(List<Finance> financeDatatable){
        Double count = 0.167;
        for(Finance finance : financeDatatable){
            Decimal nowValue = Decimal.valueOf(finance.lastYear3.replace('%',''));
            if(nowValue == 0){
                finance.CAGR = '0.00%';
                continue;
            }
           Decimal maxValue = Decimal.valueOf(finance.nextYear2.replace('%',''));
           Decimal resultValue =  Math.pow(Double.valueOf((maxValue/nowValue).setscale(3,System.RoundingMode.UP)), count)-1;
           finance.CAGR = Double.valueOf(resultValue.setscale(3,System.RoundingMode.DOWN)*100) + '%';
        }
        return financeDatatable;
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/12
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSov Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<WrapperItem> wrapperItemList { get; set; }
        @AuraEnabled
        public Boolean isDraftFlag{get;set;}
    }    
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/12
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSov Reture
    ************************************************************************************************/
    public with sharing class WrapperItem{
        @AuraEnabled
        public List<String> yearHeader { get; set; }
        
        @AuraEnabled
        public String sovTitleId { get; set; }
        
        @AuraEnabled
        public List<Finance> financeList { get; set; }
        
        @AuraEnabled
        public List<AssignedProject> projectList { get; set; }
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/12
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSov Reture
    ************************************************************************************************/
    public with sharing class Finance{
        // NEXT Related
        @AuraEnabled
        public String nextYear { get; 
                                 set; }
        @AuraEnabled
        public String nextYearId { get; 
                                   set; }
        @AuraEnabled
        public String nextYear2 { get; 
                                  set; }
        @AuraEnabled
        public String nextYear2Id { get; 
                                    set; }
		// LAST Related        
        @AuraEnabled
        public String lastYear3 { get; 
                                  set; }
        @AuraEnabled
        public String lastYear3Id { get; 
                                    set; }
        @AuraEnabled
        public String lastYear2 { get; 
                                  set; }
        @AuraEnabled
        public String lastYear2Id { get; 
                                    set; }
        @AuraEnabled
        public String lastYear { get; 
                                 set; }
        @AuraEnabled
        public String lastYearId { get; 
                                   set; }
        
        // OTHER
        @AuraEnabled
        public Integer index { get; 
                               set; }
        @AuraEnabled
        public String CAGR { get; 
                             set; }  
        @AuraEnabled
        public String financeTarget { get; 
                                      set; }
        // CURRENT Related
        @AuraEnabled
        public String curYear { get; 
                                set; }
        @AuraEnabled
        public String curYearId { get; 
                                  set; }                
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/12
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAPSov Reture
    ************************************************************************************************/
    public with sharing class AssignedProject{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String projectName { get; set; }
        @AuraEnabled
        public String projectTarget { get; set; }
        @AuraEnabled
        public Date projectCompleteDate { get; set; }
        @AuraEnabled
        public Date projectEndDate { get; set; }
        @AuraEnabled
        public String projectOwner { get; set; }
        @AuraEnabled
        public String projectOwnerId { get; set; }
        @AuraEnabled
        public String status { get; set; }
    }    
    
}