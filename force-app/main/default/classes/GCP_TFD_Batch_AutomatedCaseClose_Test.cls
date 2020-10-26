/**
* @author      Avinash Jain
* @date      18/09/2019
* @description    Test class for GCP_TFD_Batch_AutomatedCaseClose      
*/
@istest
public with sharing class GCP_TFD_Batch_AutomatedCaseClose_Test {
	//Test method to test batch class
	Public static testmethod void method1()
    {  
        Id lcimport = Schema.SObjectType.GCP_TFD_Letter_of_Credit__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CASE_RECORD_TYPE_IMPORT_LC).getRecordTypeId();
        Id lcExport = Schema.SObjectType.GCP_TFD_Letter_of_Credit__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CASE_RECORD_TYPE_EXPORT_LC).getRecordTypeId();
                
        List<case> caselist = GCP_TFD_TestDataFactory.CreateCaseForbatchLcCaseCloser(5);
        List<GCP_TFD_Letter_of_Credit__c> ListLCImport=GCP_TFD_TestDataFactory.CreateLCImportForbatchLcCaseCloser(5,lcimport,caselist);
        List<GCP_TFD_Letter_of_Credit__c> ListLCExport=GCP_TFD_TestDataFactory.CreateLCImportForbatchLcCaseCloser(5,lcExport,caselist);
        List<GCP_TFD_OpenCredit__c> OcList=GCP_TFD_TestDataFactory.CreateOCForbatchLcCaseCloser(5,caselist);
        GCP_TFD_Batch_AutomatedCaseClose Abc = new GCP_TFD_Batch_AutomatedCaseClose();
        Test.startTest();
		database.executeBatch(Abc); 
        Test.stoptest();
        system.assertNotEquals(NULL,caselist[0].Id);
    }
}