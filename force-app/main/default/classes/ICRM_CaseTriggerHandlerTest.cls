/**
* @author     Palash Awasthi
* @date       01/08/2019
* @description    Test class for ICRM_CaseTriggerHandler class  
* 
* History
*  
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_CaseTriggerHandlerTest {
    
    /**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() {
        
        List<Contact> conList = new List<Contact>();
        Account acc = new Account();
        string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = recTypeid;
        acc.Name = 'Test Account for Contact';
        Insert acc;
        ID recId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        Contact con1 = new Contact(LastName = 'Sreelatha', FirstName = 'SK', Email = 'sreelatha.sk@bp.com', RecordTypeId = recId, AccountId = acc.Id);
        conList.add(con1);
        insert conList;
    }
    

    @istest
        /**
* @description - test trigger
*/
    public static void testTrigger(){
        //Start of method
        
        Integer i1 = 0;
        ID recId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        Test.startTest(); 
       i1 = i1+ executescenario(true,recid);
        i1= i1 + executescenario(false,recid);
        System.assertEquals(i1,2,'One or more scenarios had uncaught exception');
        Test.stopTest(); 
        
    }
        /**
* Logic for validation of contact creation
*/
    public static Integer executescenario(Boolean internalform,ID recid)
    {
        Case c = new Case();
        c.RecordTypeId = recId;
        c.Type = 'Admin';
        if(internalform)
        {
            c.Origin = 'Internal Form';
            c.SuppliedEmail = 'test.test1@bp.com';
            c.TKT_Customer_Email_Address__c = 'sreelatha.sk@bp.com';
        } 
        else
        {
            c.Origin = 'New Customer Form';
            c.SuppliedEmail = 'sreelatha.sk@bp.com';
            c.TKT_Last_Name__c = 'Sreelatha';
        }
        
        Insert c;
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        Contact con;
        if(internalform)
        {
            con  = [SELECT Id FROM Contact WHERE Email =:c.TKT_Customer_Email_Address__c];
        }
        else
        {
            con  = [SELECT Id FROM Contact WHERE Email =:c.SuppliedEmail and  LastName=:c.TKT_Last_Name__c];
        }
        Case cas;
        if(internalform)
        {
            cas = [SELECT ContactId FROM Case WHERE TKT_Customer_Email_Address__c =:c.TKT_Customer_Email_Address__c];
        }
        else
        {
            cas = [SELECT ContactId FROM Case WHERE SuppliedEmail =:c.SuppliedEmail AND TKT_Last_Name__c =:c.TKT_Last_Name__c];
        }
        
        System.assertEquals(con.Id, cas.ContactId, 'Test Class fail');
      
            return 1;

       
    }
  
}