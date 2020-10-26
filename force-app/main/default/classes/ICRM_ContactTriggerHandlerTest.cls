/**
* @author     Karishma Gurjar
* @date       06/12/2019
* @description    Test class for ICRM_ContactTriggerHandler class  
*  @ -----------------------------------
*/
@isTest(SeeAllData=False)
public without sharing class ICRM_ContactTriggerHandlerTest {
    
    @testSetup static void testdataSetup() { 
        
        Account acctPros = new Account();
        string recTypeidPros = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acctPros.RecordTypeId = recTypeidPros;
        acctPros.Name = 'Test Account Prospect'; 
        acctPros.BPI_Government_Owned__c = True; 
        insert acctPros;
        Account acct1 = new Account();
        acct1.RecordTypeId = recTypeidPros;
        acct1.Name = 'Test Account'; 
        acct1.BPI_Government_Owned__c = False; 
        insert acct1;
        
        
    }
    /**
* @description - To test the Updation of Government Owned field on Contact when Contact is created on a Government Owned Account.
*/
    @istest
    public static void testTriggerGovernmentCheckOnInsert(){
        
        Test.startTest();      
        Account accPros = new Account();
        accPros = [SELECT id, name,BPI_Government_Owned__c FROM account WHERE RecordType.Name ='IST Prospect' AND NAME= 'Test Account Prospect' AND BPI_Government_Owned__c= True limit 1];
        Contact Con = new Contact();
        string recTypeidContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        Con.RecordTypeId = recTypeidContact;
        Con.FirstName = 'Test';
        Con.LastName = 'Contact1';
        Con.AccountId = accPros.id;        
        insert Con;  
        //accPros.BPI_Government_Owned__c=True;
        //Update accPros;
        Test.stopTest();
        
        Contact updatedContact = [SELECT id, name, ICRM_Government_Owned__c FROM Contact WHERE RecordType.Name ='IST Contact' AND Name = 'Test Contact1' limit 1];
        
        System.assertEquals(updatedContact.ICRM_Government_Owned__c, True ,'When Account is Government Owned then COntact must be Governemt Owned');
        
    }
    
    /**
* @description - To Test when Contact is updated with Government/Non-Government Account then Government flag should be checked on Contact Accordingly
*/
    @istest
    public static void testTriggerGovernmentCheckOnUpdate(){
        
        Test.startTest();      
        Account accPros = new Account();
        accPros = [SELECT id, name,BPI_Government_Owned__c FROM account WHERE RecordType.Name ='IST Prospect' AND NAME= 'Test Account Prospect' AND BPI_Government_Owned__c= True limit 1];
        Contact Con = new Contact();
        string recTypeidContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        Con.RecordTypeId = recTypeidContact;
        Con.FirstName = 'Test';
        Con.LastName = 'Contact1';
        Con.AccountId = accPros.id;        
        insert Con;  
        Account acc1 = new Account();
        acc1 = [SELECT id, name,BPI_Government_Owned__c FROM account WHERE RecordType.Name ='IST Prospect' AND NAME= 'Test Account' AND BPI_Government_Owned__c= False limit 1];
        Con.AccountId = acc1.id;
        update Con;
        Test.stopTest();
        
        Contact updatedContact = [SELECT id, name, ICRM_Government_Owned__c FROM Contact WHERE RecordType.Name ='IST Contact' AND Name = 'Test Contact1' limit 1];
        
        System.assertEquals(updatedContact.ICRM_Government_Owned__c, False ,'When Account that a Contact is associated changes,then Contact Government field is updated as per the new Account Government Owned field');
        
    }
    
    
}