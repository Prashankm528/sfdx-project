/*****************************************************************************************
*	    Date:		    03SEP2018
*       Author:         Adam Janicko - IBM
*       Description:    Test class for the CASFO_AccountLastMeetingActivity class.
*       Modifications:  25NOV2019 Rahma Belghouti - Add description before marking the Event as complete
****************************************************************************************/
@isTest()
public class CASFO_AccountLastMeetingActivityTest {
    @isTest
    private static void startUpdateBulkTest() {
        List<Event> newEvents = new List<Event>();
        List<Account> accounts = new List<Account>();
        Date today = Date.today();
        
        for(integer j = 0; j < 5; j++) {
            accounts.add(getAccount('unitTest' + j));
        }
        
        Test.startTest();
        insert accounts;
        
        for(Account acc : accounts) {
            for(integer i = 0; i <= 40; i++) {
                Event event = getEvent(Datetime.newInstance(today.year(), today.month() - 5, today.day() + i, 14, 00, 00), 
                                       Datetime.newInstance(today.year(), today.month() - 5, today.day() + i, 15, 00, 00), acc); 
                if(math.mod(i, 3) == 0) {
                    event.CASFO_Visit_Completed__c = true;
                    event.Description = 'Test Description';
                } 
                //from 202 I want only 33 to be of type 'Customer Meeting'
                if(math.mod(i, 3) != 0) {
                    event.Type = 'Customer Call';
                    event.Subject = 'Call';
                }  
                newEvents.add(event);
        	}    
        }
        
        insert newEvents;
        Test.stopTest();
        
        List<Account> testAccs = ([SELECT Name, CASFO_LastMeetingActivityDate__c, CASFO_Overdue__c, CASFO_Days_from_Last_Visit__c, CASFO_Customer_Meeting_Frequency__c, 
                                   (SELECT ActivityDate FROM Events 
                                    WHERE CASFO_Visit_Completed__c = true AND Type = 'Customer Meeting'
                                    ORDER BY ActivityDate DESC LIMIT 1)
                                   FROM Account 
                                   WHERE Name LIKE 'unitTest'
                                   ORDER BY Name ASC]);
        
        for(Account testAcc : testAccs) {
            Event testEvent = testAcc.Events[0];
            
            System.assertEquals(testAcc.CASFO_LastMeetingActivityDate__c, testEvent.ActivityDate);
            System.assertEquals(testAcc.CASFO_Overdue__c, true);
            System.assertEquals(testAcc.CASFO_Days_from_Last_Visit__c, math.abs(today.daysBetween(testAcc.CASFO_LastMeetingActivityDate__c)));
            System.assertEquals(testAcc.CASFO_Customer_Meeting_Frequency__c, 3);
        }
    }
	
    @isTest
    private static void notOverdueTest() {
    	insert(getAccount('unitTest'));
        Account acc = [SELECT Id FROM Account WHERE Name = 'unitTest' LIMIT 1];
        Date today = Date.today();
        
        Event event = getEvent(Datetime.newInstance(today.year(), today.month(), today.day() - 5, 14, 00, 00), 
                               Datetime.newInstance(today.year(), today.month(), today.day() - 5, 15, 00, 00), acc);
        event.CASFO_Visit_Completed__c = true; 
        event.Description = 'Test Description';
        Test.startTest();
        insert event;
        
        //event is only 5 days old, so it should not be overdue
       	Account testAcc = ([SELECT CASFO_Overdue__c FROM Account WHERE Id =: acc.Id LIMIT 1]);
        System.assertEquals(testAcc.CASFO_Overdue__c, false);
        
        event.ActivityDateTime = Datetime.newInstance(today.year(), today.month(), today.day(), 14, 00, 00);
        event.EndDateTime = Datetime.newInstance(today.year(), today.month(), today.day(), 15, 00, 00);
        
        update event;
        Test.stopTest();
    
        //test if date updated correctly
        testAcc = ([SELECT CASFO_LastMeetingActivityDate__c FROM Account WHERE Id =: acc.Id LIMIT 1]);
        Event testEvent = ([SELECT ActivityDate 
                            FROM Event 
                            WHERE Id =: event.Id]);
        System.assertEquals(testAcc.CASFO_LastMeetingActivityDate__c, testEvent.ActivityDate);
    }
    
    @isTest
    private static void overdueTest() {
    	insert(getAccount('unitTest'));
        Account acc = [SELECT Id FROM Account WHERE Name = 'unitTest' LIMIT 1];
        Date today = Date.today();
        
        Event event = getEvent(Datetime.newInstance(today.year(), today.month() - 2, today.day(), 14, 00, 00), 
                               Datetime.newInstance(today.year(), today.month() - 2, today.day(), 15, 00, 00), acc);
        Test.startTest();
        insert event;
        
        event.CASFO_Visit_Completed__c = true;
        event.Description = 'Test Description';
        update event;
        Test.stopTest();
        
        //test if after visit completed flag update, overdue got changed correctly
        Account testAcc = ([SELECT CASFO_LastMeetingActivityDate__c, CASFO_Overdue__c FROM Account WHERE Id =: acc.Id LIMIT 1]);
        Event testEvent = ([SELECT ActivityDate 
                            FROM Event 
                            WHERE Id =: event.Id]);
        System.assertEquals(testAcc.CASFO_LastMeetingActivityDate__c, testEvent.ActivityDate);
        System.assertEquals(testAcc.CASFO_Overdue__c, true);
    }
    
    @isTest
    private static void invalidEventTest() {
    	insert(getAccount('unitTest'));
        Account acc = [SELECT Id FROM Account WHERE Name = 'unitTest' LIMIT 1];
        Date today = Date.today();
        
        Event event = getEvent(Datetime.newInstance(today.year(), today.month() - 2, today.day(), 14, 00, 00), 
                               Datetime.newInstance(today.year(), today.month() - 2, today.day(), 15, 00, 00), acc);
        event.WhatID = null;
        
        Test.startTest();
        insert event;
        
        event.CASFO_Visit_Completed__c = true;
        event.Description = 'Test Description';
        update event;
        Test.stopTest();
        
        //event is not related to any Account, nothing should have been done
        Account testAcc = ([SELECT CASFO_LastMeetingActivityDate__c, CASFO_Overdue__c FROM Account WHERE Id =: acc.Id LIMIT 1]);
        System.assertEquals(testAcc.CASFO_LastMeetingActivityDate__c, null);
    }
    
    private static Event getEvent(Datetime activity, Datetime endDateTime, Account acc) {
        Event event = new Event();
        event.Type = 'Customer Meeting';
        event.Subject = 'Meeting';
        event.ActivityDateTime = activity;
        event.DurationInMinutes = 60;
        event.EndDateTime = endDateTime;
        event.WhatID = acc.Id;
        event.CASFO_Visit_Completed__c = false;
        
        return event;
    }
    
    private static Account getAccount(String name) {
        Account acc = new Account();
        acc.Name = name;
        acc.RecordTypeId = [SELECT Id, SobjectType, Name 
                            FROM RecordType WHERE Name = 'Customer'
                            AND SobjectType = 'Account'  LIMIT 1].Id;
        
        return acc;  
    }

}