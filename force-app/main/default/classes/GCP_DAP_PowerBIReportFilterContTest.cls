/*****************************************************************************************
*   Date: 05/12/2019 
*   Author: Subin M Nair   
*   Description: Test class for GCP_DAP_PowerBIReportFilterController class

*   Date: 20/04/2020 
*   Author: Subin M Nair   
*   Description: Modifications to support Parameterized reports
*******************************************************************************************/
@isTest
private with sharing class GCP_DAP_PowerBIReportFilterContTest {

    @testSetup 
    static void setup() {

        BPG_PBI_Report__c testReport = new BPG_PBI_Report__c();
        testReport.Name = 'DAP Relationship Report';
        testReport.BPG_Embed_URL__c = 'test';
        insert testReport;
        
        BPG_PBI_Report__c testReport1 = new BPG_PBI_Report__c();
        testReport1.Name = 'DAP NAGP Credit Report';
        testReport1.BPG_Embed_URL__c = 'test1';
        insert testReport1;

        BPG_PBI_Report_Filter__c repfilter = new BPG_PBI_Report_Filter__c();
        repfilter.BPG_PBI_Report__c = testReport.id;
        repfilter.BPG_Active__c = true;
        repfilter.BPG_Table_Name__c = 'RELATIONSHIP';
        repfilter.BPG_Column_Name__c = 'RELATIONSIP_ID';
        repfilter.BPG_Operator__c = 'eq';
        repfilter.BPG_Type__c = 'Relationship';
        insert repfilter;
        
        BPG_PBI_Report_Filter__c repfilter1 = new BPG_PBI_Report_Filter__c();
        repfilter1.BPG_PBI_Report__c = testReport1.id;
        repfilter1.BPG_Active__c = true;
        repfilter1.BPG_Table_Name__c = 'CREDIT_ENTITY';
        repfilter1.BPG_Column_Name__c = 'ID';
        repfilter1.BPG_Operator__c = 'eq';
        repfilter1.BPG_Type__c = 'CreditEntity';
        insert repfilter1;
        
        GCP_ETY_Relationship__c rel = new GCP_ETY_Relationship__c();
        rel.Name = 'TestName';
        rel.GCP_ETY_Relationship_ID__c = 123;
        insert rel;
        
        GCP_ETY_Credit_Entity__c cred = new GCP_ETY_Credit_Entity__c();
        cred.Name = 'Test';
        cred.recordtypeid = Schema.getGlobalDescribe().get('GCP_ETY_Credit_Entity__c').getDescribe().getRecordTypeInfosByDeveloperName().get('GCP_ETY_Pseudo_Entity').getRecordTypeId();
        cred.GCP_ETY_CRS_ID__c = 90190;
        insert cred;

    }
    
    @isTest 
    static void testGetFilters() {
        
        GCP_ETY_Relationship__c relation = [Select Id,Name,GCP_ETY_Relationship_ID__c from GCP_ETY_Relationship__c limit 1];

        List<BPG_PBI_Report__c> testReportList = [Select Name,BPG_Embed_URL__c from BPG_PBI_Report__c where Name='DAP Relationship Report'];

        List<BPG_PowerBIFilter> filters;

        Test.startTest();
        GCP_DAP_PowerBIReportFilterController filterClass = new GCP_DAP_PowerBIReportFilterController();
        filters = filterClass.getFilters(testReportList[0].Name, relation.Id);
        Test.stopTest();

        System.assertNotEquals(null, filters, 'Filters list should not be null for this test report.');
        System.assertEquals(testReportList.size(),1);
    }
    
    @isTest 
    static void testGetFiltersCred() {
        
        GCP_ETY_Credit_Entity__c credEntity = [Select Id,Name,GCP_ETY_CRS_ID__c from GCP_ETY_Credit_Entity__c limit 1];

        List<BPG_PBI_Report__c> testReportList1 = [Select Name,BPG_Embed_URL__c from BPG_PBI_Report__c where Name='DAP NAGP Credit Report'];

        List<BPG_PowerBIFilter> filters;

        Test.startTest();
        GCP_DAP_PowerBIReportFilterController filterClass = new GCP_DAP_PowerBIReportFilterController();
        filters = filterClass.getFilters(testReportList1[0].Name, credEntity.Id);
        Test.stopTest();

        System.assertNotEquals(null, filters, 'Filters list should not be null for this test report.');
        System.assertEquals(testReportList1.size(),1);
    }
}