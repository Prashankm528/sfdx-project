/**
 * @author			Venkatesh Muniyasamy
 * @date			14/01/2020
 * @group			CAJBP
 * @description		Renders Custom Calendar.
 *
 * history
 * 15/01/2020	Venkatesh Muniyasamy	    Custom Calendar
 * 16/07/2020   Abhinit Kohar               Added a test for JBP Global Calendar
 */
@isTest (seeAllData = false)
public with sharing class CAJBP_CalendarControllerTest
{
    static CAJBP_Joint_Business_Plan__c jbp;
    static CAJBP_Joint_Business_Plan__c jbpGlobal;
    static CAJBP_Objective__c objective;
    static CAJBP_JBP_Activity__c activity;
    static Id userId;
    static List<CAJBP_CalendarController.Activities> activityList;
    static final Id jbpTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Task').getRecordTypeId();
    static List<Event> events = new List<Event>();
    static List<Task> tasks = new List<Task>();
    static id jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;

    @isTest
    public static void testObjective()
    {
        CreateTestData();
        Test.startTest();
        jbp = [select Id,name from CAJBP_Joint_Business_Plan__c Limit 1];
        activityList = (List<CAJBP_CalendarController.Activities>)CAJBP_CalendarController.getData(jbp.Id, false).get('activities');
        Test.stopTest();
        system.assertEquals(9, activityList.size(),'Objective count retrieved is incorrect');
    }

    @isTest
    public static void testObjectiveGlobal()
    {
        CreateTestDataForGlobalCalendar();
        Test.startTest();
        jbpGlobal = [select Id,name from CAJBP_Joint_Business_Plan__c Limit 1];
        activityList = (List<CAJBP_CalendarController.Activities>)CAJBP_CalendarController.getData(jbpGlobal.Id, true).get('activities');
        Test.stopTest();
        system.assertEquals(9, activityList.size(),'Objective count retrieved is incorrect');
    }

    @isTest
    public static void testGetJBPs()
    {
        CreateTestDataForGlobalCalendar();
        Test.startTest();
            List <CAJBP_Joint_Business_Plan__c> jbpList = CAJBP_CalendarController.getFilterData();
        Test.stopTest();
        system.assertEquals(1, jbpList.size(),'JBP count retrieved is incorrect');
    }

    static void CreateTestData()
    {
        CAJBP_TestFactory.createUsers(1, 0);
        userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        jbp = CAJBP_TestFactory.createJointBusinessPlan();
        objective = CAJBP_TestFactory.createObjective(jbp.Id);
        activity = CAJBP_TestFactory.createJbpActivity(objective.Id);
        for(Integer i = 1; i < 5; i++) {
            Task task = new Task(
                subject='Call',
                ActivityDate = Date.today().addDays(i),
                WhatId = activity.Id,
                OwnerId = userId,
                RecordTypeId = jbpTaskRecordTypeId
            );
            Event event = new Event(
                Subject ='Call',
                StartDateTime = DateTime.now(),
                EndDateTime = DateTime.now().addHours(2),
                WhatId = activity.Id,
                Description = 'New Events',
                Type ='Customer Call'
            );
            tasks.add(task);
            events.add(event);
        }
        insert tasks;
        insert events;
    }

    static void CreateTestDataForGlobalCalendar()
    {
        Account act = new Account(Name='JBP Account', Type='Sold-To Party', BillingCountry = 'United Kingdom');
        insert act;

        Contact contact = new Contact(FirstName='TestGlobal', LastName='Last', accountid=act.id);
        insert contact;

        CAJBP_TestFactory.createUsers(1, 0);
        userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;

        jbpGlobal = new CAJBP_Joint_Business_Plan__c(Name ='JBPGlobal',
                CAJBP_State__c='In Progress',CAJBP_Year__c= string.valueOf(date.today().year()+1),
                RecordTypeId=jbpRecordType,CAJBP_Account__c=act.Id,
                CAJBP_JBP_Start_Date__c=Date.Today(),
                CAJBP_JBP_End_Date__c=Date.today(),
                CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Agreed_Sign_Off__c=True,
                CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True,
                CurrencyIsoCode = 'EUR' );

        insert jbpGlobal;

        objective = CAJBP_TestFactory.createObjective(jbpGlobal.Id);
        activity = CAJBP_TestFactory.createJbpActivity(objective.Id);
        for(Integer i = 1; i < 5; i++) {
            Task task = new Task(
                    subject='Call',
                    ActivityDate = Date.today().addDays(i),
                    WhatId = activity.Id,
                    OwnerId = userId,
                    RecordTypeId = jbpTaskRecordTypeId
            );
            Event event = new Event(
                    Subject ='Call',
                    StartDateTime = DateTime.now(),
                    EndDateTime = DateTime.now().addHours(2),
                    WhatId = activity.Id,
                    Description = 'New Events',
                    Type ='Customer Call'
            );
            tasks.add(task);
            events.add(event);
        }
        insert tasks;
        insert events;
    }
}