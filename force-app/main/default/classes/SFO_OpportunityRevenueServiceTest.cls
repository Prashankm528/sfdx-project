/*****************************************************************************************
*	Date:		    29-Jul-2020
*   Author:         SFO Team
*   Description:    Test class for OpportunityRevenueService
****************************************************************************************/
@isTest 
private class SFO_OpportunityRevenueServiceTest 
{
    private static final String testUserName = 'testvar323232@24234.com';
    private static final String accountName = 'Test Method Account Demand Planning castrol';
    private static final String opportunityName = 'Test Method Opporunity Demand Planning castrol';
    
    @testSetup 
    static void setup() {
        
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser.username = testUserName;
        testCastrolUser.Sales_Organisation__c = SFO_OpportunityRevenueService.getRevenueDemandPlanningSalesOrg().get(0);
        insert testCastrolUser;
        
        System.runAs(testCastrolUser) 
        {
            Account castrolAcc = SFO_TestDataService.createCustomerAccount();
            castrolAcc.Name = accountName;
            insert castrolAcc;
        }
    }
    
    @isTest 
    static void SFO_OppRevDemandPlanningTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList;
        List<Product2> productList;
        Date opportunitySupplyDate = Date.Today();
        
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName];  
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(opportunitySupplyDate,2,false);
            
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<2; i++)
            {
                for(integer j=0; j<2; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            
            Test.startTest();
            insert RevenueList;
            Test.stopTest();
            
            Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
            for(Opportunity_Demand_Planning__c oppDp : [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                        From Opportunity_Demand_Planning__c 
                                                        Where Opportunity_Revenue__c IN : RevenueList])
            {
                System.assertEquals(20,oppDp.Opportunity_Revenue__r.Volume__c/numberOfMonths, 'Volume should be equal to 20');
            }
            
            List<Opportunity_Demand_Planning__c> oppDemandPlanningList = [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                                          From Opportunity_Demand_Planning__c 
                                                                          Where Opportunity_Revenue__c =: RevenueList[0].Id];
            system.assertEquals(oppDemandPlanningList.size() , numberOfMonths, 'Number of demand planning records should be equal to number of months');
        }
    }

    /*
    * Test creating demand planning records for vulnerability
    */
    @isTest 
    static void SFO_VulnerabilityRevDemandPlanningTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList;
        List<Product2> productList;
        Date opportunitySupplyDate = Date.Today();
        
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName];  
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(opportunitySupplyDate,2,true);
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<2; i++)
            {
                for(integer j=0; j<2; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            
            Test.startTest();
            insert RevenueList;
            Test.stopTest();
            
            Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
            for(Opportunity_Demand_Planning__c oppDp : [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                        From Opportunity_Demand_Planning__c 
                                                        Where Opportunity_Revenue__c IN : RevenueList])
            {
                System.assertEquals(20,oppDp.Opportunity_Revenue__r.Volume__c/numberOfMonths, 'Volume should be equal to 20');
            }
            
            List<Opportunity_Demand_Planning__c> oppDemandPlanningList = [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                                          From Opportunity_Demand_Planning__c 
                                                                          Where Opportunity_Revenue__c =: RevenueList[0].Id];
            system.assertEquals(oppDemandPlanningList.size() , numberOfMonths, 'Number of demand planning records should be equal to number of months');
        }
    }
    
    @isTest 
    static void SFO_OppRevDemandPlanningUpdateVolumeTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList;
        List<Product2> productList;
        Date opportunitySupplyDate = Date.Today();
        
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName];  
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(opportunitySupplyDate,2,false);
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<2; i++)
            {
                for(integer j=0; j<2; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            insert RevenueList;
            
            Test.startTest();
            for(Revenue__c revNew : RevenueList)
            {
                revNew.Volume__c = 960;
            }
            update RevenueList;
            Test.stopTest();
            Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
            Decimal updatedVolume = 960/numberOfMonths;
            for(Opportunity_Demand_Planning__c oppDp : [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                        From Opportunity_Demand_Planning__c 
                                                        Where Opportunity_Revenue__c IN : RevenueList])
            {
                System.assertEquals(updatedVolume,oppDp.Opportunity_Revenue__r.Volume__c/numberOfMonths, 'Volume should be equal to 20');
            }
            
            List<Opportunity_Demand_Planning__c> oppDemandPlanningList = [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                                          From Opportunity_Demand_Planning__c 
                                                                          Where Opportunity_Revenue__c =: RevenueList[0].Id];
            system.assertEquals(oppDemandPlanningList.size() , numberOfMonths, 'Number of demand planning records should be equal to number of months');
        }
    }

    /*
    * Test updating the vulnerability revenue volume 
    */
    @isTest 
    static void SFO_VulnerabilityRevDemandPlanningUpdateVolumeTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList;
        List<Product2> productList;
        Date opportunitySupplyDate = Date.Today();
        
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName];  
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(opportunitySupplyDate,2,true);
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<2; i++)
            {
                for(integer j=0; j<2; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            insert RevenueList;
            
            Test.startTest();
            for(Revenue__c revNew : RevenueList)
            {
                revNew.Volume__c = 960;
            }
            update RevenueList;
            Test.stopTest();
            Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
            Decimal updatedVolume = 960/numberOfMonths;
            for(Opportunity_Demand_Planning__c oppDp : [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                        From Opportunity_Demand_Planning__c 
                                                        Where Opportunity_Revenue__c IN : RevenueList])
            {
                System.assertEquals(updatedVolume,oppDp.Opportunity_Revenue__r.Volume__c/numberOfMonths, 'Volume should be equal to 20');
            }
            
            List<Opportunity_Demand_Planning__c> oppDemandPlanningList = [Select Id,Opportunity_Revenue__r.Volume__c,Volume__c 
                                                                          From Opportunity_Demand_Planning__c 
                                                                          Where Opportunity_Revenue__c =: RevenueList[0].Id];
            system.assertEquals(oppDemandPlanningList.size() , numberOfMonths, 'Number of demand planning records should be equal to number of months');
        }
    }
    @isTest 
    static void SFO_OppRevDemandPlanningUpdateMonthTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList;
        List<Product2> productList;
        Date opportunitySupplyDate = Date.Today();
        DateTime supplyStartDate = System.now().addmonths(3);
        
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName]; 
        Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(opportunitySupplyDate,2,false);
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<1; i++)
            {
                for(integer j=0; j<1; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            insert RevenueList;
            
            Test.startTest();
            for(Opportunity newOpp : oppList)
            {
                newOpp.Supply_Start_Date__c = Date.ValueOf(supplyStartDate);
            }
            update oppList;
            Test.stopTest();
            
            DateTime  lastMonth = supplyStartDate.addMonths(numberOfMonths-1);
            String monthNameYear = lastMonth.format('MMMMM')+ ' '+ lastMonth.year();
            
            List<Opportunity_Demand_Planning__c> lastMonthYear = [Select Id,Demand_Planning_Date__c,
                                                                  Demand_Planning_Month_Year__c 
                                                                  From Opportunity_Demand_Planning__c
                                                                  order by Demand_Planning_Date__c desc
                                                                 ];
            System.assertEquals(monthNameYear,lastMonthYear[0].Demand_Planning_Month_Year__c, 'Demand_Planning_Date__c update is failed');
        }
    }
    
    /*
    * Test updating the vulnerability month  
    */
    @isTest 
    static void SFO_VulnerabilityRevDemandPlanningUpdateMonthTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList;
        List<Product2> productList;
        Date opportunitySupplyDate = Date.Today();
        DateTime supplyStartDate = System.now().addmonths(3);
        
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName]; 
        Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(opportunitySupplyDate,2,true);
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<1; i++)
            {
                for(integer j=0; j<1; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            insert RevenueList;
            
            Test.startTest();
            for(Opportunity newOpp : oppList)
            {
                newOpp.CASFO_Impact_Date__c = Date.ValueOf(supplyStartDate);
            }
            update oppList;
            Test.stopTest();
            
            DateTime  lastMonth = supplyStartDate.addMonths(numberOfMonths-1);
            String monthNameYear = lastMonth.format('MMMMM')+ ' '+ lastMonth.year();
            
            List<Opportunity_Demand_Planning__c> lastMonthYear = [Select Id,Demand_Planning_Date__c,
                                                                  Demand_Planning_Month_Year__c 
                                                                  From Opportunity_Demand_Planning__c
                                                                  order by Demand_Planning_Date__c desc
                                                                 ];
            System.assertEquals(monthNameYear,lastMonthYear[0].Demand_Planning_Month_Year__c, 'Demand_Planning_Date__c update is failed');
        }
    }
    @isTest 
    static void SFO_OppRevDPCraeteOnUpdateMonthTest()
    {
        List<Revenue__c> RevenueList = new List<Revenue__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Product2> productList;
        DateTime supplyStartDate = System.now().addmonths(3);
        User testCastrolUser = [Select Id,Sales_Organisation__c from User where username=: testUserName]; 
        Integer numberOfMonths = Integer.ValueOf(SFO_OpportunityRevenueService.getNumberOfDemandPlnningMonths());
        
        System.runAs(testCastrolUser) 
        {
            oppList = createOpportunity(null,2,false);
            productList = createProduct(testCastrolUser.Sales_Organisation__c,2);
            
            for(integer i=0; i<1; i++)
            {
                for(integer j=0; j<1; j++)
                {
                    Revenue__c revNew = SFO_TestDataService.createOpportunityRevenue(oppList[i].Id, productList[j].Id);
                    revNew.Volume__c = 480;
                    RevenueList.add(revNew);    
                }
            }
            insert RevenueList;
            
            List<Opportunity_Demand_Planning__c> demandPlnningList = [Select Id,Demand_Planning_Date__c,
                                                                      Demand_Planning_Month_Year__c 
                                                                      From Opportunity_Demand_Planning__c
                                                                      Where Opportunity_Revenue__c IN : RevenueList
                                                                      order by Demand_Planning_Date__c desc
                                                                     ];
            System.assertEquals(0,demandPlnningList.size(), 'DemandPlanning for the should be empty');
            
            Test.startTest();
            for(Opportunity newOpp : oppList)
            {
                newOpp.Supply_Start_Date__c = Date.ValueOf(supplyStartDate);
            }
            update oppList;
            Test.stopTest();
            
            DateTime  lastMonth = supplyStartDate.addMonths(numberOfMonths-1);
            String monthNameYear = lastMonth.format('MMMMM')+ ' '+ lastMonth.year();
            
            List<Opportunity_Demand_Planning__c> lastMonthYear = [Select Id,Demand_Planning_Date__c,
                                                                  Demand_Planning_Month_Year__c 
                                                                  From Opportunity_Demand_Planning__c
                                                                  order by Demand_Planning_Date__c desc
                                                                 ];
            System.assertEquals(monthNameYear,lastMonthYear[0].Demand_Planning_Month_Year__c, 'Demand_Planning_Date__c update is failed');
        }
    }
    
    private static List<Opportunity> createOpportunity(Date supplyStartDate, Integer batchSize, boolean isVulnerability)
    {
        List<Opportunity> oppList = new List<Opportunity>();
        Date opportunityCloseDate = Date.Today();
        Account castrolAcc = [Select Id From Account Where Name =: accountName];
        
        for(integer i=0; i<batchSize; i++)
        {
            Opportunity castrolOpp = SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id);
            castrolOpp.Name = opportunityName;
            castrolOpp.StageName = 'Lead';
            castrolOpp.CloseDate = opportunityCloseDate;
            if(isVulnerability){               
                castrolOpp.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SFO_Constant.VULNERABILITY).getRecordTypeId();
                castrolOpp.CASFO_Impact_Date__c = supplyStartDate; 
            }else{
                castrolOpp.Supply_Start_Date__c = supplyStartDate; 
            }   
            oppList.add(castrolOpp);
        }
        insert oppList;
        return oppList;
    }
    
    private static List<Product2> createProduct(String salesOrganisation, Integer batchSize)
    {
        List<Product2> productList = SFO_TestDataService.createCastrolTestProducts(batchSize);
        for(Product2 prod : productList)
        {
            prod.CASFO_Product_Sales_Organisation__c = salesOrganisation;
        }
        insert productList; 
        return productList;
    }
}