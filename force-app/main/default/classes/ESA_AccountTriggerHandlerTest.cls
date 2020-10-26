/*Description : This Apex Test class is for ESA_AccountTriggerHandler Apex Class.
*Project      : ESA Fuels
*Copyright    : Tata Consultancy Services Ltd
*Last Modified Date : 8/8/20
*/


@isTest
public class ESA_AccountTriggerHandlerTest {
    // The test class to cover the handleBeforeinsertUpdate methods in the ESA_AccountTriggerHandler class
    static testmethod void handleBeforeInsertUpdateTest(){
        //the test method to cover HTTP callout
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        Test.startTest();
        List<OLCM_Http_Request__c> reqdat=new List<OLCM_Http_Request__c>();
        OLCM_Http_Request__c cm=new OLCM_Http_Request__c(name='satyam',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgjh@34',OLCM_Client_Secret__c='kjgk@45');
        reqdat.add(cm);
        insert reqdat;
        list<account> listAccount=[select Id,OLCM_Sales_Area__c,OLCM_Fuels_Customers__c,OLCM_Fuels_Card_Customers__c,OLCM_Sales_Division_Description__c,OLCM_Distribution_Channel_Description__c,OLCM_Sales_Organisation_Description__c from Account where OLCM_Sales_Organisation_Description__c='LU0A' OR
                                   OLCM_Sales_Organisation_Description__c='BE01'];
        ESA_AccountTriggerHandler.handlerBeforeInsert(listAccount);
        OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(listAccount);
        Test.stopTest();
    }
    static testmethod void handleBeforeInsertUpdateTest1(){
        //the test method to cover handlebeforeinsert method for Sales organisation and non-empty BillingCountry and BillingPostalCode
        list<Account> listAccount=new list<Account>();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Account Account1 = new Account();
        Account1.Name = 'testname1';
        Account1.ESA_Business_Unit__c='ESA_B2B_Fuels';
        Account1.ESA_Sales_Organisation__c='ESA_DE01/05/01';
        Account1.ESA_Relationship_Type__c='ESA_Customer';
        Account1.ESA_Trade_Registry_No__c='345';
        Account1.RecordTypeId = accountRecordTypeId;
        Account1.BillingPostalCode ='411057';
        Account1.BillingCountry='INDIA';
        listAccount.add(Account1);
        
        insert listAccount;   
        
        Test.startTest();
        ESA_AccountTriggerHandler.handlerBeforeInsert(listAccount);
        OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(listAccount);
        System.assertEquals('01',listAccount[0].OLCM_Sales_Division_Description__c );
        System.assertNotEquals(null, listAccount[0].BillingPostalCode);
        Test.stopTest();
    }
    
    static testmethod void handleBeforeInsertUpdateTest2(){
        //to cover the error while inserting null billing postal code or billing country
        
        list<Account> listAccount2=new list<Account>();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Account Account2 = new Account();
        Account2.Name = 'testname2';
        Account2.ESA_Business_Unit__c='ESA_B2B_Fuels';
        Account2.ESA_Sales_Organisation__c='ESA_DE01/05/01';
        Account2.ESA_Relationship_Type__c='ESA_Customer';
        Account2.ESA_Trade_Registry_No__c='344';
        Account2.RecordTypeId = accountRecordTypeId;
        Account2.BillingPostalCode =' ';
        Account2.BillingCountry='INDIA ';
        listAccount2.add(Account2);
        
        Account Account3 = new Account();
        Account3.Name = 'testname3';
        Account3.ESA_Business_Unit__c='ESA_B2B_Fuels';
        Account3.ESA_Sales_Organisation__c='ESA_DE01/05/01';
        Account3.ESA_Relationship_Type__c='ESA_Customer';
        Account3.ESA_Trade_Registry_No__c='340';
        Account3.RecordTypeId = accountRecordTypeId;
        Account3.BillingPostalCode ='411057';
        Account3.BillingCountry=' ';
        listAccount2.add(Account3);
        
        Test.startTest();
        try {
            //for error handling
            insert listAccount2;
            ESA_AccountTriggerHandler.handlerBeforeInsert(listAccount2);            
            OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(listAccount2);
        }
        catch(Exception ex) {
            //to catch the exception that is error message
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Please provide value in postal code') ? true : false;
            System.assertEquals(expectedExceptionThrown, true); 
        }
        Test.stopTest(); 
        
    }
    
    /*static testmethod void handleBeforeInsertUpdateTest3(){
        //method to check the current user Profile
        Profile p = [select Id from profile where Name=:'ESA BP Base'];
        User uu=new User(firstname = 'accounttrigger',
                         lastName = 'Testuser',
                         email =  'triggertestuser@bp.com',
                         Username = 'triggertestuser@bp.com',
                         Alias = 'ABC',
                         TimeZoneSidKey = 'America/Los_Angeles',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'UTF-8',
                         LanguageLocaleKey = 'en_US',
                         ProfileId = p.Id
                         
                        );
        insert uu;
        system.runAs(uu){
            Test.startTest();
            ESA_AccountTriggerHandler.getESAProfilename(); 
            System.assertEquals(True, ESA_AccountTriggerHandler.getESAProfilename());
        }       
        Test.stopTest();
    }*/
    
    
    /*static testmethod void handleBeforeInsertUpdateTest4(){
        //method to check if olcm user craetes a ESA related Vendor record      
        list<Account> listAccount4=new list<Account>();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Account Account2 = new Account();
        Account2.Name = 'testname4';
        Account2.RecordTypeId = accountRecordTypeId;
        Account2.BillingPostalCode ='411057';
        Account2.BillingCountry='INDIA ';
        Account2.ESA_Relationship_Type__c = 'ESA_Vendor';
        Account2.Marked_for_Deletion__c=false;
        Account2.OLCM_Sales_Organisation_Description__c ='DE01';
        Account2.OLCM_Sales_Division_Description__c = '01';
        Account2.OLCM_Distribution_Channel_Description__c='01';
        Account2.OLCM_Unique_identifier__c = 'ptc01';
        Account2.OLCM_Total_Forecast_Sales__c = 78;
        Account2.OLCM_Invoice_Frequency_Number__c = '1'; 
        Account2.OLCM_Payment_Term_Number__c = '15'; 
        Account2.OLCM_Additional_Days_Number__c ='5';    
        Account2.OLCM_Credit_Request_Send__c = false;
        listAccount4.add(Account2);
        Test.startTest();
        insert listAccount4;
        ESA_AccountTriggerHandler.populateESAsalesOrg(listAccount4);        
        OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(listAccount4);
        System.assertEquals('01', listAccount4[0].OLCM_Sales_Division_Description__c);
        Test.stopTest(); 
        
        
    }*/
}