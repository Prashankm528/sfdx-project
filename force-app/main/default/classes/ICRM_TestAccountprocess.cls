/**
* @author           Santosh Verma
* @date             27/01/2020
* @group            ICRM
* @description      Handles Account's process builder code coverage for ICRM project
* 
* History
*  
*  @ ------------ Changed by ---
*  @author      
*  @date          
*  @description  
*/
@istest
public with Sharing class ICRM_TestAccountprocess {
    
    /**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() { 
  /*  test */ 
    }
    
    /**
* @description - To test the merge functionality for inserted the Legal Entity accounts from ICOS integration.
*/
    
    @istest
    public static void testTriggerMergeInsert22(){
        /* test process builder */ 
 //---------------PB 1st Condition------------------------------------------------
            Test.startTest();      
        Account accLE = new Account();
        string recTypeidLE = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        accLE.RecordTypeId = recTypeidLE;
        accLE.BillingCity = 'Singapore';
        accLE.Name = 'Legal Entity Account';
        accLE.bpi_business_party_role__c = 'Agent' ;  
        accLE.ICRM_Account_Visible__c = false  ;  
		accLE.ICRM_Prospect_ID__c = '129999';        
        Insert accLE;       
        Test.stopTest();
    //------------------------PB 2nd Condition---------------------------------------   
        account SanAcc = new account();
        account SanAcc1 = new account();
        SanAcc = [SELECT id, name,bpi_business_party_role__c,ICRM_Account_Visible__c, ICRM_Prospect_ID__c, BillingCity FROM account WHERE RecordType.Name ='IST Legal Entity' AND BillingCity = 'Singapore' limit 1];
        system.debug('santosh test 1 = ' + SanAcc.ICRM_Account_Visible__c);
        system.assertEquals(True, SanAcc.ICRM_Account_Visible__c);
        SanAcc.bpi_business_party_role__c = 'A3ge2' ; // Santosh 
        update SanAcc ;
        SanAcc1 = [SELECT id, name,bpi_business_party_role__c,ICRM_Account_Visible__c, ICRM_Prospect_ID__c, BillingCity FROM account WHERE RecordType.Name ='IST Legal Entity' AND BillingCity = 'Singapore' limit 1];
        system.debug('santosh test 2 = ' + SanAcc1.ICRM_Account_Visible__c);
        system.assertEquals(false, SanAcc1.ICRM_Account_Visible__c);
    }
}