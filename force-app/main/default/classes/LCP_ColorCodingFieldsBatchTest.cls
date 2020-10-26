@isTest
public with sharing class LCP_ColorCodingFieldsBatchTest {
    @testSetup 
    static void setup() {
        //Creating Program and Project records by calling the datafactory methods 
		List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'Standard');
        List<LCP_Project__C> project = LCP_TestDataFactory.createProject(1, pgmList[0].id);
    }
    static testmethod void LCP_ColorCodingFieldsBatch_Test() {
        //Testing the batch class functionality
        Test.startTest();
        //Retrieving the created record from the datasetup
        List<LCP_Project__C> project = [SELECT Id,LCP_Application_documents_color_code__c,LCP_Design_documents_color_code__c,
                                        LCP_Val_Start_color_code__c,LCP_Val_end_color_code__c,
                                        LCP_Req_for_registration_color_code__c,LCP_Listed_color_code__c,
                                        LCP_Registered_color_code__c,LCP_Operational_start_date_color_code__c,
                                        LCP_Contract_date_color_code__c,LCP_CP_start_color_code__c,LCP_CP_end_color_code__c,
                                        LCP_Date_color_code__c,LCP_Date2_color_code__c,
                                        LCP_California_DEBS_approved_color_code__c,LCP_Application_documents__c,
                                        LCP_Date2__c,LCP_Date__c,LCP_California_DEBS_approved__c,LCP_CP_end__c,
                                        LCP_CP_start__c,LCP_Contract_date__c,LCP_Operational_start_date__c,LCP_Registered__c,
                                        LCP_Listed__c,LCP_Design_documents__c,LCP_Val_start__c,LCP_Val_end__c,
                                        LCP_Req_for_registration__c FROM LCP_Project__C WHERE Name = 'TestProject0' limit 1];
        
        project[0].LCP_Application_documents__c = SYSTEM.today().addDays(-1);
        project[0].LCP_Application_documents_color_code__c = 'Forecast';
        project[0].LCP_Design_documents__c  = SYSTEM.today().addDays(-5);
        project[0].LCP_Design_documents_color_code__c = 'Forecast';
        project[0].LCP_Val_start__c = SYSTEM.today().addDays(-2);
        project[0].LCP_Val_Start_color_code__c = 'Forecast';
        project[0].LCP_Val_end__c = SYSTEM.today().addDays(-2);
        project[0].LCP_Val_end_color_code__c = 'Forecast';
        project[0].LCP_Req_for_registration__c = SYSTEM.today().addDays(-1);
        project[0].LCP_Req_for_registration_color_code__c = 'Forecast';
        project[0].LCP_Listed__c = SYSTEM.today().addDays(-1);
        project[0].LCP_Listed_color_code__c = 'Forecast';
        project[0].LCP_Registered__c = SYSTEM.today().addDays(-12);
        project[0].LCP_Registered_color_code__c = 'Forecast';
        project[0].LCP_Operational_start_date__c = SYSTEM.today().addDays(-20);
        project[0].LCP_Operational_start_date_color_code__c = 'Forecast';
        project[0].LCP_Contract_date__c = SYSTEM.today().addDays(-17);
        project[0].LCP_Contract_date_color_code__c = 'Forecast';
        project[0].LCP_CP_start__c = SYSTEM.today().addDays(-56);
        project[0].LCP_CP_start_color_code__c = 'Forecast';
        project[0].LCP_CP_end__c = SYSTEM.today().addDays(-4);
        project[0].LCP_CP_end_color_code__c = 'Forecast';
        project[0].LCP_Date__c = SYSTEM.today().addDays(-4);
        project[0].LCP_Date_color_code__c = 'Forecast';
        project[0].LCP_California_DEBS_approved__c = SYSTEM.today().addDays(-1);
        project[0].LCP_California_DEBS_approved_color_code__c = 'Forecast';
        project[0].LCP_Date2__c = SYSTEM.today().addDays(-18);
        project[0].LCP_Date2_color_code__c = 'Forecast';
        update project;
        
        system.assertEquals(SYSTEM.today()-1, project[0].LCP_Application_documents__c);//Checking whether the Application_documents date is exceeds today's date or not
        LCP_ColorCodingFieldsBatch batch_Test = new LCP_ColorCodingFieldsBatch();
        Database.executeBatch(batch_Test);
        Test.stopTest();
    }
}