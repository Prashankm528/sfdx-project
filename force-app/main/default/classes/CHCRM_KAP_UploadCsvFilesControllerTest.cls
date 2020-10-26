/***********************************************************************************************
* @author           WuTong
* @date             2020/09/17
* @group            CHCRM
* @description      Test class for CHCRM_KAP_UploadCsvFilesController
* history
* 2020/09/17 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_UploadCsvFilesControllerTest {
    
    @testSetup
    static void testSetup(){
        //set Sales Target Account        
        Account testAccount = CHCRM_TestSetup.createWorkshopAccount('CsvfileAccount');
        testAccount.CHCRM_Key_Account_Flg__c = true;
        insert testAccount;
        CHCRM_Sub_Channel_Account__c subChannelAccouont 
            = CHCRM_TestSetup.createSubChannelAccount(testAccount.Id , 'TestSubChannel', 
                                                                                                  'SCA-TEST-0001');
        insert subChannelAccouont;
        CHCRM_Product_Structure__c structure = CHCRM_TestSetup.createProductStructure('TestStructure',null);
        insert structure;
        CHCRM_SKU_Detail__c sku = CHCRM_TestSetup.createSKU(structure.Id ,'TestSKU');
        insert sku;
        CHCRM_PBV_Detail__c pbv = CHCRM_TestSetup.createPBV('TestPBV',null);
        insert pbv;
        Id subChannelAccountId = subChannelAccouont.Id;
        //create kap
        insert CHCRM_TestSetup.createKap(subChannelAccouont.Id , '2020');
    }
    
    static testMethod void checkRoleCanViewTest01(){
        String uniqueUserName = DateTime.now().getTime() + '@testorg.com';
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser' + uniqueUserName);
        System.runAs(u1) {
            Boolean result = CHCRM_KAP_UploadCsvFilesController.checkRoleCanView();
            String resultStr = result+'';
            System.assertEquals('true', resultStr);
        }
    }
    
    static testMethod void checkRoleCanViewTest02(){
        String uniqueUserName = DateTime.now().getTime() + '@testorg.com';
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'CHCRM Sales Management' LIMIT 1];
        UserRole role = [Select u.Name , u.DeveloperName, u.Id from UserRole u LIMIT 1];
        User u2 = new User(Alias = 'customer', Email='customeruser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p2.Id,
                          TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id,
                          UserName='customeruser' + uniqueUserName);
        System.runAs(u2) {
            Boolean result = CHCRM_KAP_UploadCsvFilesController.checkRoleCanView();
            String resultStr = result+'';
            System.assertEquals('false', resultStr);
        }
    }
    
    static testMethod void uploadFileTestPBVError(){
        String csvStrContent1 = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,Product Brand Variant,Total Volume,Total GM,Total GTO,Total GP,Volume-1,Volume-2,Volume-3,Volume-4,Volume-5,Volume-6,Volume-7,Volume-8,Volume-9,Volume-10,Volume-11,Volume-12,GM-1,GM-2,GM-3,GM-4,GM-5,GM-6,GM-7,GM-8,GM-9,GM-10,GM-11,GM-12,GTO-1,GTO-2,GTO-3,GTO-4,GTO-5,GTO-6,GTO-7,GTO-8,GTO-9,GTO-10,GTO-11,GTO-12,GP-1,GP-2,GP-3,GP-4,GP-5,GP-6,GP-7,GP-8,GP-9,GP-10,GP-11,GP-12\n';
        csvStrContent1 = csvStrContent1 + 'SCA-TEST-0002,2020,SCSA-TEST-0002,Test,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111\n';
        Test.startTest();
        CHCRM_KAP_UploadCsvFilesController.uploadFile(Blob.valueOf(csvStrContent1) , 'testuser@test.com' , 'PBV');
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Failure', salesUpload.CHCRM_Status__c);
    }
    
    static testMethod void uploadFileTestPBVException(){
        String csvStrContent2 = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,Product Brand Variant\n';
        csvStrContent2 = csvStrContent2 + 'SCA-TEST-0001,2020,SCSA-TEST-0001,Test\n';
        Test.startTest();
        CHCRM_KAP_UploadCsvFilesController.uploadFile(Blob.valueOf(csvStrContent2) , 'testuser@test.com' , 'PBV');
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Failure', salesUpload.CHCRM_Status__c);
    }
    
    
    static testMethod void uploadFileTestSKUError(){
        String csvStrContent3 = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,SKU code,Total Volume,Total GM,Total GTO,Total GP,Volume-1,Volume-2,Volume-3,Volume-4,Volume-5,Volume-6,Volume-7,Volume-8,Volume-9,Volume-10,Volume-11,Volume-12,GM-1,GM-2,GM-3,GM-4,GM-5,GM-6,GM-7,GM-8,GM-9,GM-10,GM-11,GM-12,GTO-1,GTO-2,GTO-3,GTO-4,GTO-5,GTO-6,GTO-7,GTO-8,GTO-9,GTO-10,GTO-11,GTO-12,GP-1,GP-2,GP-3,GP-4,GP-5,GP-6,GP-7,GP-8,GP-9,GP-10,GP-11,GP-12\n';
        csvStrContent3 = csvStrContent3 + 'SCA-TEST-0002,2020,,,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111\n';
        Test.startTest();
        CHCRM_KAP_UploadCsvFilesController.uploadFile(Blob.valueOf(csvStrContent3) , 'testuser@test.com' , 'SKU');
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Failure', salesUpload.CHCRM_Status__c);
    }
    
    static testMethod void uploadFileTestSKUException(){
        String csvStrContent4 = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,Product Brand Variant\n';
        csvStrContent4 = csvStrContent4 + 'SCA-TEST-0001,2020,SCSA-TEST-0001,Test\n';
        Test.startTest();
        CHCRM_KAP_UploadCsvFilesController.uploadFile(Blob.valueOf(csvStrContent4) , 'testuser@test.com' , 'SKU');
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Failure', salesUpload.CHCRM_Status__c);
    }    
    
    static testMethod void uploadFileTestSKUSuccess(){
        String csvStrContent5 = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,SKU code,Total Volume,Total GM,Total GTO,Total GP,Volume-1,Volume-2,Volume-3,Volume-4,Volume-5,Volume-6,Volume-7,Volume-8,Volume-9,Volume-10,Volume-11,Volume-12,GM-1,GM-2,GM-3,GM-4,GM-5,GM-6,GM-7,GM-8,GM-9,GM-10,GM-11,GM-12,GTO-1,GTO-2,GTO-3,GTO-4,GTO-5,GTO-6,GTO-7,GTO-8,GTO-9,GTO-10,GTO-11,GTO-12,GP-1,GP-2,GP-3,GP-4,GP-5,GP-6,GP-7,GP-8,GP-9,GP-10,GP-11,GP-12\n';
        csvStrContent5 = csvStrContent5 + 'SCA-TEST-0001,2020,SCSA-TEST-0001,TestSKU,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111\n';
        Test.startTest();
        CHCRM_KAP_UploadCsvFilesController.uploadFile(Blob.valueOf(csvStrContent5) , 'testuser@test.com' , 'SKU');
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Completed', salesUpload.CHCRM_Status__c);
    }

}