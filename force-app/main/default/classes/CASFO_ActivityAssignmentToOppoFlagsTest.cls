/**************************************************************************************************************************************
* Description : test the different scenarios to CASFO_ActivityAssignmentToOpportunitySetFlags Invocable.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 30-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CASFO_ActivityAssignmentToOppoFlagsTest 
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }
    
    @isTest
    static void eventCustomerCallTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        insert testOpportunity;
        
        Event newEvent;
        Test.startTest();
        system.runAs(testUser) 
        {
            newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testOpportunity.Id;
            newEvent.Type = 'Customer Call';
            newEvent.CASFO_QBR_Closed__c = false;
            newEvent.StartDateTime = datetime.now();
            insert newEvent;
        }
        Test.stopTest();
        testOpportunity = [Select Id,Customer_Visit_Associated__c From Opportunity Where Id =: newEvent.whatId limit 1];
        
        System.assert(testOpportunity.Customer_Visit_Associated__c,'Customer Customer_Visit_Associated__c value should be qual to true');
        
    }
    
    @isTest
    static void eventCustomerEmailTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        insert testOpportunity;
        
        Event newEvent;
        Test.startTest();
        system.runAs(testUser) 
        {
            newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testOpportunity.Id;
            newEvent.Type = 'Customer Email';
            newEvent.CASFO_QBR_Closed__c = false;
            newEvent.StartDateTime = datetime.now();
            insert newEvent;
        }
        Test.stopTest();
        testOpportunity = [Select Id,Customer_Visit_Associated__c From Opportunity Where Id =: newEvent.whatId limit 1];
        
        System.assert(testOpportunity.Customer_Visit_Associated__c,'Customer Customer_Visit_Associated__c value should be qual to true');
        
    }
    
    @isTest
    static void eventCustomerMeetingTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        insert testOpportunity;
        
        Event newEvent;
        Test.startTest();
        system.runAs(testUser) 
        {
            newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testOpportunity.Id;
            newEvent.Type = 'Customer Meeting';
            newEvent.CASFO_QBR_Closed__c = false;
            newEvent.StartDateTime = datetime.now();
            insert newEvent;

            Map<String, object> params = new Map<String, Object>();
            params.put('WhatID', testOpportunity.Id);
            Flow.Interview.Update_Opportunity_When_Customer_Visit_Assigned oppFlow = new Flow.Interview.Update_Opportunity_When_Customer_Visit_Assigned(params);
			oppFlow.Start();
            
        }
        Test.stopTest();
        testOpportunity = [Select Id,Customer_Visit_Associated__c From Opportunity Where Id =: newEvent.whatId limit 1];
        
        System.assert(testOpportunity.Customer_Visit_Associated__c,'Customer Customer_Visit_Associated__c value should be qual to true');
        
    }

    @isTest
    static void eventFlowTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        testOpportunity.Customer_Visit_Associated__c = false;
        insert testOpportunity;
        
        Test.startTest();
        system.runAs(testUser) 
        {
			List<opportunity> oppList = new List<opportunity>{testOpportunity};		
            Map<String, object> params = new Map<String, Object>();
            params.put('WhatID', testOpportunity.Id);
            Flow.Interview.Update_Opportunity_When_Customer_Visit_Assigned oppFlow = new Flow.Interview.Update_Opportunity_When_Customer_Visit_Assigned(params);
			oppFlow.Start();
        }
        Test.stopTest();
        testOpportunity = [Select Id,Customer_Visit_Associated__c From Opportunity Where Id =: testOpportunity.Id limit 1];
        
        System.assert(testOpportunity.Customer_Visit_Associated__c,'Customer Customer_Visit_Associated__c value should be qual to true');
        
    }
    
    private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}