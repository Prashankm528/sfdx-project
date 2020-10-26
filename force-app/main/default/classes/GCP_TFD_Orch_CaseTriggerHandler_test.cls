/**
* @author       Sid
* @date         11/12/2019
* @description  Test class for LetterOfCreditTriggerHandler      
*/
@isTest
public with sharing class GCP_TFD_Orch_CaseTriggerHandler_test
{
    //Method to test create case...
    @isTest 
    static void Createcase()
    {
        system.test.startTest();
        case cs = gcp_tfd_testdatafactory.createCase();
        Case cs1 = gcp_tfd_testdatafactory.createGCPCase();
        system.test.stopTest();
        system.assertNotEquals(NULL,[Select id from case Limit 1].Id);
    }
    //Method to test update case...
    @isTest 
    static void Updatecase()
    {
        system.test.startTest();
        case cs = gcp_tfd_testdatafactory.createCase();
        Case cs1 = gcp_tfd_testdatafactory.createGCPCase();
        cs.gcp_tfd_generate_document__c = True;
        cs1.gcp_tfd_generate_document__c = True;
        update cs;
        update cs1;
        system.test.stopTest();
        system.assertNotEquals(NULL,[Select id from case Limit 1].Id);
    }
    @isTest 
    static void deleteCase()
    {
        system.test.startTest();
        Case cs1 = gcp_tfd_testdatafactory.createGCPCase();
        delete cs1;
        undelete cs1;
        system.test.stopTest();
        system.assertNotEquals(NULL,[Select id from case Limit 1]);
    }
}