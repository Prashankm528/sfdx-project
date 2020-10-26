/**
 * @author          Jan Majling
 * @date            27/08/2018
 * @group           CAJBP
 * @description     tests for CAJBP functionality in EventTrigger
 *
 * history
 * 27/08/2018   Jan Majling         Created 
 */
@isTest
private class CAJBP_EventTriggerTest {
	private final static Id JBP_EVENT_RECORD_TYPE_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Event').getRecordTypeId();

    @testSetup static void setup() {
        CAJBP_TestFactory.createUsers(1, 0);
        Id jbpId = CAJBP_TestFactory.createJointBusinessPlan().Id;
        Id objectiveId = CAJBP_TestFactory.createObjective(jbpId).Id;
        CAJBP_TestFactory.createJbpActivity(objectiveId);
    }
    /**
    @isTest static void testCalculateActivityTotalCostsForEventsOnInsert() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Integer eventsCount = 200;
        List<Event> events = new List<Event>(); 
        for(Integer i = 0; i < eventsCount; i++) {
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
            events.add(event);
        }

        Test.startTest();
        insert events;
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(eventsCount * 100, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        System.assertEquals(eventsCount * 200, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost should be equal');
    }
    
    @isTest static void testCalculateActivityTotalCostsForEventsOnUpdate() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Integer eventsCount = 200;
        List<Event> events = new List<Event>(); 
        for(Integer i = 0; i < eventsCount; i++) {
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
            events.add(event);
        }
        insert events;
        for(Integer i = 0; i < eventsCount; i++) {
            Event event = events.get(i);
            event.CAJBP_Estimated_Cost__c = 150;
            event.CAJBP_Actual_Cost__c = 250;
        }

        Test.startTest();
        update events;
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(eventsCount * 150, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        System.assertEquals(eventsCount * 250, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be equal');
    }

    @isTest static void testCalculateActivityTotalCostsForEventsOnDelete() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Integer eventsCount = 200;
        List<Event> events = new List<Event>(); 
        for(Integer i = 0; i < eventsCount; i++) {
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
            events.add(event);
        }
        insert events;

        Test.startTest();
        delete events;
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(0, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost value should be zero');
        System.assertEquals(0, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be zero');
    }*/
}