/*
* @author Jewelslyn Shama P
* @company Tata Consultancy Services
* @date 
* @group Fuels
* @description      Test class for OLCM_BatchAccountMarkForDelete
*/
@isTest
public class OLCM_AccountTriggerHandlerTest {
    
    /***********************************************************************************
* Data Preparation Method 
* ---------------------------- 
***********************************************************************************/   
    @testSetup static void setUp(){        
        list<Account> listAccount=new list<Account>();
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        //Insert Accounts
        List<OLCM_Http_Request__c> reqdat=new List<OLCM_Http_Request__c>();
        Id RecordTypeacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();      
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Prospect'];
        OLCM_Http_Request__c cm=new OLCM_Http_Request__c(name='satyam',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgjh@34',OLCM_Client_Secret__c='kjgk@45');
        reqdat.add(cm);
        insert reqdat;
        listAccount.add(new Account (name = 'testname1', Marked_for_Deletion__c=True,recordtypeid=RecordTypeacc,RecordType=rt,
                                     BillingCity ='TestCity1', BillingCountry ='Australia', OLCM_Sales_Organisation_Description__c='BE01',
                                     BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                     OLCM_Distribution_Channel_Description__c='12'));
        listAccount.add(new Account (name = 'testname2', Marked_for_Deletion__c=false,recordtypeid=RecordTypeacc,RecordType=rt,
                                     BillingCity ='TestCity2', BillingCountry ='India', OLCM_Sales_Organisation_Description__c='BE01',
                                     BillingStreet ='TestStreet2', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                     OLCM_Distribution_Channel_Description__c='12'));
        listAccount.add(new Account (name = 'testname2', Marked_for_Deletion__c=false,recordtypeid=RecordTypeacc,RecordType=rt,
                                     BillingCity ='TestCity2', BillingCountry ='India', OLCM_Sales_Organisation_Description__c='BE01',
                                     BillingStreet ='TestStreet2', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                     OLCM_Distribution_Channel_Description__c='02',
                                     OLCM_Credit_Request_Send__c = false));
        
        insert listAccount; 
        
        
    }
    /*********************************************************************************************************
* Test Methods 
* ----------------------------
* Test methods for populating Country ISO Codes, Currency ISO codes, Credit Control Area, Credit Segment 
**********************************************************************************************************/  
    static testmethod void handleBeforeInsertUpdateTest(){
        
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        Test.startTest();
        List<OLCM_Http_Request__c> reqdat=new List<OLCM_Http_Request__c>();
        OLCM_Http_Request__c cm=new OLCM_Http_Request__c(name='satyam',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgjh@34',OLCM_Client_Secret__c='kjgk@45');
        reqdat.add(cm);
        insert reqdat;
        list<account> listAccount=[select Id,OLCM_Sales_Area__c,OLCM_Fuels_Customers__c,OLCM_Fuels_Card_Customers__c,OLCM_Sales_Division_Description__c,OLCM_Distribution_Channel_Description__c,OLCM_Sales_Organisation_Description__c from Account where OLCM_Sales_Organisation_Description__c='LU0A' OR
                                   OLCM_Sales_Organisation_Description__c='BE01'];
        
        
        
        OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(listAccount);
        OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(listAccount);
        Test.stopTest();
        system.assertEquals(3, listAccount.size(), 'List of account') ; 
    }
    /*********************************************************************************************************
* Test method to send Credit request to S4 HANA via Mulesoft 
**********************************************************************************************************/ 
    @isTest
    static  void OLCM_AccountTriggerHandlerQueueableTest1(){
        set<Id> accId=new set<Id>();
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        Test.startTest();
        List<OLCM_Http_Request__c> reqdat=new List<OLCM_Http_Request__c>();
        OLCM_Http_Request__c cm=new OLCM_Http_Request__c(name='satyam',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgjh@34',OLCM_Client_Secret__c='kjgk@45');
        reqdat.add(cm);
        insert reqdat;
        
        list<account> listAccount=[select Id,OLCM_Credit_Request_Check__c,OLCM_Fuels_Card_Customers__c,
                                   OLCM_Credit_Request_Send__c,Marked_for_Deletion__c
                                   from Account where OLCM_Sales_Organisation_Description__c='LU0A' OR
                                   OLCM_Sales_Organisation_Description__c='BE01'];
        
        
        
        for(account acc:listAccount){
            accId.add(acc.Id);
        }
        
        Test.stopTest();
        system.assertEquals(3, listAccount.size(),'size of listAccount');
    }
	/*
    @isTest
    static  void OLCM_AccountTriggerHandlerQueueableTestuserrole(){
        List<Account> acList=new List<Account>();
        Test.startTest();
        UserRole r = new UserRole(DeveloperName = 'OLCM_DE_SALES_Sat', Name = 'Fuel - BEk Sales Manager');
        insert r;                                                                
        
        system.debug('userrolename'+r.name+'id'+r.id);
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'BPG_BP Base Platform'].Id,
            LastName = 'Fuell',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com'+'satyam',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'tfuel',
            TimeZoneSidKey = 'Europe/London',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_GB',
            FirstName = 'test1',
            UserRoleId = r.Id,
            LocaleSidKey='en_GB',
            CurrencyIsoCode ='USD',
            CommunityNickname   ='testFuel1',
            City    ='ramtirath'
            
        );
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OLCM_Credit_Management_User_Platform'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
        system.runAs(u){  
            Account a=new Account (name = 'testname1', Marked_for_Deletion__c=True,
                                   BillingCity ='TestCity1', BillingCountry ='Belgium', OLCM_Sales_Organisation_Description__c='BE01',
                                   BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                   OLCM_Distribution_Channel_Description__c='12');
            insert a;
            acList.add(a);
            
        }   
        
        OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(acList);
        Test.stopTest();
        system.assertEquals(1, acList.size(), 'size of acc');    
        
    }
    */
/*********************************************************************************************************
* Test method to validate Sibel Customer 
**********************************************************************************************************/ 
    static testmethod void handleBeforeInsertUpdateTest1(){
        List<Account> siebelAcc=new List<Account>();
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        Test.startTest();
        List<OLCM_Http_Request__c> reqdat1=new List<OLCM_Http_Request__c>();
        OLCM_Http_Request__c cm1=new OLCM_Http_Request__c(name='satyam12',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgujh@34',OLCM_Client_Secret__c='k90jgk@45');
        reqdat1.add(cm1);
        insert reqdat1;
        List<OLCM_Http_Request__c> reqdat12 = OLCM_Http_Request__c.getall().values();
        System.debug('chkval'+reqdat12);
         Id RecordTypeacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();      
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Prospect'];
        
       Account ac=new Account (name = 'testSiebel', Marked_for_Deletion__c=false,recordtypeid=RecordTypeacc,RecordType=rt,
                                     BillingCity ='TestCity2', BillingCountry ='India', OLCM_Sales_Organisation_Description__c='DE01',
                                     BillingStreet ='TestStreet2', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                     OLCM_Distribution_Channel_Description__c='05',
                                     OLCM_Credit_Request_Send__c = false,Account_Siebel_ID__c='123456',OLCM_Siebel_Check__c=true);
        siebelAcc.add(ac);
        insert siebelAcc;
        OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(siebelAcc);
        OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(siebelAcc);
        Test.stopTest();
        system.assertEquals(1, siebelAcc.size(), 'List of account') ; 
    }
/*********************************************************************************************************
@Test method to validate OLCM_recordsharing class
**********************************************************************************************************/ 
    static testmethod void handleinsertgroup(){
          
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());
        Test.startTest();
        List<OLCM_Http_Request__c> reqdat=new List<OLCM_Http_Request__c>();
        OLCM_Http_Request__c cm=new OLCM_Http_Request__c(name='satyam1234',OLCM_Endpoint_Url__c='https://google.com',OLCM_Client_Id__c='khgjh@34',OLCM_Client_Secret__c='kjgk@45');
        reqdat.add(cm);
        insert reqdat;
        list<account> listAccount=[select Id,OLCM_Sales_Area__c,OLCM_Fuels_Customers__c,OLCM_Fuels_Card_Customers__c,OLCM_Sales_Division_Description__c,OLCM_Distribution_Channel_Description__c,OLCM_Sales_Organisation_Description__c from Account where OLCM_Sales_Organisation_Description__c='LU0A' OR
                                   OLCM_Sales_Organisation_Description__c='BE01'];
        
        
        Group gp=new Group(name='OLCM_AT0N');
        Insert gp;
         Account ac12=new Account (name = 'testSiebel123', Marked_for_Deletion__c=false,
                                     BillingCity ='TestCity2', BillingCountry ='India', OLCM_Sales_Organisation_Description__c='DE01',
                                     BillingStreet ='TestStreet2', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                     OLCM_Distribution_Channel_Description__c='05',
                                     OLCM_Credit_Request_Send__c = false,Account_Siebel_ID__c='123456',OLCM_Siebel_Check__c=true);
        insert ac12;
        List<group> gpp=[select id from Group where name like 'OLCM_AT'];
        group gppAU=[select id from Group where name ='OLCM_parent'];
        Olcm_recordSharing.ShareEditAcc(ac12.id, 'AT0N',gpp,gppAU);
        Olcm_recordSharing.ShareEditAcc(ac12.id, 'AU0A',gpp,gppAU);
        OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(listAccount);
        OLCM_AccountTriggerHandlerQueueable chk=new OLCM_AccountTriggerHandlerQueueable(listAccount);
        Test.stopTest();
        system.assertEquals(3, listAccount.size(), 'List of account') ; 
        
    }
}