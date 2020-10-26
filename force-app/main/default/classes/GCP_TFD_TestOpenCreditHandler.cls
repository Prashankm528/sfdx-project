/**
* @author      Avinash Jain
* @date      21/08/2019
* @description    Test class for OpenCreditTriggerHandler      
*/
@isTest
public with sharing class GCP_TFD_TestOpenCreditHandler
{
    /**
* @description Method to Test if GCP_TFD_Bank_ICOS__c is updating correctly.
*/
    public static id BPLErecordtype = Schema.SObjectType.GCP_ETY_Credit_Entity__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CE_RECORD_TYPE_BPLE).getRecordTypeId();    
    public static id Counterpatyrecordtype = Schema.SObjectType.GCP_ETY_Credit_Entity__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CE_RECORD_TYPE_COUNTERPARTY).getRecordTypeId();    
    
    @isTest
    static void Testoponcreditinsert1()
    {
        Account a1 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 1','123',False);
        Account a2 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 2','12',True);
        Account a3 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 3','1',False);
        GCP_ETY_Credit_Entity__c acc1 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a1,Counterpatyrecordtype);
        GCP_ETY_Credit_Entity__c acc2 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a2,BPLErecordtype);
        GCP_ETY_Credit_Entity__c acc3 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a3,Counterpatyrecordtype);
        GCP_TFD_RelatedRights__c RR = GCP_TFD_TestDataFactory.createRelatedRightsforOC(acc3,'SBLC','Details');
        
        GCP_TFD_BankDetails__c BD1 = GCP_TFD_TestDataFactory.createBankDetailforOC(acc1,'Crude','GOA');     
        GCP_TFD_BankDetails__c BD2 = GCP_TFD_TestDataFactory.createBankDetailforOC(acc2,'Crude','GOA');

        List<GCP_TFD_OpenCredit__c> OCList =new List<GCP_TFD_OpenCredit__c>();
        GCP_TFD_OpenCredit__c OC = GCP_TFD_TestDataFactory.createOC('12','123','1','UTest','GCRUDE');
        
        GCP_TFD_OpenCreditTriggerHandler OCT = new GCP_TFD_OpenCreditTriggerHandler();
        Test.startTest();
        OCT.onAfterInsert(OCList);
        RR = GCP_TFD_TestDataFactory.UpdateRR(RR,'Insurance');
        OC = GCP_TFD_TestDataFactory.UpdateOC(OC,'A1234');
        OClist.clear();
        OCList.add(OC);
        OCT.onAfterInsert(OCList);
        RR = GCP_TFD_TestDataFactory.UpdateRR(RR,'Guarantee');
        OC = GCP_TFD_TestDataFactory.UpdateOC(OC,'ETest');
        OClist.clear();
        OCList.add(OC);
        OCT.onAfterInsert(OCList);
        Test.stopTest(); 
		System.assertEquals('123',[select GCP_TFD_Bank_ICOS__c from case limit 1].GCP_TFD_Bank_ICOS__c);
    }
    /**
	* @description Method to Test if GCP_TFD_BPLE_ICOS__c is updating correctly.
	*/
    @isTest
    static void Testoponcreditinsert2()
    {
        Account a1 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 1','123',False);
        Account a2 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 2','12',True);
        Account a3 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 3','1',False);
        
        GCP_ETY_Credit_Entity__c acc1 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a1,Counterpatyrecordtype);
        GCP_ETY_Credit_Entity__c acc2 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a2,BPLErecordtype);
        GCP_ETY_Credit_Entity__c acc3 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a3,Counterpatyrecordtype);
        
        GCP_TFD_RelatedRights__c RR = GCP_TFD_TestDataFactory.createRelatedRightsforOC(acc3,'SBLC','Details');
        
        GCP_TFD_BankDetails__c BD1 = GCP_TFD_TestDataFactory.createBankDetailforOC(acc1,'Crude','GOA');     
        GCP_TFD_BankDetails__c BD2 = GCP_TFD_TestDataFactory.createBankDetailforOC(acc2,'Crude','GOA');

        List<GCP_TFD_OpenCredit__c> OCList =new List<GCP_TFD_OpenCredit__c>();
        GCP_TFD_OpenCredit__c OC = GCP_TFD_TestDataFactory.createOC('12','123','1','UTest','GCRUDE');
        
        GCP_TFD_OpenCreditTriggerHandler OCT = new GCP_TFD_OpenCreditTriggerHandler();
        Test.startTest();
        OCT.onAfterInsert(OCList);
        RR = GCP_TFD_TestDataFactory.UpdateRR(RR,'Insurance');
        OC = GCP_TFD_TestDataFactory.UpdateOC(OC,'A1234');
        OClist.clear();
        OCList.add(OC);
        OCT.onAfterInsert(OCList);
        RR = GCP_TFD_TestDataFactory.UpdateRR(RR,'Guarantee');
        OC = GCP_TFD_TestDataFactory.UpdateOC(OC,'ETest');
        OClist.clear();
        OCList.add(OC);
        OCT.onAfterInsert(OCList);
        OC.GCP_TFD_Run_Update_Trigger__c = TRUE;
        update oc;
        Test.stopTest(); 
        System.assertEquals('12',[select GCP_TFD_BPLE_ICOS__c from case limit 1].GCP_TFD_BPLE_ICOS__c);
    }
    /**
	* @description Method to Test if Origin is updating correctly.
	*/
    @isTest
    static void Testoponcreditinsert3()
    {
        Account a1 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 1','123',False);
        Account a2 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 2','12',True);
        Account a3 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 3','1',False);
        
        GCP_ETY_Credit_Entity__c acc1 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a1,Counterpatyrecordtype);
        GCP_ETY_Credit_Entity__c acc2 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a2,BPLErecordtype);
        GCP_ETY_Credit_Entity__c acc3 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a3,Counterpatyrecordtype);
        
        GCP_TFD_RelatedRights__c RR = GCP_TFD_TestDataFactory.createRelatedRightsforOC(acc3,'SBLC','Details');
        
        GCP_TFD_BankDetails__c BD1 = GCP_TFD_TestDataFactory.createBankDetailforOC(acc1,'Crude','GOA');     
        GCP_TFD_BankDetails__c BD2 = GCP_TFD_TestDataFactory.createBankDetailforOC(acc2,'Crude','GOA');

        List<GCP_TFD_OpenCredit__c> OCList =new List<GCP_TFD_OpenCredit__c>();
        GCP_TFD_OpenCredit__c OC = GCP_TFD_TestDataFactory.createOC('12','123','1','UTest','GCRUDE');
        
        GCP_TFD_OpenCreditTriggerHandler OCT = new GCP_TFD_OpenCreditTriggerHandler();
        Test.startTest();
        OCT.onAfterInsert(OCList);
        RR = GCP_TFD_TestDataFactory.UpdateRR(RR,'Insurance');
        OC = GCP_TFD_TestDataFactory.UpdateOC(OC,'A1234');
        OClist.clear();
        OCList.add(OC);
        OCT.onAfterInsert(OCList);
        RR = GCP_TFD_TestDataFactory.UpdateRR(RR,'Guarantee');
        OC = GCP_TFD_TestDataFactory.UpdateOC(OC,'ETest');
        OClist.clear();
        OCList.add(OC);
        OCT.onAfterInsert(OCList);
        Test.stopTest(); 
        System.assertEquals('OCP',[select Origin from case limit 1].Origin);       
    }
}