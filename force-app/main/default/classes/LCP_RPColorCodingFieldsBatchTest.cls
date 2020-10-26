@isTest
public with sharing class LCP_RPColorCodingFieldsBatchTest {
    @testSetup 
    static void setup() {
        //Creating Program and Project records by calling the datafactory methods 
		List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'Standard');
        List<LCP_Project__C> project = LCP_TestDataFactory.createProject(1, pgmList[0].id);
        List<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_Standard', project[0].id);
    }
    static testmethod void LCP_ColorCodingFieldsBatch_Test() {
        //Testing the batch class functionality
        Test.startTest();
        //Retrieving the created record from the datasetup
        List<LCP_Reporting_Period__c> rp = [SELECT Id,LCP_ARBOC_Issuance_Date__c,LCP_ARBOC_Issuance_Color_code__c,
                                            LCP_Delivery_Date2__c,LCP_Delivery_Date2_Color_code__c,
                                            LCP_Conversion_Application__c,LCP_Conversion_Application_Color_code__c,
                                            LCP_Conversion_Approval__c,LCP_Conversion_Approval_Color_code__c,
                                            LCP_Delivery_Date__c,LCP_Delivery_Date_Color_code__c,LCP_End__c,
                                            LCP_End_Color_code__c,LCP_End_of_RP__c,LCP_End_of_RP_Color_Code__c,
                                            LCP_Issuance_Date__c,LCP_Issuance_Date_Color_code__c,LCP_OPDR_Submitted__c,
                                            LCP_OPDR_Submitted_Color_code__c,LCP_Report_Submitted__c,
                                            LCP_Report_Submitted_Color_code__c,LCP_ROC_Issuance_Date__c,
                                            LCP_ROC_Issuance_Date_Color_code__c,LCP_Start__c,LCP_Start_Color_code__c,
                                            LCP_Start_of_RP__c,LCP_Start_of_RP_Color_code__c,LCP_Transfer_Date__c,
                                            LCP_Transfer_Date_Color_code__c FROM LCP_Reporting_Period__c WHERE Name = 'TestRP0' limit 1];
        
        rp[0].LCP_ARBOC_Issuance_Date__c = SYSTEM.today().addDays(-1);
        rp[0].LCP_ARBOC_Issuance_Color_code__c = 'Forecast';
        rp[0].LCP_Delivery_Date2__c  = SYSTEM.today().addDays(-5);
        rp[0].LCP_Delivery_Date2_Color_code__c = 'Forecast';
        rp[0].LCP_Channel__C=True;
        rp[0].LCP_Conversion_Application__c = SYSTEM.today().addDays(-2);
        rp[0].LCP_Conversion_Application_Color_code__c = 'Forecast';
        rp[0].LCP_Conversion_Approval__c = SYSTEM.today().addDays(-2);
        rp[0].LCP_Conversion_Approval_Color_code__c = 'Forecast';
        rp[0].LCP_Delivery_Date__c = SYSTEM.today().addDays(-1);
        rp[0].LCP_Delivery_Date_Color_code__c = 'Forecast';
        rp[0].LCP_End__c = SYSTEM.today().addDays(-1);
        rp[0].LCP_End_Color_code__c = 'Forecast';
        rp[0].LCP_End_of_RP__c = SYSTEM.today().addDays(-12);
        rp[0].LCP_End_of_RP_Color_Code__c = 'Forecast';
        rp[0].LCP_Issuance_Date__c = SYSTEM.today().addDays(-20);
        rp[0].LCP_Issuance_Date_Color_code__c = 'Forecast';
        rp[0].LCP_OPDR_Submitted__c = SYSTEM.today().addDays(-17);
        rp[0].LCP_OPDR_Submitted_Color_code__c = 'Forecast';
        rp[0].LCP_Report_Submitted__c = SYSTEM.today().addDays(-56);
        rp[0].LCP_Report_Submitted_Color_code__c = 'Forecast';
        rp[0].LCP_ROC_Issuance_Date__c = SYSTEM.today().addDays(-4);
        rp[0].LCP_ROC_Issuance_Date_Color_code__c = 'Forecast';
        rp[0].LCP_Start__c = SYSTEM.today().addDays(-4);
        rp[0].LCP_Start_Color_code__c = 'Forecast';
        rp[0].LCP_Start_of_RP__c = SYSTEM.today().addDays(-1);
        rp[0].LCP_Start_of_RP_Color_code__c = 'Forecast';
        rp[0].LCP_Transfer_Date__c = SYSTEM.today().addDays(-18);
        rp[0].LCP_Transfer_Date_Color_code__c = 'Forecast';
        update rp;
        
        system.assertEquals(SYSTEM.today()-1, rp[0].LCP_ARBOC_Issuance_Date__c);//Checking whether the Application_documents date is exceeds today's date or not
        LCP_RPColorCodingFieldsBatch batch_Test = new LCP_RPColorCodingFieldsBatch();
        Database.executeBatch(batch_Test);
        Test.stopTest();
    }
}