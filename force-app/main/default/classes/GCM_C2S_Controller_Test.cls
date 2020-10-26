/****************************************************************************************************
 *  Date          : 15-FEB-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_C2S_Controller
 * Modifications  : 17-April-2019 SYAP - Initial
 *                  27-April-2019 SYAP - c2s start and stop timer for cases
 *					02-December-2019 AJAY KONATHALA - Get Case Id Method for cases.
 ****************************************************************************************************/
@isTest
public with sharing class GCM_C2S_Controller_Test 
{
/****************************************************************************************************
  Test Stop Timer
 ****************************************************************************************************/
    @isTest static void stopTimerBulkforCase() {
        // Test Stop Timer When Case Closed
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        insert testContact;
        
        // Create GCM_Case_Duration__c
        GCM_Case_Duration__c casDur = new GCM_Case_Duration__c();
        casDur.GCM_End_Time__c = system.now();
        casDur.OwnerId = UserInfo.getUserId();
        insert casDur;
        
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
        request.OwnerId = UserInfo.getUserId();
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        
        // Create User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'BP Base (Salesforce)' LIMIT 1];
        User u1 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user1');
        
        System.assert(request.Id != null, 'Case Created');
        
        GCM_C2S_Controller.isCaseOpen(testAccount.Id);
        GCM_C2S_Controller.startTimer(request.Id);
        Map<Id, Case> mapcase = new Map<Id, Case>();
        List<Case> lstCase=[select Id, OwnerId from Case where Id = :request.Id];
        GCM_C2S_Controller.stopNewCaseTimer(lstCase);

        // When Case Close 
        for(case obj : lstCase)
        {
            obj.Status = 'Closed';
            mapcase.put(obj.Id, obj);
        }
        update lstCase;
        //  when case reopen :- close to open        
        
        for(case obj : lstCase)
        {
            obj.Status='Open';
            obj.CALCF_Not_Surveyed_Reason__c = 'Survey Error 10';
            obj.OwnerId = u1.Id;
            obj.GCM_ByPassValidation_Timestamp__c = Datetime.now() + 1;
            mapcase.put(obj.Id,obj);
        }
        update lstCase;
    }

/****************************************************************************************************
  Test Start Timer
 ****************************************************************************************************/   
    @isTest static void startTimerforCase() {
        // Test Start Timer
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
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
        request.AccountId = testAccount.Id;
        request.ContactId = testContact.Id;
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        System.assert(request.Id != null, 'Case Created');
        
        
        GCM_C2S_Controller.startTimer(request.Id);
        GCM_C2S_Controller.stopTimerByCase(request.Id);
        GCM_C2S_Controller.startTimer(request.Id);
        GCM_C2S_Controller.deleteOrphanNewCaseTimer();
        GCM_C2S_Controller.clearTimer();
    } 
    
/****************************************************************************************************
  Test Stop Timer (Old Case)
 ****************************************************************************************************/   
    @isTest static void StopTimerForOldCase() {
        // Test Stop Timer For Existing Cases Currently Tracked
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
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
        request.AccountId = testAccount.Id;
        request.ContactId = testContact.Id;
        request.OwnerId = UserInfo.getUserId();
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        
        // Create Case
        Case case2 = new Case();
        case2.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        case2.Type = 'Test';
        case2.Area__c = 'Test';
        case2.Sub_Area__c = 'Test';
        case2.Priority = 'Test';
        case2.Description = 'Test';
        case2.Resolution_Code__c = 'Test';
        case2.SR_Resolutions__c = 'Test';
        case2.AccountId = testAccount.Id;
        case2.ContactId = testContact.Id;
        case2.OwnerId = UserInfo.getUserId();
        case2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert case2;
        
        System.assert(case2.Id != null, 'Case Created');
        
        
        GCM_C2S_Controller.startTimer(case2.Id);
        GCM_C2S_Controller.startTimer(request.Id);
        
        GCM_C2S_Controller.clearTimer();
        
    } 
    
/****************************************************************************************************
  Test Start New Case Timer
 ****************************************************************************************************/
    @isTest static void StartNewcaseTimer() {
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        insert testContact;
        
        // Create Case
        list<case> lstcases=new list<case>();
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
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        
        lstcases.add(request);
        // Create Case
        Case case2 = new Case();
        case2.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        case2.Type = 'Test';
        case2.Area__c = 'Test';
        case2.Sub_Area__c = 'Test';
        case2.Priority = 'Test';
        case2.Description = 'Test';
        case2.Resolution_Code__c = 'Test';
        case2.SR_Resolutions__c = 'Test';
        case2.AccountId = testAccount.Id;
        case2.ContactId = testContact.Id;
        case2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert case2;
        lstcases.add(case2);
        System.assert(case2.Id != null, 'Case Created');
        GCM_C2S_Controller.startTimer(case2.Id);
        GCM_C2S_Controller.startNewCaseTimer();
        GCM_C2S_Controller.NewCaseclearTimer();  
    } 
    
 /****************************************************************************************************
  Test method for getting the case duration record for the current user where the end time is null 
 ****************************************************************************************************/
    @isTest static void getCaseId() {
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        insert testContact;
        
        // Create Case
        list<case> lstcases=new list<case>();
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
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        
        lstcases.add(request);
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'BP Base (Salesforce)' LIMIT 1];
        User u1 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user1');
       
        GCM_C2S_Controller.getCaseId(u1.Id);
        GCM_C2S_Controller.startTimer(request.Id);
        GCM_C2S_Controller.stopTimerByCase(request.Id);      
    }   
}