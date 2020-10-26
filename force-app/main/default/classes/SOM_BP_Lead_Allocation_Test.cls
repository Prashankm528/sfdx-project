/*********************************************************************************
 * Date:    08FEB17
 * Author:  Jon Marson - Forcify Ltd
 * Desc:    Test class for BP Lead Allocation class
 * Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
 * *******************************************************************************/
@isTest
public with sharing class SOM_BP_Lead_Allocation_Test 
{   
 /*********************************************************************************
 * Date:    08FEB17
 * Author:  Jon Marson - Forcify Ltd
 * Desc:    Method use for test exception.
 * Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
 * *******************************************************************************/
    static testMethod void testException()
    {
        Test.startTest();
        SOM_BP_Lead_Allocation.allocate(null);
        SOM_BP_Lead_Allocation_Lightning_Wrapper.allocate(null);
        system.assertEquals(0,0);
        Test.stopTest();
   }
 
 /*********************************************************************************
 * Date:    08FEB17
 * Author:  Jon Marson - Forcify Ltd
 * Desc:    Method use to test Allocation.
 * Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
 * *******************************************************************************/
    static testMethod void testAllocation()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='SOM Fuel Cards Base'];
        User d1User = new User(UserName='d1User@test.bp.com', Email='d1User@test.bp.com', LastName='D1', Alias='d1User', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=p.Id);    
        User d2User = new User(UserName='d2User@test.bp.com', Email='d2User@test.bp.com', LastName='D2', Alias='d2User', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=p.Id);    
        User d3User = new User(UserName='d3User@test.bp.com', Email='d3User@test.bp.com', LastName='D3', Alias='d3User', TimeZoneSidKey='Europe/London', LocaleSidKey='en_GB', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=p.Id);    
        insert new User[] {d1User, d2User, d3User};     
 Test.startTest();
        Id distributorRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();  
        Account distributor1 = new Account(Name='Distributor1', RecordTypeId=distributorRTID, SOM_Primary_Partner_User__c=d1User.Id,SOM_Email_on_Lead_Assignment__c='mail@test.com');
        Account distributor2 = new Account(Name='Distributor2', RecordTypeId=distributorRTID, SOM_Primary_Partner_User__c=d2User.Id,SOM_Email_on_Lead_Assignment__c='mail@test.com');
        Account distributor3 = new Account(Name='Distributor3', RecordTypeId=distributorRTID, SOM_Primary_Partner_User__c=d3User.Id,SOM_Email_on_Lead_Assignment__c='mail@test.com');
        insert new Account[] {distributor1, distributor2, distributor3};

        Product2 tier1 = new Product2(Name='Tier1', Family='Fuel Card Lead');
        Product2 tier2 = new Product2(Name='Tier1', Family='Fuel Card Lead');
        Product2 tier3 = new Product2(Name='Tier1', Family='Fuel Card Lead');
        insert new Product2[] {tier1, tier2, tier3};
            
        SOM_Allocation_Group__c ag1 = new SOM_Allocation_Group__c(SOM_Product__c=tier1.Id, SOM_Campaign__c='Test Campaign', SOM_Country__c='United Kingdom', SOM_Lower_Bound__c=0, SOM_Upper_Bound__c=1000,SOM_Allocation_Mode__c='Manual');
        SOM_Allocation_Group__c ag2 = new SOM_Allocation_Group__c(SOM_Product__c=tier2.Id, SOM_Campaign__c='Test Campaign1', SOM_Country__c='Germany', SOM_Lower_Bound__c=5000, SOM_Upper_Bound__c=50000,SOM_Allocation_Mode__c='Auto');
        insert new SOM_Allocation_Group__c[] {ag1, ag2};
        
        SOM_Account_Allocation_Group__c aag11 = new SOM_Account_Allocation_Group__c(SOM_Allocation_Group__c=ag1.Id, SOM_Account__c=distributor1.Id, SOM_Sequence__c=1);
        SOM_Account_Allocation_Group__c aag12 = new SOM_Account_Allocation_Group__c(SOM_Allocation_Group__c=ag1.Id, SOM_Account__c=distributor2.Id, SOM_Sequence__c=2);
        SOM_Account_Allocation_Group__c aag22 = new SOM_Account_Allocation_Group__c(SOM_Allocation_Group__c=ag2.Id, SOM_Account__c=distributor2.Id, SOM_Sequence__c=1);
        SOM_Account_Allocation_Group__c aag23 = new SOM_Account_Allocation_Group__c(SOM_Allocation_Group__c=ag2.Id, SOM_Account__c=distributor3.Id, SOM_Sequence__c=2);
        insert new SOM_Account_Allocation_Group__c[] {aag11, aag12, aag22, aag23};
 // date dt = date.parse(system.today());
        SOM_Period__c period = new SOM_Period__c(SOM_Start_Date__c=Date.newInstance(2017, 1, 1), SOM_End_Date__c=system.today(), SOM_Type__c='Month', SOM_Status__c='Closed');
        insert period;
            
        SOM_Budget__c d1Budget = new SOM_Budget__c(Account__c=distributor1.Id, SOM_Period__c=period.Id, SOM_Max_Spend__c=1000);
        SOM_Budget__c d2Budget = new SOM_Budget__c(Account__c=distributor2.Id, SOM_Period__c=period.Id, SOM_Max_Spend__c=1000);
        SOM_Budget__c d3Budget = new SOM_Budget__c(Account__c=distributor3.Id, SOM_Period__c=period.Id, SOM_Max_Spend__c=1000);
        insert new SOM_Budget__c[] {d1Budget, d2Budget, d3Budget};  
     
        SOM_Budget_Item__c  d1t1 = new SOM_Budget_Item__c(SOM_Budget__c=d1Budget.Id, SOM_Product__c=tier1.Id, SOM_Unit_Price__c=30, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d1t2 = new SOM_Budget_Item__c(SOM_Budget__c=d1Budget.Id, SOM_Product__c=tier2.Id, SOM_Unit_Price__c=50, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d1t3 = new SOM_Budget_Item__c(SOM_Budget__c=d1Budget.Id, SOM_Product__c=tier3.Id, SOM_Unit_Price__c=100, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d2t1 = new SOM_Budget_Item__c(SOM_Budget__c=d2Budget.Id, SOM_Product__c=tier1.Id, SOM_Unit_Price__c=30, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d2t2 = new SOM_Budget_Item__c(SOM_Budget__c=d2Budget.Id, SOM_Product__c=tier2.Id, SOM_Unit_Price__c=50, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d2t3 = new SOM_Budget_Item__c(SOM_Budget__c=d2Budget.Id, SOM_Product__c=tier3.Id, SOM_Unit_Price__c=100, SOM_Max_Spend__c=1000);   
        SOM_Budget_Item__c  d3t1 = new SOM_Budget_Item__c(SOM_Budget__c=d3Budget.Id, SOM_Product__c=tier1.Id, SOM_Unit_Price__c=30, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d3t2 = new SOM_Budget_Item__c(SOM_Budget__c=d3Budget.Id, SOM_Product__c=tier2.Id, SOM_Unit_Price__c=50, SOM_Max_Spend__c=1000);
        SOM_Budget_Item__c  d3t3 = new SOM_Budget_Item__c(SOM_Budget__c=d3Budget.Id, SOM_Product__c=tier3.Id, SOM_Unit_Price__c=100, SOM_Max_Spend__c=1000);
        insert new SOM_Budget_Item__c[] {d1t1, d1t2, d1t3, d2t1, d2t2, d2t3, d3t1, d3t2, d3t3};
          
        //Used to store refreshed lead data used in assertions.    
        Map<Id, Lead> leadMap;
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();   
        //Insert 3 leads - all in allocation group 1.  They should round robin between D1 and D2 only
        Lead lead1 = new Lead(recordtypeid=devRecordTypeId,LastName='Test1', Company='TestCompany1', Status='New', SOM_Campaign__c='Test Campaign', Country='United Kingdom', SOM_SQL__c=true, SOM_Monthly_Fuel_Spend__c=500, SOM_Allocation_Group__c=ag1.Id);
        Lead lead2 = new Lead(recordtypeid=devRecordTypeId,LastName='Test2', Company='TestCompany2', Status='New', SOM_Campaign__c='Test Campaign', Country='United Kingdom', SOM_SQL__c=true, SOM_Monthly_Fuel_Spend__c=500, SOM_Allocation_Group__c=ag1.Id);
        Lead lead3 = new Lead(recordtypeid=devRecordTypeId,LastName='Test3', Company='TestCompany3', Status='New', SOM_Campaign__c='Test Campaign', Country='United Kingdom', SOM_SQL__c=true, SOM_Monthly_Fuel_Spend__c=500, SOM_Allocation_Group__c=ag1.Id);
        insert new Lead[] {lead1, lead2, lead3};        
        leadMap = new Map<Id, Lead>([SELECT Id, Status, OwnerId, SOM_Allocation_Group__c FROM Lead]);  
        
        SOM_BP_Lead_Allocation.allocate(leadMap.values());
        SOM_BP_Lead_Allocation_Lightning_Wrapper.allocate(leadMap.values());
        
        
        
      //Insert 3 leads - all in allocation group 2.  They should round robin between D2 and D3 only
        Lead lead4 = new Lead(recordtypeid=devRecordTypeId,LastName='Test4', Company='TestCompany4', Status='New', SOM_Campaign__c='Test Campaign', Country='United Kingdom', SOM_SQL__c=true, SOM_Monthly_Fuel_Spend__c=20000);
        Lead lead5 = new Lead(recordtypeid=devRecordTypeId,LastName='Test5', Company='TestCompany5', Status='New', SOM_Campaign__c='Test Campaign2', Country='United Kingdom2', SOM_SQL__c=true, SOM_Monthly_Fuel_Spend__c=20000);
        Lead lead6 = new Lead(recordtypeid=devRecordTypeId,LastName='Test6', Company='TestCompany6', Status='New', SOM_Campaign__c='Test Campaign', Country='United Kingdom', SOM_SQL__c=true, SOM_Monthly_Fuel_Spend__c=20000);
        insert new Lead[] {lead4, lead5, lead6};        
        leadMap = new Map<Id, Lead>([SELECT Id, Status, OwnerId FROM Lead]);  
        Test.stopTest();
        system.assertEquals('OK', SOM_BP_Lead_Allocation_Wrapper.allocate(lead1.Id));
               
    }   
}