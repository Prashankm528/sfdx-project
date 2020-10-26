/*****************************************************************************************
*	Date:		    29-Jul-2020
*   Author:         SFO Team
*   Description:    OpportunityRevenueService
****************************************************************************************/
public  with sharing class SFO_OpportunityRevenueService 
{
    private static List<String> salesOrgs;
    private static Map<Id, String> recordTypesMap = getOpportunityRecordTypes();
    
    /*
    * Creates demand planning records based on supply date for opportunity
    * and impact date for vulnerability
    */
    public void createDemandPlaningRecords(List<Revenue__c> revenueList)
    {
        List<Opportunity_Demand_Planning__c> newOppDPList = new List<Opportunity_Demand_Planning__c>();
        Set<Id> oppIdSet = New Set<Id>();
        DateTime monthDate;
        if(isValidSalesOrgnisation())
        {
            Integer demandPlanningMonths = getNumberOfDemandPlnningMonths();
            
            for(Revenue__c rev : revenueList)
            {
                oppIdSet.add(rev.Opportunity__c);
            }
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, RecordTypeId, Supply_Start_Date__c, CASFO_Impact_Date__c  From Opportunity Where Id IN : oppIdSet]);
            
            if(demandPlanningMonths > 0)
            {                
                for(Revenue__c oppRevenue : revenueList) 
                {              
                    newOppDPList.addAll(createDemandPlaning(oppRevenue,
                                                            getDemandPlanninngDate(oppMap.get(oppRevenue.Opportunity__c), recordTypesMap),
                                                            demandPlanningMonths));
                }
                if(newOppDPList != null && !newOppDPList.isEmpty()) 
                {
                    insert newOppDPList; 
                }  
            }
        }
    }
    
    /*
    * Updates demand planning records when the volume is changed based on supply date for opportunity
    * and impact date for vulnerability
    */
    public void updateDemandPlaningVolume(List<Revenue__c> opportunityRevenueList, Map<Id, Revenue__c> opportunityRevenueMap)
    {
        Set<Id> oppRevenueVolumeChangeSet = new Set<Id>();
        List<Revenue__c> withoutDemandPlanningList = new List<Revenue__c>();
        List<Opportunity_Demand_Planning__c> updateList = new List<Opportunity_Demand_Planning__c>();
        
        if(isValidSalesOrgnisation())
        {
            Integer demandPlanningMonths = getNumberOfDemandPlnningMonths();
            
            for(Revenue__c oppRevenue : opportunityRevenueList)
            {
                if(oppRevenue.Volume__c <> opportunityRevenueMap.get(oppRevenue.Id).Volume__c)
                {
                    oppRevenueVolumeChangeSet.add(oppRevenue.Id);
                }
            }
            if(!oppRevenueVolumeChangeSet.isEmpty())
            {
                
                List<Revenue__c> revenueList = [Select Id,Volume__c,Opportunity__r.Supply_Start_Date__c,
                                                Opportunity__r.CASFO_Impact_Date__c, Opportunity__r.RecordTypeId,
                                                (Select Id,Volume__c 
                                                 From Opportunity_Demand_Plannings__r
                                                 Order By Demand_Planning_Date__c Desc)
                                                From Revenue__c  
                                                Where Id IN : opportunityRevenueList];
                for(Revenue__c oppRevenue : revenueList)
                {
                    Decimal oppRevenueMonthlyVolume = (oppRevenue.Volume__c * 2)/demandPlanningMonths;
                    if(oppRevenue.Volume__c <> opportunityRevenueMap.get(oppRevenue.Id).Volume__c 
                       && oppRevenue.Opportunity_Demand_Plannings__r != null 
                       && !oppRevenue.Opportunity_Demand_Plannings__r.isEmpty())
                    {
                        for(Opportunity_Demand_Planning__c oppdp : oppRevenue.Opportunity_Demand_Plannings__r)
                        {
                            oppdp.Volume__c = oppRevenueMonthlyVolume;   
                            updateList.add(oppdp);
                        }
                    }
                    else if (oppRevenue.Opportunity_Demand_Plannings__r == null || 
                             oppRevenue.Opportunity_Demand_Plannings__r.isEmpty())
                    {                       
                        updateList.addAll(createDemandPlaning(oppRevenue, 
                                                              getDemandPlanninngDate(oppRevenue.Opportunity__r, recordTypesMap), 
                                                              demandPlanningMonths));                        
                    }
                }
                upsert updateList;
            }
        }
    }
    
    /*
    * Updates demand planning records when the opportunity date is changed (supply date for opportunity
    * and impact date for vulnerability)
    */
    public void updateDemandPlaningMonth(List<Opportunity> OpportunityList, Map<Id, Opportunity> oldOpportunityMap)
    {
        Set<Id> oppSupplyDateChangeSet = new Set<Id>();
        List<Opportunity_Demand_Planning__c> updateList = new List<Opportunity_Demand_Planning__c>();
        if(isValidSalesOrgnisation())
        {
            Integer demandPlanningMonths = getNumberOfDemandPlnningMonths();
            for(Opportunity opp : OpportunityList)
            {
                if(recordTypesMap.get(opp.RecordTypeId).equals(SFO_Constant.VULNERABILITY)){
                    if(opp.CASFO_Impact_Date__c <> oldOpportunityMap.get(opp.Id).CASFO_Impact_Date__c){
                        oppSupplyDateChangeSet.add(opp.Id);
                    }
                }else{
                    if(opp.Supply_Start_Date__c <> oldOpportunityMap.get(opp.Id).Supply_Start_Date__c){
                        oppSupplyDateChangeSet.add(opp.Id);
                    }
                }                
            }
            if(!oppSupplyDateChangeSet.isEmpty())
            {
                List<Revenue__c> revenueList = [Select Id,Opportunity__r.Supply_Start_Date__c,Volume__c,
                                                Opportunity__r.CASFO_Impact_Date__c, Opportunity__r.RecordTypeId,
                                                (Select Id,Demand_Planning_Date__c 
                                                 From Opportunity_Demand_Plannings__r
                                                 Order By Demand_Planning_Date__c Desc)
                                                From Revenue__c  
                                                Where Opportunity__c IN : oppSupplyDateChangeSet];
                
                for(Revenue__c oppRevenue : revenueList)
                {
                    if(oppRevenue.Opportunity_Demand_Plannings__r != null && 
                       !oppRevenue.Opportunity_Demand_Plannings__r.isEmpty() )
                    {
                        Integer numOfMonths = 0;
                        for(Opportunity_Demand_Planning__c oppdp : oppRevenue.Opportunity_Demand_Plannings__r)
                        {
                            Date demandPlanningDate = getDemandPlanninngDate(oppRevenue.Opportunity__r, recordTypesMap);
                            oppdp.Demand_Planning_Date__c = demandPlanningDate.toStartOfMonth().addMonths(numOfMonths++); 
                            updateList.add(oppdp);
                        }
                    }
                    else if (oppRevenue.Opportunity_Demand_Plannings__r == null || 
                             oppRevenue.Opportunity_Demand_Plannings__r.isEmpty())
                    {                        
                        updateList.addAll(createDemandPlaning(oppRevenue,
                                                              getDemandPlanninngDate(oppRevenue.Opportunity__r, recordTypesMap),
                                                              demandPlanningMonths));
                        
                    }
                    
                }
            }
        }
        upsert updateList;
    }
    
    /*
    * Creates demand planning records based on supply date for opportunity
    * and impact date for vulnerability
    */
    public List<Opportunity_Demand_Planning__c> createDemandPlaning(Revenue__c revenue, Date SupplyStartDate, Integer demandPlanningMonths)
    {
        List<Opportunity_Demand_Planning__c> newOppDPList = new List<Opportunity_Demand_Planning__c>();
        
        if(SupplyStartDate != null && revenue.Volume__c != null && revenue.Volume__c != 0)
        {
            Decimal oppRevenueMonthlyVolume = (revenue.Volume__c * 2)/demandPlanningMonths;           
            for(Integer numOfMonths = 0; numOfMonths < demandPlanningMonths; numOfMonths++)
            {
                Opportunity_Demand_Planning__c newOppDP = new Opportunity_Demand_Planning__c();
                newOppDP.Volume__c = oppRevenueMonthlyVolume;
                newOppDP.Demand_Planning_Date__c = supplyStartDate.toStartOfMonth().addMonths(numOfMonths);
                newOppDP.Opportunity_Revenue__c = revenue.Id;
                newOppDPList.add(newOppDP);
            }
        }
        return newOppDPList;
    }
    
    @TestVisible
    private static integer getNumberOfDemandPlnningMonths()
    {
        SFO_Configuration_Settings__mdt revenueDemandPlanningMonths = [Select Id,SFO_Number_Value__c  
                                                                       From SFO_Configuration_Settings__mdt 
                                                                       Where DeveloperName = 'Revenue_Demand_Planning_Months'];
        return Integer.ValueOf(revenueDemandPlanningMonths.SFO_Number_Value__c);
    }
    
    @TestVisible
    private static List<String> getRevenueDemandPlanningSalesOrg()
    {
        if(salesOrgs == null)
        {
            salesOrgs = new List<String>();
            SFO_Configuration_Settings__mdt userSalesOrg = [Select Id,SFO_Text_Value__c  
                                                            From SFO_Configuration_Settings__mdt 
                                                            Where DeveloperName = 'Revenue_Demand_Planning_SalesOrg'];
            if(String.isNotBlank(userSalesOrg.SFO_Text_Value__c))
            {
                salesOrgs = userSalesOrg.SFO_Text_Value__c.split(',');
            }
        }
        return salesOrgs;
    }
    
    /*
    * Get List of record types for opportunity
    */
    @TestVisible
    private static Map<Id, String> getOpportunityRecordTypes()
    {
        Map<Id, String> recordTypesMap = new Map<Id, String>();
        for (RecordType recordType : [SELECT Id, Name  FROM RecordType WHERE SObjectType = 'Opportunity']){
            recordTypesMap.put(recordType.Id, recordType.Name);
        }
        return recordTypesMap;
    }
    
    @TestVisible
    private static Boolean isValidSalesOrgnisation()
    {
        User currentUser = [Select Id,Sales_Organisation__c From User Where Id =:UserInfo.getUserId()];
        List<String> salesOrgs = getRevenueDemandPlanningSalesOrg();
        if(salesOrgs.contains(currentUser.Sales_Organisation__c))
        {
            return true;
        }
        return false;
    }
    /*
    * Returns the date based on the opportunity recordtype
    */
    @TestVisible
    private Date getDemandPlanninngDate(Opportunity opportunity, Map<Id, String> recordTypesMap){
        Date inputDate;
        if(recordTypesMap.get(opportunity.recordTypeId).equals(SFO_Constant.VULNERABILITY)){
            inputDate =  opportunity.CASFO_Impact_Date__c;
        }else{
            inputDate =  opportunity.Supply_Start_Date__c;
        }
        return inputDate;
    }
    public void revenueWithProductCode(List<Revenue__c> revenueList)
    {    
        Revenue__c revenueWithProductCode;
        List<Id> opportunities = new List<Id>();
        
        Map<Id, Revenue__c> revenueProductMap = new Map<Id, Revenue__c>([SELECT Id, Product__r.ProductCode    
                                                                         FROM Revenue__c 
                                                                         WHERE Id IN :revenueList]);
        
        for (Revenue__c revenue : revenueList) {
            revenueWithProductCode = revenueProductMap.get(revenue.id);
            
            if (revenueWithProductCode.Product__r.ProductCode == null || revenueWithProductCode.Product__r.ProductCode != 'EST') {
                opportunities.add(revenue.Opportunity__c);
            }
        }        
        if (opportunities.size() > 0) {
            delete [SELECT Id FROM Revenue__c WHERE Opportunity__r.Id IN :opportunities AND Product__r.ProductCode = :'EST'];
        }
    }
}