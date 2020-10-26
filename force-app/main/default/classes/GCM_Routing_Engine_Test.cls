/****************************************************************************************************
 *  Date          : 15-SEP-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Routing_Engine
 * Modifications  : 15-SEP-2019 SYAP - Initial
 ****************************************************************************************************/
@isTest
public with sharing class GCM_Routing_Engine_Test 
{
/****************************************************************************************************
 * Routing Rules
 * Designed To Work Even If Trigger Handler Turned Off
 ****************************************************************************************************/   
    @isTest static void validateRoutingRule() {
        User thisUser = (User) BPG_Error_Logger.queryFirstRecord('select Id from User where Id = \'' + UserInfo.getUserId() + '\'');
        System.runAs (thisUser) {
          // Create Landing Queue
          Group landingQueue = new Group(Type = 'Queue', Name = 'GCM MB Test Landing Queue', DeveloperName = 'GCM_MB_Test_Landing_Queue');
          insert landingQueue;
          QueueSObject landingQueueObject = new QueueSObject(SObjectType = 'Case', QueueId = landingQueue.Id);
          insert landingQueueObject;

          // Create Assignment Queue
          Group assignQueue = new Group(Type = 'Queue', Name = 'GCM Test Assign Queue', DeveloperName = 'GCM_Test_Assign_Queue');
          insert assignQueue;
          QueueSObject assignQueueObject = new QueueSObject(SObjectType = 'Case', QueueId = assignQueue.Id);
          insert assignQueueObject;
        
          // Create Default Account
          Account defaultAccount = new Account();
          defaultAccount.Name = 'Test';
          defaultAccount.Account_ERP_ID__c = 'GCMTESTDA';
          defaultAccount.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'Customer\' and SObjectType = \'Account\'').Id;
          insert defaultAccount;

          // Disable Duplicate Check
          Database.DMLOptions dml = new Database.DMLOptions();
          dml.DuplicateRuleHeader.AllowSave = true; 

          // Create Default Contact
          Contact defaultContact = new Contact();
          defaultContact.FirstName = 'Test';
          defaultContact.LastName = 'Test';
          defaultContact.AccountId = defaultAccount.Id;
          defaultContact.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'General_Contact\' and SObjectType = \'Contact\'').Id;
          Database.insert(defaultContact, dml);
            
          // Create Test Account
          Account testAccount = new Account();
          testAccount.Name = 'Test';
          testAccount.Account_ERP_ID__c = 'X9999999';
          testAccount.GCM_Portfolio_1__c = 'Test';
          testAccount.GCM_Portfolio_2__c = 'Test';
          testAccount.GCM_Portfolio_3__c = 'Test';
          testAccount.GCM_Portfolio_4__c = 'Test';
          testAccount.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'Customer\' and SObjectType = \'Account\'').Id;
          insert testAccount;
        
          // Create Contact
          /*
          Contact testContact = new Contact();
          testContact.FirstName = 'Test';
          testContact.LastName = 'Test';
          testAccount.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'General_Contact\' and SObjectType = \'Contact\'').Id;        
          insert testContact;
          */

          // Create Case - Default Account
          Case requestDA = new Case();
          requestDA.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
          requestDA.Type = 'Test';
          requestDA.Area__c = 'Test';
          requestDA.Sub_Area__c = 'Test';
          requestDA.Priority = 'Test';
          requestDA.Description = 'Test';
          requestDA.Resolution_Code__c = 'Test';
          requestDA.SR_Resolutions__c = 'Test';
          //requestDA.ContactId = testContact.Id;
          requestDA.GCM_ByPassValidation_Timestamp__c = Datetime.now();
          requestDA.OwnerId = landingQueue.Id;
          requestDA.SuppliedEmail = 'testsender@test.com';
          insert requestDA;
          System.assert(requestDA.Id != null, 'Case Created');

          // Create Case - Match Account
          Case requestMA = new Case();
          requestMA.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
          requestMA.Type = 'Test';
          requestMA.Area__c = 'Test';
          requestMA.Sub_Area__c = 'Test';
          requestMA.Priority = 'Test';
          requestMA.Description = 'Test X9999999';
          requestMA.Resolution_Code__c = 'Test';
          requestMA.SR_Resolutions__c = 'Test';
          //requestMA.ContactId = testContact.Id;
          requestMA.GCM_ByPassValidation_Timestamp__c = Datetime.now();
          requestMA.OwnerId = landingQueue.Id;
          requestMA.SuppliedEmail = 'testsender@test.com';            
          insert requestMA;
          System.assert(requestMA.Id != null, 'Case Created');
            
          // Create Routing Rule AFTER Test Case Data Created / Skip Trigger Handlers
          GCM_Routing_Strategy__c rule = new GCM_Routing_Strategy__c();
          rule.GCM_Account_Length__c = 8;
          rule.GCM_Account_Match__c = '(X)[0-9]{7}';
          rule.GCM_Case_Type__c = 'Test';
          rule.GCM_Case_Area__c = 'Test';
          rule.GCM_Case_Sub_Area__c = 'Test';
          rule.GCM_Default_Account__c = 'GCMTESTDA';
          rule.GCM_Keyword_Long__c = '^(?!\\s*$).+'; // Any Text
          rule.GCM_Landing_Queue__c = 'GCM_MB_Test_Landing_Queue';
          rule.GCM_Queue__c = 'GCM_Test_Assign_Queue';
          rule.GCM_Mailbox__c = 'test@salesforce.com';
          rule.GCM_Sender__c = 'testsender';
          rule.GCM_Portfolio_1__c = 'Test';
          rule.GCM_Portfolio_2__c = 'Test';
          rule.GCM_Portfolio_3__c = 'Test';
          rule.GCM_Portfolio_4__c = 'Test';
          rule.GCM_Order__c = 1;
          insert rule;
        
          List<Case> caseList = [select Id, AccountId, ContactId, Type, Area__c, Sub_Area__c, Subject, Description, OwnerId, SuppliedEmail from Case where OwnerId = :landingQueue.Id];
          System.assert(caseList.size() > 0, 'Case Test Data Created');
          Map<Id, Case> newMap = new Map<Id, Case>();
          for (Case thisCase : caseList) {
            newMap.put(thisCase.Id, thisCase);
          }
        
          GCM_Routing_Engine.applyRoutingRules(null, newMap, caseList);
        }
    }
}