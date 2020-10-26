/**
* @description Test class for ISTCP_FileUploadController.
* @author Ravi Potla | 6/12/2020 
**/
@isTest
public with sharing class ISTCP_FileUploadControllerTest {
    
    @testSetup 
    static void testdataSetup(){
        //test setup method for creating test data
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspect Account Test';
        insert acc;

        Profile PfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
        
        user auser = new user(); 
        auser.lastname = 'test1'; 
        auser.Username = 'test123@xyz.com'+ System.currentTimeMillis(); 
        auser.Email = 'test@xyz.com';
        auser.Alias = 't123';
        auser.EmailEncodingKey='UTF-8'; 
        auser.LanguageLocaleKey='en_US'; 
        auser.LocaleSidKey='en_US'; 
        auser.TimeZoneSidKey='America/Chicago'; 
        auser.ProfileId = PfId.id;
        auser.IsActive = true;  
        insert auser; 

        ISTCP_BP_Number__c bpNumber = new ISTCP_BP_Number__c();
        bpNumber.ISTCP_Account__c = acc.Id;
        bpNumber.Name = '234';
        insert bpNumber;

        ISTCP_BP_Number_Entitlement__c entitlement = new ISTCP_BP_Number_Entitlement__c();
        entitlement.ISTCP_BP_Number__c = bpNumber.Id;
        entitlement.ISTCP_User__c = auser.Id;
        insert entitlement;

        ISTCP_Feature__c feature = new ISTCP_Feature__c();
        feature.Name = 'Complex Deal Management';
        insert feature;

        ISTCP_Feature_Access__c access = new ISTCP_Feature_Access__c();
        access.ISTCP_Feature__c = feature.Id;
        access.ISTCP_User__c = auser.Id;
        insert access;

    }

    @isTest
	public static void fileuploadTest(){
        Test.startTest();
        ISTCP_FileUploadController.fetchPickListValue();
        ISTCP_FileUploadController.fetchBPNumberPickListValue();
        Id parentId = null;
        ISTCP_FileUploadController.saveFile(parentId, 'test', 'test', 'Cash flow forecast', '234', 'FEB');
        ISTCP_Log__c log = [Select id, ISTCP_Document_Type__c from ISTCP_Log__c where ISTCP_BP_Number__c = '234'];
        System.assertEquals(log.ISTCP_Document_Type__c , 'Cash flow forecast');
        Test.stopTest();
        
    }
}