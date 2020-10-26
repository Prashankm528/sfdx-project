/**
* @ author       -  Gaurav Wadhawan
* @ company      -  IBM
* @ date         -  24/06/2020
* @ description  -  Test Batch class to merge an Account record when it's duplicated.)
*/
@isTest(seeAllData=false)
public with sharing class BPCM_AccountServiceBatchTest {
    
     static testMethod void MergeAccountsTest() {
         
     List<Account> Acclist = new  List<Account>();
        
     String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('BPCM Consumer').getRecordTypeId();      
     //Create Account Test Record
     Account acc1= new Account(RecordTypeID=recordTypeId , FirstName='Test FName2', LastName='Test LName2', BPCM_CV_ID__c = '12345'); 
     Acclist.add(acc1);
     insert Acclist;   
             
     Test.startTest();
       // call batch class for merge duplicate Accounts for test
       BPCM_AccountServiceBatch obj = new BPCM_AccountServiceBatch(Acclist);
       DataBase.executeBatch(obj, 1);
             
     Test.stopTest();
     // Check List of Account Record creeated
     system.assertEquals(1, Acclist.size(), 'List of account') ; 
  }

}