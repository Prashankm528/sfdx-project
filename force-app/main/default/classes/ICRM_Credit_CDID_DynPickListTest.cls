/**
* @author Santosh Verma
* @date 21/08/2019
* @description - This Test class is for "ICRM_Credit_CDID_DynPickList" used to get the ICOS IDs from the Salesforce Account 
* 
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_Credit_CDID_DynPickListTest { 
    
    /**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() {
        try{
            string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
            system.debug(recTypeid);
            Account acctPros = new Account();
            acctPros.RecordTypeId = recTypeid;
            acctPros.Name = 'Test Account';
            acctPros.BPI_ICOS_ID__c = '1234';
            acctPros.BillingCity = 'Singapore';  
            acctPros.ICRM_BP_Entity__c = true;  
            insert acctPros;
        }
        catch(Exception ex){
            system.debug('Exception_Line_No--->'+ex.getLineNumber());
            system.debug('Exception_Message--->'+ex.getMessage()); 
        } 
    }   
    /**
* @description - test method
*/
    @istest
    private static void testAccount(){
        list<account> acclst = new list<account>();  
        Test.startTest();
        acclst =  ICRM_Credit_CDID_DynPickList.getValues(); 
        system.debug('santosh account list ' + acclst);
        system.debug('acclst.get(0).BPI_ICOS_ID__c = ' + acclst.get(0).BPI_ICOS_ID__c);
        System.assertEquals(acclst.get(0).BPI_ICOS_ID__c, '1234','The test class is not pass'); 
        Test.stopTest(); 
    }  
}