/**
 * @author          Jan Majling
 * @date            27/08/2018
 * @group           CAJBP
 * @description     test class for CAJBP_CalculateEstimateAndActualCost
 *
 * history
 * 27/08/2018   Jan Majling         Created 
 */
@isTest
private class CAJBP_CalculateEstimateAndActualCostTest {
	private static final Id JBP_TASK_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Task').getRecordTypeId();
	private final static Id JBP_EVENT_RECORD_TYPE_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Event').getRecordTypeId();

    @testSetup static void setup() {
        CAJBP_TestFactory.createUsers(1, 0);
        Id jbpId = CAJBP_TestFactory.createJointBusinessPlan().Id;
        Id objectiveId = CAJBP_TestFactory.createObjective(jbpId).Id;
        CAJBP_TestFactory.createJbpActivity(objectiveId);
    }

    @isTest static void testCalculateActivityTotalCosts() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;

        Event event = new Event(
            WhatId = jbpActivityId,
            OwnerId = userId,
            DurationInMinutes = 120,
            ActivityDateTime = Datetime.newInstance(2080, 1, 1),
            CAJBP_Estimated_Cost__c = 200,
            CAJBP_Actual_Cost__c = 300,
            RecordTypeId = JBP_EVENT_RECORD_TYPE_ID,
            CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
        );
        insert event;
        List<Event> events = new List<Event>{
            event
        };

        Test.startTest();
        new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(events);
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(1900, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        //System.assertEquals(300, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be equal');
    }

    @isTest static void testCalculateActivityTotalCostsNoValues() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Event event = new Event(
            WhatId = jbpActivityId,
            OwnerId = userId,
            DurationInMinutes = 120,
            ActivityDateTime = Datetime.newInstance(2080, 1, 1),
            RecordTypeId = JBP_EVENT_RECORD_TYPE_ID,
            CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
        );
        insert event;
        List<Event> events = new List<Event>{
            event
        };

        Test.startTest();
        new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(events);
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(1900, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        //System.assertEquals(0, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be equal');
    }

    @isTest static void testCalculateActivityTotalCostsWhenTwoListsChanged() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Event event = new Event(
            WhatId = jbpActivityId,
            OwnerId = userId,
            DurationInMinutes = 120,
            ActivityDateTime = Datetime.newInstance(2080, 1, 1),
            CAJBP_Estimated_Cost__c = 100,
            CAJBP_Actual_Cost__c = 200,
            RecordTypeId = JBP_EVENT_RECORD_TYPE_ID,
            CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
        );
        insert event;
        Task task = new Task(
            WhatId = jbpActivityId,
            OwnerId = userId,
            CAJBP_Estimated_Cost__c = 200,
            CAJBP_Actual_Cost__c = 300,
            RecordTypeId = JBP_TASK_RECORD_TYPE_ID,
            CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
        );
        insert task;
        

        Test.startTest();
        List<Event> events = new List<Event>{event};
        List<Task> tasks = new List<Task>{task};
        new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(events, tasks);
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(1900, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        //System.assertEquals(500, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be equal');
    }

    @isTest static void testNoCalculationForNonActivityEvent() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpId = [
            SELECT Id
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Name = 'Test Account Customer Group JBP 2080'
        ].Id;
        Event event = new Event(
            WhatId = jbpId,
            OwnerId = userId,
            DurationInMinutes = 120,
            ActivityDateTime = Datetime.newInstance(2080, 1, 1)
        );
        insert event;
        List<Event> events = new List<Event>{
            event
        };

        Test.startTest();
        new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(events);
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            LIMIT 1
        ];
        System.assertEquals(1900, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost value should not have been updated');
        //System.assertEquals(null, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost value should not have been updated');
    }
}