/*****************************************************************************************
*   Date:     10/05/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_SendEmailOnCaseCreated_Updated
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestSendEmailOnCaseCreated_Updated 
{
     //test data create
     @testSetup static void setup() {
         	 Profile prof = [SELECT Id FROM profile WHERE name LIKE '%PCRM BP Base%'];
             User user = new User();
             user.firstName = 'FirstName';
             user.lastName = 'LastName';
             user.profileId = prof.id;
             user.username = 'aj770c@gmail.com.pcrmdev';
             user.email = 'test4@gmail.com';
             user.Alias = 'ab59c';
             user.TimeZoneSidKey = 'Europe/London';
             user.EmailEncodingKey = 'UTF-8';
             user.LanguageLocaleKey = 'en_US';
             user.LocaleSidKey  = 'en_GB';
             INSERT user;  
             
             Profile prof1 = [SELECT Id FROM profile WHERE name LIKE '%PCRM BP Base%'];
             User SalesManager = new User();
             SalesManager.firstName = 'FirstName1';
             SalesManager.lastName = 'LastName1';
             SalesManager.profileId = prof1.id;
             SalesManager.username = 'aj770d@gmail.com.pcrmdev';
             SalesManager.email = 'test5@gmail.com';
             SalesManager.Alias = 'ab59d';
             SalesManager.TimeZoneSidKey = 'Europe/London';
             SalesManager.EmailEncodingKey = 'UTF-8';
             SalesManager.LanguageLocaleKey = 'en_US';
             SalesManager.LocaleSidKey  = 'en_GB';
             INSERT SalesManager;
            
             Profile prof2 = [SELECT Id FROM profile WHERE name LIKE '%PCRM BP Base%'];
             User AccountCordinator = new User();
             AccountCordinator.firstName = 'FirstName2';
             AccountCordinator.lastName = 'LastName2';
             AccountCordinator.profileId = prof2.id;
             AccountCordinator.username = 'aj770e@gmail.com.pcrmdev';
             AccountCordinator.email = 'test6@gmail.com';
            
             AccountCordinator.Alias = 'ab59e';
             AccountCordinator.TimeZoneSidKey = 'Europe/London';
             AccountCordinator.EmailEncodingKey = 'UTF-8';
             AccountCordinator.LanguageLocaleKey = 'en_US';
             AccountCordinator.LocaleSidKey  = 'en_GB';
             INSERT AccountCordinator;
            
             Group HSSEGroup = new Group();
             HSSEGroup.Name = 'Test Group';
             insert HSSEGroup;
         
       		 Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
             Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PCRM_Petchem_Contact').getRecordTypeId();
             Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PCRM_Chemicals_Acetyls').getRecordTypeId();

             Account AccountObj = NEW Account();
             AccountObj.Name = 'Test 1';
             AccountObj.recordtypeId = RecordTypeIdAccount;
             INSERT AccountObj; 
            
             Contact contactObj = NEW Contact();
             contactObj.recordtypeId = RecordTypeIdContact;
             contactObj.LastName = 'Contact Name';   
             contactObj.AccountId = AccountObj.Id;
             contactObj.Email= 'test@gmail.com';
             INSERT contactObj;    
                
             Case CaseObj = NEW  Case();
             CaseObj.AccountId = AccountObj.Id;
        	 CaseObj.Subject = 'TestingCase991'; 
             CaseObj.Status= 'Open';  
             CaseObj.recordtypeId = RecordTypeIdCase;
             CaseObj.PCRM_Potential_Severity__c = 'A';   
             //CaseObj.GCM_Date_Time_Incident__c = Date.Today() - 1;
             CaseObj.PCRM_Investigator__c= user.Id;
             CaseObj.Area__c= 'Driver';
             CaseObj.Sub_Area__c = 'Driving';  
             CaseObj.PCRM_Reported_By__c= AccountObj.Id;
             CaseObj.PCRM_Responsible_Party__c= AccountObj.Id ;
             CaseObj.Description= 'Description';
             CaseObj.PCRM_Sales_Manager__c = SalesManager.Id;
             CaseObj.PCRM_Account_Coordinator__c = AccountCordinator.Id;
             CaseObj.OwnerId = user.Id;             
                
             INSERT  CaseObj;       
    }
    //Method is created to cover case 'Create' condition
    static testMethod void testCoverCreateCondition() 
    {
        Test.startTest();
       		 List<Case>  CaseObj = [SELECT Id,Subject FROM Case WHERE Subject='TestingCase991' ];           
        	//to makesure test class is cover, need to call invocable class directly, which in this scenario I need to instantiate
             // inner class    
             List<PCRM_SendEmailOnCaseCreated_Updated.CaseRequest> listRequest =new List<PCRM_SendEmailOnCaseCreated_Updated.CaseRequest>();
            
             PCRM_SendEmailOnCaseCreated_Updated.CaseRequest req  = new PCRM_SendEmailOnCaseCreated_Updated.CaseRequest();
             req.CaseId= CaseObj[0].Id;
             req.Action='Create';
             listRequest.add(req); 
        
             //the call the method directly -when case is updated
             PCRM_SendEmailOnCaseCreated_Updated.SetupCase(listRequest); 
        	 system.assertEquals(1,CaseObj.size() );
        Test.stopTest();
    }
    
    //Method is created to cover case 'Update' condition
    static testMethod void testCoverUpdateCondition() 
    {
        Test.startTest();
            List<Case>  CaseObj= [SELECT Id,Subject FROM Case WHERE Subject='TestingCase991' LIMIT 1];
        	//to makesure test class is cover, need to call invocable class directly, which in this scenario I need to instantiate
             // inner class    
             List<PCRM_SendEmailOnCaseCreated_Updated.CaseRequest> listRequest =new List<PCRM_SendEmailOnCaseCreated_Updated.CaseRequest>();
            
             PCRM_SendEmailOnCaseCreated_Updated.CaseRequest req  = new PCRM_SendEmailOnCaseCreated_Updated.CaseRequest();
             req.CaseId= CaseObj[0].Id;
             req.Action='Update';
             listRequest.add(req); 
        
             //the call the method directly -when case is updated
             PCRM_SendEmailOnCaseCreated_Updated.SetupCase(listRequest); 
       		 system.assertEquals(1,CaseObj.size() );
        Test.stopTest();
    }
    
     //Method is created to cover case 'Close' condition
    static testMethod void testCoverCloseCondition() 
    {
        Test.startTest();
            List<Case>  CaseObj = [SELECT Id,Subject FROM Case WHERE Subject='TestingCase991' ];
        	//to makesure test class is cover, need to call invocable class directly, which in this scenario I need to instantiate
             // inner class    
             List<PCRM_SendEmailOnCaseCreated_Updated.CaseRequest> listRequest =new List<PCRM_SendEmailOnCaseCreated_Updated.CaseRequest>();
            
             PCRM_SendEmailOnCaseCreated_Updated.CaseRequest req  = new PCRM_SendEmailOnCaseCreated_Updated.CaseRequest();
             req.CaseId= CaseObj[0].Id;
             req.Action='Close';
             listRequest.add(req); 
        
             //the call the method directly -when case is updated
             PCRM_SendEmailOnCaseCreated_Updated.SetupCase(listRequest); 
        	system.assertEquals(1,CaseObj.size() );
        Test.stopTest();
    }
}