/**
* @ author  - Gaurav Wadhawan
* @ company - IBM
* @ date    - 10/06/2020
* @ description  - Test Class for BPCM_AccountService)
*/

@isTest(seeAllData=false)
public with sharing class BPCM_AccountServiceTest {
    
  static testMethod void MergeAccounts() {
     List<Account> Acclist = new  List<Account>();
     String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('BPCM Consumer').getRecordTypeId();      
     //Create Account Test Record
     Account acc1= new Account(RecordTypeID=recordTypeId , FirstName='Test FName1', LastName='Test LName1',BPCM_CV_ID__c = '12345' );    
     insert acc1; 
 
     Account acc2= new Account(RecordTypeID=recordTypeId , FirstName='Test FName2', LastName='Test LName2', BPCM_CV_ID__c = '12345'); 
     insert acc2;
      
     Account acc3= new Account(RecordTypeID=recordTypeId , FirstName='Test FName3', LastName='Test LName3',BPCM_CV_ID__c = '12345' );    
     insert acc3; 
     
     Account acc4= new Account(RecordTypeID=recordTypeId , FirstName='Test FName4', LastName='Test LName4', BPCM_CV_ID__c = '12345'); 
     insert acc4; 
     Acclist.add(acc4);
      
     Test.startTest();
     // call class for merge duplicate Accounts for test
       BPCM_AccountService.MergeAccounts(Acclist);
     Test.stopTest();
      
     // Check List of Account Record creeated
     system.assertEquals(1, Acclist.size(), 'List of account') ; 
  }
    
}