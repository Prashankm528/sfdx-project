/**
 * @author          Jan Majling
 * @date            27/08/2018
 * @group           CAJBP
 * @description     tests for CAJBP functionality in TaskTrigger
 *
 * history
 * 27/08/2018   Jan Majling         Created 
 */
@isTest
private class CAJBP_TaskTriggerTest {
	private static final Id JBP_TASK_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Task').getRecordTypeId();

    @testSetup static void setup() {
        CAJBP_TestFactory.createUsers(1, 0);
        Id jbpId = CAJBP_TestFactory.createJointBusinessPlan().Id;
        Id objectiveId = CAJBP_TestFactory.createObjective(jbpId).Id;
        CAJBP_TestFactory.createJbpActivity(objectiveId);
    }
    /**
    @isTest static void testCalculateActivityTotalCostsForTaskOnInsert() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Integer tasksCount = 200;
        List<Event> events = new List<Event>(); 
        List<Task> tasks = new List<Task>(); 
        for(Integer i = 0; i < tasksCount; i++) {
            Task task = new Task(
                WhatId = jbpActivityId,
                OwnerId = userId,
                CAJBP_Estimated_Cost__c = 200,
                CAJBP_Actual_Cost__c = 300,
                RecordTypeId = JBP_TASK_RECORD_TYPE_ID,
                CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
            );
            tasks.add(task);
        }

        Test.startTest();
        insert tasks;
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(tasksCount * 200, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        System.assertEquals(tasksCount * 300, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost should be equal');
    }
    
    @isTest static void testCalculateActivityTotalCostsForTaskOnUpdate() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Integer tasksCount = 200;
        List<Task> tasks = new List<Task>(); 
        for(Integer i = 0; i < tasksCount; i++) {
            Task task = new Task(
                WhatId = jbpActivityId,
                OwnerId = userId,
                CAJBP_Estimated_Cost__c = 200,
                CAJBP_Actual_Cost__c = 300,
                RecordTypeId = JBP_TASK_RECORD_TYPE_ID,
                CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
            );
            tasks.add(task);
        }
        insert tasks;
        for(Integer i = 0; i < tasksCount; i++) {
            Task task = tasks.get(i);
            task.CAJBP_Estimated_Cost__c = 150;
            task.CAJBP_Actual_Cost__c = 250;
        }

        Test.startTest();
        update tasks;
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(tasksCount * 150, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost values should be equal');
        System.assertEquals(tasksCount * 250, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be equal');
    }

    @isTest static void testCalculateActivityTotalCostsForTaskOnDelete() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpActivityId = [SELECT Id FROM CAJBP_JBP_Activity__c WHERE Name = 'Test JBP Activity'].Id;
        Integer tasksCount = 200;
        List<Task> tasks = new List<Task>(); 
        for(Integer i = 0; i < tasksCount; i++) {
            Task task = new Task(
                WhatId = jbpActivityId,
                OwnerId = userId,
                CAJBP_Estimated_Cost__c = 200,
                CAJBP_Actual_Cost__c = 300,
                RecordTypeId = JBP_TASK_RECORD_TYPE_ID,
                CurrencyIsoCode = CAJBP_TestFactory.CURRENCY_ISO_CODE
            );
            tasks.add(task);
        }
        insert tasks;

        Test.startTest();
        delete tasks;
        Test.stopTest();

        CAJBP_JBP_Activity__c jbpActivity = [
            SELECT CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c
            FROM CAJBP_JBP_Activity__c
            WHERE Id = :jbpActivityId
        ];
        System.assertEquals(0, jbpActivity.CAJBP_Estimated_Cost__c, 'Estimated cost value should be zero');
        System.assertEquals(0, jbpActivity.CAJBP_Actual_Cost__c, 'Actual cost values should be zero');
    }
    */
}