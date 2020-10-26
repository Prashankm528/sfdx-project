/****************************************************************************************************
 *  Date          : 15-FEB-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Case_Trigger
 * Modifications  : 
 * 15-FEB-2019    : SYAP - Initial
 * 22-MAR-2019    : SYAP - Enabled recursive calls for the test class to work.
 * 19-JUL-2019    : SYAP - Test class for default account.
 * 17-SEP-2019    : Roselin - Removed test class dependency on triggers.
 * 02-SEP-2020    : SYAP - Bypass validation of child task and case if bypass timestamp is set.
 ****************************************************************************************************/
@isTest
public with sharing class GCM_Case_Trigger_Test 
{
/****************************************************************************************************
 * Cannot Close Case When There Are Open Child Activities
 ****************************************************************************************************/   
    @isTest static void validateChildActivityNotClosed() {
        List<Case> newCaseList = new List<Case>();
        // Cases With Open Child Tasks
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Sales_Organisation__c = 'MX02';
        testAccount.Business_Unit__c = 'Fuels - Dealer';
        testAccount.Service_Experience_Level__c = 'SL Silver';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        insert testContact;
        
        // Create Case
        Case request = new Case();
        request.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        request.Type = 'Invoice Management';
        request.Area__c = 'Errors & Corrections';
        request.Sub_Area__c = 'Price';
        request.Priority = 'Test';
        request.Description = 'Test';
        request.Resolution_Code__c = 'Test';
        request.SR_Resolutions__c = 'Test';
        request.AccountId = testAccount.Id;
        request.ContactId = testContact.Id;
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        System.assert(request.Id != null, 'Case Created');
        
        // Create Open Child Task
        Task action = new Task();
        action.WhatId = request.Id;
        action.Description = 'Test';
        insert action;
        System.assert(action.Id != null, 'Child Task Created');
        
        // Set Case Status = Closed
        String errorMessage = null;
        Case requestUpdate = new Case();
        requestUpdate.Id = request.Id;
        
        requestUpdate.Status = 'Closed';
        newCaseList.add(requestUpdate);
        
        Map<Id, Case> oMap = new Map<Id, Case>();
        oMap.put(requestUpdate.Id, requestUpdate);
        Map<Id, Case> nMap = new Map<Id, Case>();
        nMap.put(requestUpdate.Id, requestUpdate);
        
        try {
            GCM_Case_Trigger_Helper.validateChildRecords(oMap, nMap, newCaseList);
            update requestUpdate;      
        }
        catch (Exception error) {
            errorMessage = error.getMessage();
        }        
        System.assert(errorMessage != null, 'Child Task Not Closed Error Message');
        
        // Bypass Validation
        Case oldRecord = [select Id, GCM_ByPassValidation_Timestamp__c from Case];
        Case newRecord = [select Id, GCM_ByPassValidation_Timestamp__c from Case];
        newRecord.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        oMap.put(oldRecord.Id, oldRecord);
        nMap.put(newRecord.Id, newRecord);
        // Command Below Should Not Throw Error
        GCM_Case_Trigger_Helper.validateChildRecords(oMap, nMap, newCaseList);
    }
    
/****************************************************************************************************
 * Cannot Close Case When There Are Open Child Cases
 ****************************************************************************************************/  
    @isTest static void validateChildCaseNotClosed() {
        List<Case> newCaseList = new List<Case>();
        // Cases With Open Child Cases
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Business_Unit__c='Test';
        testAccount.Sales_Organisation__c='Test';
        testAccount.Service_Experience_Level__c='Test';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        
        insert testContact;
        ///
        GCM_Service_Catalog__c objServiceCatalog = new GCM_Service_Catalog__c();
        objServiceCatalog.GCM_Sales_Organisation__c = 'Test';
        objServiceCatalog.GCM_Business_Unit__c = 'Test';
        objServiceCatalog.GCM_SEL__c = 'Test';
        objServiceCatalog.GCM_Related_Object__c = 'Case';
        objServiceCatalog.GCM_Active__c = true;
        objServiceCatalog.GCM_Type__c = 'Test'; 
        objServiceCatalog.GCM_Area__c = 'Test';
        objServiceCatalog.GCM_Sub_Area__c = 'Test';
        objServiceCatalog.GCM_Complaint__c = false;
        
        insert objServiceCatalog;
        
        // Create Case
        Case request = new Case();
        request.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        request.Type = 'Test';
        request.Area__c = 'Test';
        request.Sub_Area__c = 'Test';
        request.Priority = 'Test';
        request.Description = 'Test';
        request.Resolution_Code__c = 'Test';
        request.SR_Resolutions__c = 'Test';
        request.AccountId = testAccount.Id;
        request.ContactId = testContact.Id;
        request.GCM_Mailbox_Reference__c='gbssftest1@bp.com';
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        System.assert(request.Id != null, 'Case Created');
        
        // Create Open Child Task
        Case childCase = new Case();
        childCase.ParentId = request.Id;
        childCase.Type = 'Test';
        insert childCase;
        System.assert(childCase.Id != null, 'Child Case Created');
        
        string strtest= GCM_Case_Trigger_Helper.getSubstring('0-9', 8, 'Test Test');
        // Set Case Status = Closed
        String errorMessage = null;
        Case requestUpdate = new Case();
        requestUpdate.Id = request.Id;
        requestUpdate.Status = 'Closed';
        newCaseList.add(requestUpdate);

        Map<Id, Case> oMap = new Map<Id, Case>();
        oMap.put(requestUpdate.Id, requestUpdate);
        Map<Id, Case> nMap = new Map<Id, Case>();
        nMap.put(requestUpdate.Id, requestUpdate);
        
        try {
            GCM_Case_Trigger_Helper.validateChildRecords(oMap, nMap, newCaseList);
            update requestUpdate;
            
        }
        catch (Exception error) {
            system.debug('error'+errorMessage);
            errorMessage = error.getMessage();
        }
        System.assert(errorMessage != null, 'Child Case Not Closed Error Message');
        
    }
    
/****************************************************************************************************
 * Recognise Account Based On Email Content
 ****************************************************************************************************/  
    @isTest static void validateAccountRecognition() {  
        Map<Id,Case> oldMap = new Map<Id,Case>();
        Map<Id,Case> newMap = new Map<Id,Case>();
        List<Case> newCaseList = new List<Case>();
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Account_ERP_ID__c = 'MX020104TEST';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        insert testContact;
        
        // Create Case
        Case request = new Case();
        request.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        request.Type = 'Test';
        request.Area__c = 'Test';
        request.Sub_Area__c = 'Test';
        request.Priority = 'Test';
        request.Description = 'Test';
        request.Resolution_Code__c = 'Test';
        request.SR_Resolutions__c = 'Test';
        request.ContactId = testContact.Id;
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        oldMap.put(request.Id,request);
        System.assert(request.Id != null, 'Case Created');
        
        // Update Mailbox
        Case requestUpdate = new Case();
        requestUpdate.Id = request.Id;
        requestUpdate.GCM_ByPassValidation_Timestamp__c = Datetime.now() + 1;
        requestUpdate.GCM_Mailbox_Reference__c='gbssftest1@bp.com';
        
        newMap.put(requestUpdate.Id,requestUpdate);
        newCaseList.add(requestUpdate);

        Map<Id, Case> oMap = new Map<Id, Case>();
        oMap.put(requestUpdate.Id, requestUpdate);
        Map<Id, Case> nMap = new Map<Id, Case>();
        nMap.put(requestUpdate.Id, requestUpdate);
        
        GCM_Case_Trigger_Helper.validateChildRecords(oMap, nMap, newCaseList);
        GCM_Case_Trigger_Helper.applyRoutingRules(oldMap, newMap, newCaseList);
        
        update requestUpdate;
        
        // Query Newly Created Case
        Case newCase = (Case) BPG_Error_Logger.queryFirstRecord('select AccountId from Case where Id = \'' + request.Id + '\'');
        System.assert(newCase.AccountId != null, 'Default Account Id Not Set');
    }
    
/****************************************************************************************************
 * Test Default Account
 ****************************************************************************************************/  
    @isTest static void validateDefaultAccount() {
		// Set User-Level Business Hours
        User thisUser = [select Id, GCM_Business_Hours__c from User where Id = :UserInfo.getUserId()];
        thisUser.GCM_Business_Hours__c = 'Default';
        update thisUser;
        
        Map<Id,Case> oldMap = new Map<Id,Case>();
        Map<Id,Case> newMap = new Map<Id,Case>();
        List<Case> newCaseList = new List<Case>();
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Account_ERP_ID__c = '51234567';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        insert testContact;
        
        // Create Case
        Case request = new Case();
        request.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        request.Description = 'Test 51234567 Data Test';
        request.Resolution_Code__c = 'Test';
        request.SR_Resolutions__c = 'Test';
        request.ContactId = testContact.Id;
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        request.OwnerId = UserInfo.getUserId();
        insert request;
        oldMap.put(request.Id,request);
        System.assert(request.Id != null, 'Case Created');
        
        // Update Mailbox
        Case requestUpdate = new Case();
        requestUpdate.Id = request.Id;
        requestUpdate.Description = 'Test 51234567 Data Test';
        requestUpdate.GCM_Mailbox_Reference__c = 'gbssftest1@bp.com';
        requestUpdate.GCM_ByPassValidation_Timestamp__c = Datetime.now() + 1;       

        newMap.put(requestUpdate.Id,requestUpdate);
        newCaseList.add(requestUpdate);

        Map<Id, Case> oMap = new Map<Id, Case>();
        oMap.put(requestUpdate.Id, requestUpdate);
        Map<Id, Case> nMap = new Map<Id, Case>();
        nMap.put(requestUpdate.Id, requestUpdate);
        
        GCM_Case_Trigger_Helper.validateChildRecords(oMap, nMap, newCaseList);
        GCM_Case_Trigger_Helper.applyRoutingRules(oldMap, newMap, newCaseList);
        
        update requestUpdate;
        
        // Query Newly Created Case
        Case newCase = (Case) BPG_Error_Logger.queryFirstRecord('select AccountId from Case where Id = \'' + request.Id + '\'');
        System.assert(newCase.AccountId != null, 'Default Account Id Not Set');
    }   

/****************************************************************************************************
 * Test Queue Team Name
 ****************************************************************************************************/  
    @isTest static void validateQueueTeamName() {
        User thisUser = (User) BPG_Error_Logger.queryFirstRecord('select Id from User where Id = \'' + UserInfo.getUserId() + '\'');
        System.runAs (thisUser) {
          // Create Test Queue
          Group testQueue = new Group(Type = 'Queue', Name = 'GCM Test Queue', DeveloperName = 'GCM_Test_Queue');
          insert testQueue;
          QueueSObject testQueueObject = new QueueSObject(SObjectType = 'Case', QueueId = testQueue.Id);
          insert testQueueObject;

          // Create Unmapped Queue
          Group unmappedQueue = new Group(Type = 'Queue', Name = 'GCM Test Unmapped Queue', DeveloperName = 'GCM_Test_Unmapped_Queue');
          insert unmappedQueue;
          QueueSObject unmappedQueueObject = new QueueSObject(SObjectType = 'Case', QueueId = unmappedQueue.Id);
          insert unmappedQueueObject;
                
          // Create Test Account
          Account testAccount = new Account();
          testAccount.Name = 'Test';
          testAccount.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'Customer\' and SObjectType = \'Account\'').Id;
          insert testAccount;
        
          // Create Contact
          Contact testContact = new Contact();
          testContact.FirstName = 'Test';
          testContact.LastName = 'Test';
          testAccount.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'General_Contact\' and SObjectType = \'Contact\'').Id;        
          insert testContact;
        
          // Create Case
          Case request = new Case();
          request.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
          request.Type = 'Test';
          request.Area__c = 'Test';
          request.Sub_Area__c = 'Test';
          request.Priority = 'Test';
          request.Description = 'Test';
          request.Resolution_Code__c = 'Test';
          request.SR_Resolutions__c = 'Test';
          request.ContactId = testContact.Id;
          request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
          request.OwnerId = testQueue.Id;
          insert request;
          System.assert(request.Id != null, 'Case Created');
        
          List<Case> caseList = [select Id, GCM_Owner_Team_Name__c from Case where OwnerId = :testQueue.Id];
          System.assert(caseList.size() > 0, 'Case Test Data Created');
          System.assert(caseList[0].GCM_Owner_Team_Name__c == 'Test', 'Team Name Assigned');
          
          // Change Owner
          caseList[0].OwnerId = unmappedQueue.Id;
          update caseList;          
        }
    }
}