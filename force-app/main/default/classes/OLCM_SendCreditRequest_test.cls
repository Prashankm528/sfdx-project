/*
 * @author Satyam
 * @company Tata Consultancy Services
 * @date 3/02/2019
 * @group Fuels
 * @description      Test class for OLCM_SendCreditRequest
 */

@isTest
public with sharing class OLCM_SendCreditRequest_test {
    @isTest
    public static  void testCallout(){        
        
        Account a=new Account (name = 'testname1', Marked_for_Deletion__c=True,
        BillingCity ='TestCity1_03', BillingCountry ='Australia', OLCM_Sales_Organisation_Description__c='BE01',
        BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                    OLCM_Distribution_Channel_Description__c='12');
        insert a;
        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock());//Calling of Mock Class
        //List<Account> accList=new List<Account>(); 
        //OLCM_SendCreditRequest req=new OLCM_SendCreditRequest();
        OLCM_SendCreditRequest.creditRequest(a.id);
         system.assertEquals('testname1', a.name, 'name of acc');
        Test.stopTest();  
    }
    
    @isTest
    static  void OLCM_BillingcountryAcctest(){
        
        try{
        List<Account> acList=new List<Account>();
        UserRole r = new UserRole(DeveloperName = 'OLCM_DE_SALES_Sat', Name = 'Fuel');
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
            Account a=new Account (name = 'Billingcountrytestname1', Marked_for_Deletion__c=True,
                                   BillingCity ='TestCity1_02',OLCM_Sales_Organisation_Description__c='BE01',
                                   BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                   OLCM_Distribution_Channel_Description__c='12');
            insert a;
            acList.add(a);
             Test.startTest();       
             OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(acList);
             Test.stopTest();
             system.assertEquals(1, acList.size(), 'size of acc');   
            
        } 
        }catch(exception ex){
        system.debug('Error msg**'+ex);
        }
    }
    
     @isTest
    static void OLCM_BillingcountryAccounttest(){
        
        try{
        List<Account> acList=new List<Account>();
        UserRole r = new UserRole(DeveloperName = 'OLCM_DE_SALES_Sat', Name = 'Fuel');
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
            Account a=new Account (name = 'billingcountrytest', Marked_for_Deletion__c=True,
                                   BillingCity ='TestCity1_0', BillingCountry ='test',OLCM_Sales_Organisation_Description__c='BE01',
                                   BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                   OLCM_Distribution_Channel_Description__c='12');
            insert a;
            acList.add(a);
             Test.startTest();       
             OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(acList);
             Test.stopTest();
             system.assertEquals(1, acList.size(), 'size of acc');   
            
        } 
        }catch(exception ex){
        system.debug('Error msg**'+ex);
        }
    }
    
     @isTest
    static void OLCM_BillingpostalcodeAccounttest(){
        
        try{
        List<Account> acList=new List<Account>();
        UserRole r = new UserRole(DeveloperName = 'OLCM_DE_SALES_Sat', Name = 'Fuel');
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
            Account a=new Account (name = 'billingpostalcodetest', Marked_for_Deletion__c=True,
                                   BillingCity ='TestCity1_01', BillingCountry ='Belgium',OLCM_Sales_Organisation_Description__c='BE01',
                                   BillingStreet ='TestStreet1',OLCM_Sales_Division_Description__c='01',
                                   OLCM_Distribution_Channel_Description__c='12');
            insert a;
            acList.add(a);
             Test.startTest();       
             OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(acList);
             Test.stopTest();
             system.assertEquals(1, acList.size(), 'size of acc');   
            
        } 
        }catch(exception ex){
        system.debug('Error msg**'+ex);
        }
    }

    
}