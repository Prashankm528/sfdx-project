/**
* @author     Irfan Ahmed
* @date       19/06/2020
* @description    Test class for projecttrigger and helper class  
* 
* History
*  
*/
@isTest(SeeAllData=False)

public with sharing class ICRM_CapExTriggerHandlerTest {
    
    /**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() {
        String sTime= String.valueOf(System.currentTimeMillis());
        string recTypeid = Schema.getGlobalDescribe().get('ICRM_CapEx__c').getDescribe().getRecordTypeInfosByName().get('ICRM CapEx').getRecordTypeId();
        ICRM_Project__c proj = new ICRM_Project__c();
        proj.Name = 'Test Project'+sTime;
        insert proj;
        ICRM_CapEx__c  CapObj1 = new ICRM_CapEx__c();
        CapObj1.ICRM_Project__c = proj.Id;
        CapObj1.RecordTypeId = recTypeid;
        Date myDate = Date.newInstance(2019, 2, 17);
        CapObj1.ICRM_Date__c = myDate;
        insert CapObj1;    
    }
    
    /**
* @description - test method
*/
    @istest
    public static void testcapExVerifyYearQuarter(){
        String recTypeid2 = Schema.getGlobalDescribe().get('ICRM_CapEx__c').getDescribe().getRecordTypeInfosByName().get('ICRM CapEx').getRecordTypeId();
        Date myDate = Date.newInstance(2019, 2, 17);
        ICRM_Project__c proj1 =  [Select id from ICRM_Project__c where name like 'Test Project%'];
        ICRM_CapEx__c  CapObj2 = new ICRM_CapEx__c();
        CapObj2.ICRM_Project__c = proj1.Id;
        CapObj2.RecordTypeId = recTypeid2;
        CapObj2.ICRM_Date__c = myDate;
        Test.startTest();
        try
        {
            insert CapObj2;     
        }
        catch (DMLException e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is already a Capital Expenditure on this Project for this Quarter and Year.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();   
    }  
}