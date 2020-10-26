/***********************************************************************************************
* @author           WuTong
* @date             2020/09/18
* @group            CHCRM
* @description      Test class for CHCRM_KAP_UploadBaselineAndPipeline_Ctrl
* history
* 2020/09/18 WuTong Updated
************************************************************************************************/
@isTest
public with sharing class CHCRM_KAP_UploadBaselineAndPipelineTest {
    
    @testSetup
    static void testSetup(){ 
        Account baseAcc;
        baseAcc = 
            CHCRM_TestSetup.createWorkshopAccount('Account');
        insert baseAcc;
        CHCRM_Sub_Channel_Account__c subChannelBase = CHCRM_TestSetup.createSubChannelAccount(baseAcc.Id , 'SubChannel', 'SCA-TEST-0001');
        insert subChannelBase;
        CHCRM_Key_Account_Plan__c kap = CHCRM_TestSetup.createKap(subChannelBase.Id , '2020');
        insert kap;       
    }
    
    static testMethod void checkRoleCanViewTest01(){
        String name = DateTime.now().getTime() + '@testorg.com';
        Profile p1 
            = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'standt', 
                           Email='standarduser@testorg.com',
                           EmailEncodingKey='UTF-8', 
                           LastName='Testing1', 
                           LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', 
                           ProfileId = p1.Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           UserName='standarduser' + name);
        System.runAs(testUser) {
            Boolean result = CHCRM_KAP_UploadBaselineAndPipeline_Ctrl.checkRoleCanView();
            String resultStr = result+'';
            System.assertEquals('true', resultStr);
        }
    }
    
    static testMethod void checkRoleCanViewTest02(){
        String uniqueUserName = DateTime.now().getTime() + '@testorg.com';
        User u2 = new User(Alias = 'customer', Email='customeruser@testorg.com',
                           EmailEncodingKey='UTF-8', 
                           LastName='Testing2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', 
                           ProfileId = [SELECT Id FROM Profile WHERE Name = 'CHCRM Sales Management' LIMIT 1].Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           UserRoleId = [Select u.Name , u.DeveloperName, u.Id from UserRole u LIMIT 1].Id,
                           UserName='customeruser' + uniqueUserName);
        System.runAs(u2) {
            Boolean result = CHCRM_KAP_UploadBaselineAndPipeline_Ctrl.checkRoleCanView();
            String resultStr = result+'';
            System.assertEquals('false', resultStr);
        }
    }
    
    
    static testMethod void testBaselineAndPipelineError(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        String csvStrContent1 = '生产线/风场,设备编号,数量,工艺,设备制造商,总油箱容积,浓度,总用油量（升）,使用周期（月）,当前供应商,产品,产品类型\n';
        csvStrContent1 = csvStrContent1 + ',,11,Test,Test,800,80,800,12,Test,Test,Test\n';
        Test.startTest();
        CHCRM_KAP_UploadBaselineAndPipeline_Ctrl.uploadFile(Blob.valueOf(csvStrContent1), 'testuser@test.com', 'Baseline', kap.Id);
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Failure', salesUpload.CHCRM_Status__c);
    }
    
    static testMethod void testBaselineAndPipelineException(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        String csvStrContent1 = '生产线/风场,设备编号,数量,工艺,设备制造商,总油箱容积,浓度,总用油量（升）,使用周期（月）,当前供应商,产品,产品类型\n';
        csvStrContent1 = csvStrContent1 + ',,11,Test,Test\n';
        Test.startTest();
        CHCRM_KAP_UploadBaselineAndPipeline_Ctrl.uploadFile(Blob.valueOf(csvStrContent1), 'testuser@test.com', 'Baseline', kap.Id);
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Failure', salesUpload.CHCRM_Status__c);
    }
    
    static testMethod void testBaselineAndPipelineSuccess(){
        CHCRM_Key_Account_Plan__c kap = [SELECT Id FROM CHCRM_Key_Account_Plan__c LIMIT 1];
        String csvStrContent1 = '生产线/风场,设备编号,数量,工艺,设备制造商,总油箱容积,浓度,总用油量（升）,使用周期（月）,当前供应商,产品,产品类型\n';
        csvStrContent1 = csvStrContent1 + 'Test Product,111111,11,Test,Test,800,80,800,12,Test,Test,Test\n';
        Test.startTest();
        CHCRM_KAP_UploadBaselineAndPipeline_Ctrl.uploadFile(Blob.valueOf(csvStrContent1), 'testuser@test.com', 'Baseline', kap.Id);
        Test.stopTest();
        CHCRM_Sales_Plan_Upload__c salesUpload = [select Id , CHCRM_Status__c FROM CHCRM_Sales_Plan_Upload__c LIMIT 1];
        System.assertEquals('Completed', salesUpload.CHCRM_Status__c);
    }
    
}