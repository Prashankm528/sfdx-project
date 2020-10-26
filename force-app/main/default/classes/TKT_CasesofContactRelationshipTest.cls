/**
* @author     Himanshu Bansal
* @date       24 Jul 2020
* @description    Test class for TKT_CasesofContactRelationship   
**/
@isTest
public with sharing class TKT_CasesofContactRelationshipTest{
    
    public testMethod static void getCaseRecordTest(){
        
        Test.startTest();
      
        Map<String,Id > profileMap = new Map<String, Id>();
        for(Profile p1: [SELECT Id,name FROM Profile WHERE Name in ('ICRM Base','System Administrator')]){
            profileMap.put(p1.name,p1.id);
        }
        User auser = new User();
        aUser.Username = 'TKTTestUserabc@test.com.customer';
        auser.lastname = 'Testing';
        auser.Email = 'standarduser@testorg.com'; 
        auser.Alias = 'standt';
        auser.EmailEncodingKey='UTF-8'; 
        auser.LanguageLocaleKey='en_US'; 
        auser.LocaleSidKey='en_US'; 
        auser.TimeZoneSidKey='America/Chicago'; 
        auser.IsActive = true;  
        auser.ProfileId = profileMap.get('ICRM Base');  

        insert auser; 
        
        System.runAs(auser){
            Account acc = new Account();
            string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
            acc.RecordTypeId = recTypeid;
            acc.Name = 'Test Account for Contact';
            Insert acc;
            
            string recId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
            Contact con = new Contact(LastName = 'Test', FirstName = 'SK', Email = 'test123@testcase.com', RecordTypeId = recId, AccountId = acc.Id);
            insert con;
            
            ICRM_Contact_Relationship__c rel = new ICRM_Contact_Relationship__c(ICRM_User_Name__c = auser.Id, ICRM_Active__c = true, ICRM_Contact__c = con.Id);
            insert rel; 
            
            Case cc =new Case();
            string recTypeCaseid = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TKT_Ticketing').getRecordTypeId();
            cc.ContactId = con.Id;
            cc.RecordTypeId = recTypeCaseid;
            cc.ownerid=auser.Id;
            cc.SuppliedEmail = 'test@testcase.com';
            cc.Origin = 'CRM';
            cc.TKT_Request_Channel__c = 'Email';
            cc.TKT_How_can_we_help_you__c= 'New User Access';
            cc.Status='New'; 
            Insert cc;
            
                   
            List<TKT_CasesofContactRelationship.CaseWrapper> caseSummary = TKT_CasesofContactRelationship.getCaseRecords();
            System.assertEquals(false,caseSummary.isEmpty() , 'Cases Found');
        
            Test.stopTest();
        }
    }
}