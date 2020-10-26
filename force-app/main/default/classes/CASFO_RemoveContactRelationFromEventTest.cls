/**
 * @Who     Maros Zilka maros.zilka@sk.ibm.com
 * @when    19-03-2019
 * @what    Test for CASFO_RemoveContactRelationFromEvent
 **/

@isTest
public class CASFO_RemoveContactRelationFromEventTest {
    public static final Integer bulkSize = 200;
    
    @isTest
    public static void bulkTestOfContactDeletion() {
        List<Contact> contacts = getContacts('General_Contact');
        List<Event> events = new List<Event>();
        
        for (Integer i = 0; i < bulkSize; i++) {
            Event e = new Event(Type = 'Customer call',
                                Subject = 'Meeting',
                                WhoId = contacts[i].Id,
                                ActivityDateTime = Date.today(),
                                DurationInMinutes = 90);
            
            events.add(e);
        }
        
        insert events;
        
        Test.startTest();
        
        delete contacts;
        
        Test.stopTest();
        
        events = [SELECT Id, CASFO_Last_Deleted_Contact_Name__c, WhoId FROM Event];
        
        System.assertEquals(200, events.size(), 'There should be 200 events.');
        
        for (Event e : events) {
            System.assertEquals('First Last', e.CASFO_Last_Deleted_Contact_Name__c, 'Last Deleted Contact Name should be set.');
            System.assertEquals(null, e.WhoId, 'WhoId field should be null.');
        }
    }
    
    // Testing deletion of contacts without Events to increase coverage
    @isTest
    public static void bulkTestOfContactDeletionWithoutEvent () {
        List<Contact> contacts = getContacts('General_Contact');
                       
        Test.startTest();
        
        delete contacts;
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Count() FROM Contact], 'There should be no contacts.');
    }
    
    // Negative testing for different record type as Generic Contact
    @isTest
    public static void negativeTestOfnonGeneralContactDeletion () {
        List<Contact> contacts = getContacts('CAIDB_Contact');
        List<Event> events = new List<Event>();
        
        for (Integer i = 0; i < bulkSize; i++) {
            Event e = new Event(Type = 'Customer call',
                                Subject = 'Meeting',
                                WhoId = contacts[i].Id,
                                ActivityDateTime = Date.today(),
                                DurationInMinutes = 90);
            
            events.add(e);
        }
        
        insert events;
        
        Test.startTest();
        
        delete contacts;
        
        Test.stopTest();
        
        events = [SELECT Id, CASFO_Last_Deleted_Contact_Name__c, WhoId FROM Event];
        
        System.assert(events.isEmpty(), 'There should be 200 events.');
    }
    
    private static List<Contact> getContacts(String recordTypeDevName) {
        List<Contact> contacts = new List<Contact>(); 

        Account a = new Account(Name = 'Test Account');
        
        insert a;
        
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        
        for (Integer i = 0; i < bulkSize; i++) {
            Contact c = new Contact(RecordTypeId = recordTypeId,
                                    FirstName = 'First',
                                    LastName = 'Last',
                                    AccountId = a.Id,
                                    CAIDB_Birthday__c = '01/01');
            
            contacts.add(c);
        }
        
        insert contacts;
        
        return contacts;
    }
}