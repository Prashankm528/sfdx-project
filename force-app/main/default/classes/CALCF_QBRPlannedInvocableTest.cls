/**************************************************************************************************************************************
* Description : test the different scenarios to CALCF_QBR_Planned_Invocable.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 29-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CALCF_QBRPlannedInvocableTest 
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }
    
    @isTest
    static void eventIsPlannedTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Event newEvent;
        Test.startTest();
        system.runAs(testUser) 
        {
            newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testCustomerAccount.Id;
            newEvent.Type = 'Quarterly Business Review';
            newEvent.CASFO_QBR_Closed__c = false;
            newEvent.StartDateTime = datetime.now();
            insert newEvent;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,CASFO_QBR_Planned__c,CASFO_QBR_Planned_Date__c From Account Where Id =: testCustomerAccount.Id limit 1];
        
        System.assertEquals(newEvent.StartDateTime, testCustomerAccount.CASFO_QBR_Planned_Date__c,'Customer planned date should be equal to event startdate');
        System.assert(testCustomerAccount.CASFO_QBR_Planned__c,'Customer CASFO_QBR_Planned__c value should be qual to true');
        
    }
    
    @isTest
    static void eventIsCompletedTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        Event newEvent;
        Test.startTest();
        system.runAs(testUser) 
        {
            newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testCustomerAccount.Id;
            newEvent.Type = 'Quarterly Business Review';
            newEvent.CASFO_QBR_Closed__c = true;
            newEvent.CASFO_QBR_Meeting_Status__c = 'Completed';
            newEvent.StartDateTime = datetime.now();
            insert newEvent;
        }
        Test.stopTest();
        testCustomerAccount = [Select Id,CASFO_QBR_Completed_Date__c,CASFO_QBR_Planned__c,CASFO_QBR_Planned_Date__c,
                               CASFO_QBR_Requested_Date__c,CASFO_QBR_Requested__c
                               From Account Where Id =: testCustomerAccount.Id limit 1];
        
        System.assertEquals(null, testCustomerAccount.CASFO_QBR_Planned_Date__c,'Customer CASFO_QBR_Planned_Date__c value should be qual to blank');
        System.assert(!testCustomerAccount.CASFO_QBR_Planned__c,'Customer CASFO_QBR_Planned__c value should be qual to false');
        System.assertEquals(null, testCustomerAccount.CASFO_QBR_Requested_Date__c,'Customer CASFO_QBR_Requested_Date__c value should be qual to blank');
        System.assert(!testCustomerAccount.CASFO_QBR_Requested__c,'Customer CASFO_QBR_Requested__c value should be qual to false');
    }
    
    @isTest
    static void eventIsMultiTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        List<Account> testCustomerAccountList = SFO_TestDataService.createCustomerAccounts(5);
        insert testCustomerAccountList;
        
        List<Event> newEventList = new List<Event>();
        Test.startTest();
        system.runAs(testUser) 
        {
            Event newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testCustomerAccountList[0].Id;
            newEvent.Type = 'Quarterly Business Review';
            newEvent.CASFO_QBR_Closed__c = false;
            newEvent.StartDateTime = datetime.now();
            newEventList.add(newEvent);
            
            Event newEvent2 =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent2.CASFO_Visit_Completed__c = True;
            newEvent2.ownerId = testUser.Id; 
            newEvent2.whatId = testCustomerAccountList[1].Id;
            newEvent2.Type = 'Quarterly Business Review';
            newEvent2.CASFO_QBR_Closed__c = true;
            newEvent2.CASFO_QBR_Meeting_Status__c = 'Completed';
            newEvent2.StartDateTime = datetime.now();
            newEventList.add(newEvent2);
            insert newEventList;
        }
        Test.stopTest();
        Account testCustomerAccount = [Select Id,CASFO_QBR_Planned__c,CASFO_QBR_Planned_Date__c From Account Where Id =: testCustomerAccountList[0].Id limit 1];
        
        System.assertEquals(newEventList[0].StartDateTime, testCustomerAccount.CASFO_QBR_Planned_Date__c,'Customer planned date should be equal to event startdate');
        System.assert(testCustomerAccount.CASFO_QBR_Planned__c,'Customer CASFO_QBR_Planned__c value should be qual to true');
      
        testCustomerAccount = [Select Id,CASFO_QBR_Completed_Date__c,CASFO_QBR_Planned__c,CASFO_QBR_Planned_Date__c,
                               CASFO_QBR_Requested_Date__c,CASFO_QBR_Requested__c
                               From Account Where Id =: testCustomerAccountList[1].Id limit 1];
        
        System.assertEquals(null, testCustomerAccount.CASFO_QBR_Planned_Date__c,'Customer CASFO_QBR_Planned_Date__c value should be qual to blank');
        System.assert(!testCustomerAccount.CASFO_QBR_Planned__c,'Customer CASFO_QBR_Planned__c value should be qual to false');
        System.assertEquals(null, testCustomerAccount.CASFO_QBR_Requested_Date__c,'Customer CASFO_QBR_Requested_Date__c value should be qual to blank');
        System.assert(!testCustomerAccount.CASFO_QBR_Requested__c,'Customer CASFO_QBR_Requested__c value should be qual to false');
        
    }
    
    private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}