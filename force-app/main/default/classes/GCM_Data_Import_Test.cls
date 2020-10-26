/****************************************************************************************************
*  Date          : 12-MAR-2020
*  Author        : Sunny Yap
*  Description   : Test class for GCM_Data_Import
* Modifications  : 12-MAR-2020 SYAP - Initial
12-May-2020    : Apoorv - Modifed the class for task and case insert logic with callable interface
****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Data_Import_Test
{
    
    /****************************************************************************************************
Setup Test Data
****************************************************************************************************/    
    @testSetup static void testDataSetup() {
        GCM_File_Import__c objimport = new GCM_File_Import__c ();
        objimport.GCM_Automation__c ='GCM_File_Import_Case';
        objimport.GCM_Class__c ='GCM_Data_Import_Case';
        objimport.GCM_Method__c ='GCM_Insert';
        objimport.Name = 'GCM_Case';
        objimport.GCM_Active__c = true;
        insert objimport ;
        
        GCM_File_Import__c objimport1 = new GCM_File_Import__c ();
        objimport1.GCM_Automation__c ='GCM_File_Import_Task';
        objimport1.GCM_Class__c ='GCM_Data_Import_Task';
        objimport1.GCM_Method__c ='GCM_Insert';
        objimport1.Name = 'GCM_Task_Dynamic';
        objimport1.GCM_Active__c = true;
        insert objimport1 ;
        
        GCM_File_Import_Log__c log = new GCM_File_Import_Log__c();
        log.GCM_Status__c='sucess,fail';
        insert log;
        
        Account acc = new Account();
        acc.name = 'Demo Account';
        acc.Sales_Organisation__c = 'MX02';
        acc.Type = 'Business';
        acc.Account_ERP_ID__c = '12345';
        insert acc;
        
        contact objCon = new contact();
        objCon.firstname = 'Name';
        objCon.lastname = 'Demo';
        objCon.email = 'demo@abc.com';
        objCon.accountId = acc.Id;
        insert objCon ;
    }
    
    /****************************************************************************************************
Test Task Import Data
****************************************************************************************************/
    @isTest static void testImportDataTask() {
        String data = 'Subject,Description,Owner,Due Date \n'+
            'Visit the customer new 1,Customer\'s office is in London New region, 12345, 2020-03-15';
        
        GCM_File_Import_Log__c logs = [select Id from GCM_File_Import_Log__c where CreatedById = :UserInfo.getUserId() order by CreatedDate desc limit 1];
        
        Test.startTest();
        //call status method
        GCM_Data_Import.getLogStatus(logs.id);
        // Call Import Method
        GCM_Data_Import.importData_Callable('GCM_Task_Dynamic', data);
        
        // Check Results
        List<Task> objTaskcount= [select Id from task where CreatedById = :UserInfo.getUserId()];
        system.assertequals(1,objTaskcount.size());
        Test.stopTest();
    }
    
    /****************************************************************************************************
Test Task failed Import Data
****************************************************************************************************/
    @isTest static void testImportDataTask_failed() {
        String data = 'Subject,Description,Owner,Due Date \n'+
            'Visit the customer new 1,Customer\'s office is in London New region, demo@bp.om, 20-03-2020';
        
        GCM_File_Import_Log__c logs = [select Id from GCM_File_Import_Log__c where CreatedById = :UserInfo.getUserId() order by CreatedDate desc limit 1];
        
        Test.startTest();
        //call status method
        GCM_Data_Import.getLogStatus(logs.id);
        // Call Import Method
        GCM_Data_Import.importData_Callable('GCM_Task_Dynamic', data);
        // Check Results
        List<Task> objTaskcount= [select Id from task where CreatedById = :UserInfo.getUserId()];
        system.assertequals(0,objTaskcount.size());
        Test.stopTest();
    }
    
    /****************************************************************************************************
Test case exception Import Data
****************************************************************************************************/
    @isTest static void testImportDatacaseException() {
        String data = 'Subject,Description,Owner,Due Date \n'+
            'Visit the customer new 1,Customer\'s office is in London New region, demo@bp.om, 20-03-2020';
        Test.startTest();
        GCM_Data_Import.importData_Callable('GCM_Case', data);
        Test.stopTest();
    }
    
    
    /****************************************************************************************************
Test case Import Data
****************************************************************************************************/
    @isTest static void testImportDataCase() {
        String data = 'Type,Area,Sub Area,Priority,Description,Account,Account ERP Id,Contact Last Name,Contact First Name,Contact Email,User NTID,Date/Time Incident,Complaint,Record Type Name \n'+
            'Invoice Management,Blocked Invoices,Blocked Invoice Report,1-ASAP,Invoice number 123456,Demo Account,12345,Demo,Name,demo@abc.com,12345,2020-01-01 23:15:00,TRUE,Fuel - Cards';
        
        Test.startTest();
        GCM_Data_Import.importData_Callable('GCM_Case', data);
        // Check Results
        List<case> objCase= [select Id from case where CreatedById = :UserInfo.getUserId()];
        system.assertequals(0,objCase.size());
        
        Test.stopTest();
    }
    
    /****************************************************************************************************
Test case scenario 1 Import Data
****************************************************************************************************/
    @isTest static void testImportDataCase_1() {
        String data = 'Type,Area,Sub Area,Priority,Description,Account,Account ERP Id,Contact Last Name,Contact First Name,Contact Email,User NTID,Date/Time Incident,Complaint,Record Type Name \n'+
            'Invoice Management,Blocked Invoices,Blocked Invoice Report,1-ASAP,Invoice number 123456,,12345,,Name,demo@abc.com,12345,2020-01-01 23:15:00,TRUE,Fuel - Cards';
        
        
        Test.startTest();
        GCM_Data_Import.importData_Callable('GCM_Case', data);
        List<case> objCase= [select Id from case where CreatedById = :UserInfo.getUserId()];
        system.assertequals(0,objCase.size());
        Test.stopTest();
    }
    
    /****************************************************************************************************
Test case fail scenario Import Data
****************************************************************************************************/
    @isTest static void testImportDataCase_fail() {
        String data = 'Type,Area,Sub Area,Priority,Description,Account,Account ERP Id,Contact Last Name,Contact First Name,Contact Email,User NTID,Date/Time Incident,Complaint,Record Type Name \n'+
            'Invoice Management,Blocked Invoices,Blocked Invoice Report,1-ASAP,Invoice number 123456,Demo Account1,123415,Demo1,Name1,demo1@abc.com,123451,1/1/2020 23:15:00,TRUE,Fuel - Cards';
        
        Test.startTest();
        GCM_Data_Import.importData_Callable('GCM_Case', data);
        // Check Results
        List<case> objCase= [select Id from case where CreatedById = :UserInfo.getUserId()];
        system.assertequals(0,objCase.size());
        Test.stopTest();
    }
    
    /****************************************************************************************************
Test null 
****************************************************************************************************/   
    @isTest static void checkNull() {
        GCM_Data_Import.importData_Callable(null, null);
        GCM_Data_Import.getLogStatus(null);
    }
    
    /****************************************************************************************************
Test  exceptions
****************************************************************************************************/   
    @isTest static void checkException() {
        GCM_Data_Import.getLogStatus('01p7E000004yoeP');
        GCM_Data_Import_Task_Helper.importData('');
        try
        {
            Callable CallableDemo = (Callable) Type.forName('GCM_Data_Import_Task').newInstance();
            string result = (string)CallableDemo.call( 'GCM_Insert1', new Map<String, Object> { 
                'idImportLogID' => '' 
                    });
        }
        catch(exception ex)
        {
            system.assertequals(ex.getmessage(),'Method not implemented');
        }
        try
        {
            Callable CallableDemo = (Callable) Type.forName('GCM_Data_Import_Case').newInstance();
            string result = (string)CallableDemo.call( 'GCM_Insert1', new Map<String, Object> { 
                'idImportLogID' => '' 
                    });
        }
        catch(exception ex)
        {
            system.assertequals(ex.getmessage(),'Method not implemented');
        }
    }
    
}