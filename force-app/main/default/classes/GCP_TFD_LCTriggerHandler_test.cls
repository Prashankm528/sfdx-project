/**
* @author      Avinash Jain
* @date      18/09/2019
* @description    Test class for LetterOfCreditTriggerHandler      
*/
@isTest
public with sharing class GCP_TFD_LCTriggerHandler_test {
       /**
* @description Method to Test all possible scenarios.
*/    
    public static id BPLErecordtype = Schema.SObjectType.GCP_ETY_Credit_Entity__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CE_RECORD_TYPE_BPLE).getRecordTypeId();    
    public static id Counterpatyrecordtype = Schema.SObjectType.GCP_ETY_Credit_Entity__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CE_RECORD_TYPE_COUNTERPARTY).getRecordTypeId();    
    
    @isTest static void TestLetterOfcreditinsert1(){
        //Test class to test the insert trigger and update trigger...
        Account a1 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 1','123',False);
        Account a2 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 2','12',True);
        Account a3 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 3','1',False);
        GCP_ETY_Credit_Entity__c acc1 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a1,Counterpatyrecordtype);
        GCP_ETY_Credit_Entity__c acc2 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a2,BPLErecordtype);
        GCP_ETY_Credit_Entity__c acc3 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a3,Counterpatyrecordtype);
        GCP_TFD_RelatedRights__c RR = GCP_TFD_TestDataFactory.createRelatedRightsforOC(acc3,'SBLC','Details');
        List<GCP_TFD_Letter_of_Credit__c> LCList = new List<GCP_TFD_Letter_of_Credit__c>();
        Test.startTest();
        GCP_TFD_Letter_of_Credit__c LC = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
        LC.GCP_TFD_Deal_Reference__c = 'A190010086';
        LC.GCP_TFD_Run_Update_Trigger__c = TRUE;
        LC.GCP_TFD_NTID__c = 'nas1';
        update LC;
        System.assertEquals(1,[select count() from case]);
        Test.stopTest(); 
    }   
    
        @isTest static void TestLetterOfcreditinsert2(){
        //Method to test the update trigger...
        Account a1 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 1','123',False);
        Account a2 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 2','12',True);
        Account a3 = GCP_TFD_TestDataFactory.createAccountforOC('Test Account 3','1',False);
        GCP_ETY_Credit_Entity__c acc1 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a1,Counterpatyrecordtype);
        GCP_ETY_Credit_Entity__c acc2 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a2,BPLErecordtype);
        GCP_ETY_Credit_Entity__c acc3 = GCP_TFD_TestDataFactory.createCreditEntityforOC(a3,Counterpatyrecordtype);
        GCP_TFD_RelatedRights__c RR = GCP_TFD_TestDataFactory.createRelatedRightsforOC(acc3,'SBLC','Details');
        List<GCP_TFD_Letter_of_Credit__c> LCList = new List<GCP_TFD_Letter_of_Credit__c>();
        Test.startTest();
        GCP_TFD_Letter_of_Credit__c LC = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
        LC.GCP_TFD_Deal_Reference__c = 'E190010086';
        update LC;
        System.assertEquals(1,[select count() from case]);
        Test.stopTest(); 
    } 
}