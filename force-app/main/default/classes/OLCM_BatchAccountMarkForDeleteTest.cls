/**
* @author Satyam
* @company Tata Consultancy Services
* @date 
* @group Fuels
* @description      Test class for OLCM_BatchAccountMarkForDelete
*/
@isTest
public with sharing class OLCM_BatchAccountMarkForDeleteTest {
    
    /***********************************************************************************
* Test Method
*--------------
***********************************************************************************/ 
    
    static testmethod void test_AccountMarkForDelete(){
        
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        Account aclist;
        Test.startTest();
        
        Account sa=new Account(name='satyam',BillingCity='Amritsar',Billingcountry='India',BillingPostalCode='143001',OLCM_Sales_Division_Description__c='01',OLCM_Distribution_Channel_Description__c='05',Marked_for_Deletion__c=false,Sales_Organisation__c='DAVG');
        insert sa;
        
        aclist=[SELECT Id,OLCM_Fuels_Card_Customers__c,OLCM_Last_Modified_Greater_than_60_Days__c,
                Marked_for_Deletion__c FROM Account where id=:sa.id];
        
        List<OLCM_Http_Request__c> reqdat=new List<OLCM_Http_Request__c>();
        OLCM_Http_Request__c cm=new OLCM_Http_Request__c(name='satyam',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgjh@34',OLCM_Client_Secret__c='kjgk@45');
        reqdat.add(cm);
        insert reqdat;
        OLCM_BatchAccountMarkForDelete batchJob = new OLCM_BatchAccountMarkForDelete();
        
        database.executeBatch(batchJob);
        Test.stopTest();
        system.assertEquals(true, aclist.OLCM_Fuels_Card_Customers__c, 'Formula field ');
        
    }    
}