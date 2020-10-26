/****************************************************************************************************
 *  Date          : 27-APR-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Entitlement_Engine. Test class cannot run in parallel mode.
 * Modifications  : 27-APR-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest
public with sharing class GCM_Entitlement_Engine_Test {
/****************************************************************************************************
 * Test Business Hours Assignment
 ****************************************************************************************************/
    @isTest static void testAssignBusinessHours() {
        Test.startTest();
        
        // Remove User Level Business Hours
        User thisUser = [select Id, GCM_Business_Hours__c from User where Id = :UserInfo.getUserId()];
        thisUser.GCM_Business_Hours__c = null;
        update thisUser;
        
        // Create Account
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Account newAccount = new Account();
        newAccount.recordTypeId = accountRecordTypeId;
        newAccount.Name = 'Test Case Entitlement Business Hours';
        newAccount.Sales_Organisation__c = 'XX01';
        newAccount.Business_Unit__c = 'Fuels - Cards';
        newAccount.Service_Experience_Level__c = 'SL Silver';
        insert newAccount;

        // Get Entitlement Process
        List<SlaProcess> processes = [select Id from SlaProcess where Name = 'GCM_Entitlement_Test_Class'];
        System.assert(processes.size() > 0, 'Entitlement Process Found');
        Id processId = processes[0].Id;
                
        // Create Entitlement
        Entitlement newEntitlement = new Entitlement();
        newEntitlement.Name = newAccount.Name;
        newEntitlement.AccountId = newAccount.Id;
        newEntitlement.StartDate = Date.today();
        newEntitlement.SlaProcessId = processId;
        insert newEntitlement;

        // Call Entitlement Engine
        Map<Id, Id> entitlementMap = new Map<Id, Id>();
        entitlementMap.put(newEntitlement.Id, null);
        GCM_Entitlement_Engine.updateEntitlementMap(entitlementMap);
        System.assert(entitlementMap.get(newEntitlement.Id) != null, 'Business Hours Found');
        
        // Create Service Catalog
        GCM_Service_Catalog__c catalog = new GCM_Service_Catalog__c();
        catalog.GCM_Type__c = 'Test';
        catalog.GCM_Area__c = 'Test';
        catalog.GCM_Sub_Area__c = 'Test';
		catalog.GCM_Sales_Organisation__c = 'XX01';
		catalog.GCM_Business_Unit__c = 'Fuels - Cards';
        catalog.GCM_SEL__c = 'SL Silver';
        catalog.GCM_Service_Level_Priority__c = '40';
        catalog.GCM_Duration__c = 40;
        catalog.GCM_Related_Object__c = 'Case';
        catalog.GCM_Active__c = true;
        insert catalog;
        
        // Create Case
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fuels - Dealer').getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = caseRecordTypeId;
        newCase.Type = 'Test';
        newCase.Area__c = 'Test';
        newCase.Sub_Area__c = 'Test';
        newCase.Subject = 'Test Entitlement';
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        newCase.AccountId = newAccount.Id;
        newCase.EntitlementId = newEntitlement.Id;
        insert newCase;

        Case queriedCase = [select BusinessHours.Name, Due__c from Case where Id = :newCase.Id];
        System.assert(queriedCase.BusinessHours.Name == 'GBS_UK_Cards_Business_Hours', 'UK Business Hours Set');
        System.assert(queriedCase.Due__c != null, 'UK Due Date Set');
        Test.stopTest();
    }

/****************************************************************************************************
 * Test User Business Hours Assignment
 ****************************************************************************************************/
    @isTest static void testAssignUserBusinessHours() {
        Test.startTest();

        // Create Account
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Account newAccount = new Account();
        newAccount.recordTypeId = accountRecordTypeId;
        newAccount.Name = 'Test Case Entitlement Business Hours';
        newAccount.Sales_Organisation__c = 'XX01';
        newAccount.Business_Unit__c = 'Fuels - Cards';
        newAccount.Service_Experience_Level__c = 'SL Silver';
        insert newAccount;

        // Get Entitlement Process
        List<SlaProcess> processes = [select Id from SlaProcess where Name = 'GCM_Entitlement_Test_Class'];
        System.assert(processes.size() > 0, 'Entitlement Process Found');
        Id processId = processes[0].Id;
                
        // Create Entitlement
        Entitlement newEntitlement = new Entitlement();
        newEntitlement.Name = newAccount.Name;
        newEntitlement.AccountId = newAccount.Id;
        newEntitlement.StartDate = Date.today();
        newEntitlement.SlaProcessId = processId;
        insert newEntitlement;
        
        User thisUser = [select Id, GCM_Business_Hours__c from User where Id = :UserInfo.getUserId()];
        thisUser.GCM_Business_Hours__c = 'Default';
        update thisUser;
        
        Map<Id, Id> userMap = new Map<Id, Id>();
        userMap.put(UserInfo.getUserId(), null);
        GCM_Entitlement_Engine.updateUserEntitlementMap(userMap);
        System.assert(userMap.get(UserInfo.getUserId()) != null, 'Business Hours Found');

        // Create Service Catalog
        GCM_Service_Catalog__c catalog = new GCM_Service_Catalog__c();
        catalog.GCM_Type__c = 'Test';
        catalog.GCM_Area__c = 'Test';
        catalog.GCM_Sub_Area__c = 'Test';
		catalog.GCM_Sales_Organisation__c = 'XX01';
		catalog.GCM_Business_Unit__c = 'Fuels - Cards';
        catalog.GCM_SEL__c = 'SL Silver';
        catalog.GCM_Service_Level_Priority__c = '40';
        catalog.GCM_Duration__c = 40;
        catalog.GCM_Related_Object__c = 'Case';
        catalog.GCM_Active__c = true;
        insert catalog;
        
        // Create Case
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fuels - Dealer').getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = caseRecordTypeId;
        newCase.Type = 'Test';
        newCase.Area__c = 'Test';
        newCase.Sub_Area__c = 'Test';
        newCase.Subject = 'Test Entitlement';
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        newCase.AccountId = newAccount.Id;
        newCase.EntitlementId = newEntitlement.Id;
        newCase.OwnerId = UserInfo.getUserId();
        insert newCase;

        Case queriedCase = null;
        queriedCase = [select BusinessHours.Name, Due__c from Case where Id = :newCase.Id];
        System.assert(queriedCase.BusinessHours.Name == 'Default', 'Business Hours Set');
        System.assert(queriedCase.Due__c != null, 'Due Date Set');        

		// Modify Case
        newCase.Type = 'Test Modify';
        newCase.Area__c = 'Test Modify';
        newCase.Sub_Area__c = 'Test Modify';        
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now().addMinutes(1);        
        update newCase;
        
        queriedCase = [select Due__c from Case where Id = :newCase.Id];
        System.assert(queriedCase.Due__c == null, 'Due Date Cleared');        
        
        Test.stopTest();
    }
    
/****************************************************************************************************
 * Test Queue Business Hours Assignment
 ****************************************************************************************************/
    @isTest static void testAssignQueueBusinessHours() {
        Test.startTest();

        User thisUser = (User) BPG_Error_Logger.queryFirstRecord('select Id from User where Id = \'' + UserInfo.getUserId() + '\'');
        System.runAs (thisUser) {
			// Create Queue
			Group testQueue = new Group(Type = 'Queue', Name = 'GCM Test Queue', DeveloperName = 'GCM_Test_Queue');
			insert testQueue;
			QueueSObject testQueueObject = new QueueSObject(SObjectType = 'Case', QueueId = testQueue.Id);
			insert testQueueObject;

	        // Call Entitlement Engine
	        Map<Id, Id> userMap = new Map<Id, Id>();
	        userMap.put(testQueue.Id, null);
	        userMap.put(UserInfo.getUserId(), null);
	        GCM_Entitlement_Engine.updateQueueEntitlementMap(userMap);
	        System.assert(userMap.get(testQueue.Id) != null, 'Business Hours Found');

	        // Create Account
	        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
	        Account newAccount = new Account();
	        newAccount.recordTypeId = accountRecordTypeId;
	        newAccount.Name = 'Test Case Entitlement Business Hours';
	        newAccount.Sales_Organisation__c = 'XX01';
	        newAccount.Business_Unit__c = 'Fuels - Cards';
	        newAccount.Service_Experience_Level__c = 'SL Silver';
	        insert newAccount;

	        // Get Entitlement Process
	        List<SlaProcess> processes = [select Id from SlaProcess where Name = 'GCM_Entitlement_Test_Class'];
	        System.assert(processes.size() > 0, 'Entitlement Process Found');
	        Id processId = processes[0].Id;
                
	        // Create Entitlement
	        Entitlement newEntitlement = new Entitlement();
	        newEntitlement.Name = newAccount.Name;
	        newEntitlement.AccountId = newAccount.Id;
	        newEntitlement.StartDate = Date.today();
	        newEntitlement.SlaProcessId = processId;
	        insert newEntitlement;
                
	        // Create Service Catalog
	        GCM_Service_Catalog__c catalog = new GCM_Service_Catalog__c();
	        catalog.GCM_Type__c = 'Test';
	        catalog.GCM_Area__c = 'Test';
	        catalog.GCM_Sub_Area__c = 'Test';
			catalog.GCM_Sales_Organisation__c = 'XX01';
			catalog.GCM_Business_Unit__c = 'Fuels - Cards';
	        catalog.GCM_SEL__c = 'SL Silver';
	        catalog.GCM_Service_Level_Priority__c = '40';
	        catalog.GCM_Duration__c = 40;
			catalog.GCM_Related_Object__c = 'Case';
        	catalog.GCM_Active__c = true;
        	insert catalog;
        
	        // Create Case
	        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fuels - Dealer').getRecordTypeId();
        	Case newCase = new Case();
        	newCase.RecordTypeId = caseRecordTypeId;
        	newCase.Type = 'Test';
        	newCase.Area__c = 'Test';
        	newCase.Sub_Area__c = 'Test';
        	newCase.Subject = 'Test Entitlement';
        	newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        	newCase.AccountId = newAccount.Id;
        	newCase.EntitlementId = newEntitlement.Id;
        	newCase.OwnerId = testQueue.Id;
        	insert newCase;

        	Case queriedCase = null;
        	queriedCase = [select BusinessHours.Name, Due__c from Case where Id = :newCase.Id];
        	System.assert(queriedCase.BusinessHours.Name == 'GBS_Mexico_Business_Hours', 'Queue Business Hours Set');
        	System.assert(queriedCase.Due__c != null, 'Due Date Set');        
        
        	Test.stopTest();
    	}
    }
}