/**
* @author           Utkarsh  Gupta
* @date             02/07/2019
* @group            ICRM
* @description      handles Account triggers for ICRM project
* 
* History
* 17/07/2019       Edited     Utkarsh Gupta
*  @ ------------ Changed by ---
*  @author      Karishma Gurjar      
*  @date         06 Dec 2019      
*  @description Cover "updateGovernmentOnContact" method of base class which was created as part of PBI 683271
*/
@istest
public with Sharing class ICRM_TestAccountTrigger {
    
    /**
* @description - test setup method for creating test data
* @acclist  - newly created records for test
*/
    @testSetup static void testdataSetup() { 
        List<Account> accList = new List<Account>();
        Account acctPros = new Account();
        string recTypeidPros = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acctPros.RecordTypeId = recTypeidPros;
        acctPros.Name = 'Test Account';
        //      acctPros.ICRM_Prospect_ID__c = '1234' ;
        acctPros.BillingCity = 'Singapore'; 
        
        acctPros.BPI_Government_Owned__c = False; 
        insert acctPros;
        
    }
    
    /**
* @description - To test the merge functionality for inserted the Legal Entity accounts from ICOS integration.
*/
    
    @istest
    public static void testTriggerMergeInsert(){
        
        Test.startTest();      
        Account accPros = new Account();
        accPros = [SELECT id, name,ICRM_Prospect_ID__c, BillingCity FROM account WHERE RecordType.Name ='IST Prospect' AND BillingCity = 'Singapore' limit 1];
        Account accLE = new Account();
        string recTypeidLE = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        accLE.RecordTypeId = recTypeidLE;
        accLE.Name = 'Legal Entity Account';
        accLE.ICRM_Prospect_ID__c = accPros.ICRM_Prospect_ID__c;        
        insert accLE;       
        Test.stopTest();
        
        List<Account> accProspectList = new List<Account>();
        accProspectList = [SELECT id, name, ICRM_Prospect_ID__c, BillingCity FROM account WHERE RecordType.Name ='IST Prospect' AND BillingCity = 'Singapore' limit 1];
        
        System.assertEquals(accProspectList.size(), 0 ,'The Account is deleted');
        
    }
    /**
* @description - To test the Updation of Government Owned field on Contact when Account is Updated.
*/
    @istest
    public static void testTriggerGovernmentCheck(){
        
        Test.startTest();      
        Account accPros = new Account();
        accPros = [SELECT id, name,ICRM_Prospect_ID__c, BillingCity FROM account WHERE RecordType.Name ='IST Prospect' AND BillingCity = 'Singapore' AND BPI_Government_Owned__c= False limit 1];
        Contact Con = new Contact();
        string recTypeidContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        Con.RecordTypeId = recTypeidContact;
        Con.FirstName = 'Test';
        Con.LastName = 'Contact1';
        Con.AccountId = accPros.id;        
        insert Con;  
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        accPros.BPI_Government_Owned__c=True;
        Update accPros;
        Test.stopTest();
        
        Contact updatedContact = [SELECT id, name, ICRM_Government_Owned__c FROM Contact WHERE RecordType.Name ='IST Contact' AND Name = 'Test Contact1' limit 1];
        
        System.assertEquals(updatedContact.ICRM_Government_Owned__c, True ,'Contact is updated when Account is Updated with Governemnt Owned checked/unchecked');
        
    }
    
}