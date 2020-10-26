/**
 * @Who     Adam Janicko
 * @when    03-09-2018
 * @what    Handler for the Event trigger. Updates fields on the Account sObject.
 **/
public class CASFO_AccountLastMeetingActivity {
    private static final String customerMeeting = 'Customer Meeting';
    
    private void updateLastMeetingActivityDate(Set<String> accountIds) {
        List<Account> accountsToUpdate = new List<Account>();
        Date today = Date.today();
        Map<String, List<Event>> accountsEvents = new Map<String, List<Event>>();
        
        //get events for all accounts
        List<Event> meetings = ([SELECT Id, AccountId, ActivityDate, CASFO_Visit_Completed__c, Account.CASFO_Minimum_Days_Between_Visits__c
                                 FROM Event 
                                 WHERE AccountId IN :accountIds AND Type = :customerMeeting AND CASFO_Visit_Completed__c = true 
                                 ORDER BY ActivityDate DESC]);
        
        //group events for each account
        for(Event event : meetings) {
            if(accountsEvents.containsKey(event.AccountId)) {
                accountsEvents.get(event.AccountId).add(event);
            } else {
                accountsEvents.put(event.AccountId, new List<Event>{event});
            }
        }
        
        //for each account calculate fields based on its events
        for(List<Event> eventsForAccount : accountsEvents.values()) { 
            Event newestMeeting = eventsForAccount[0];
            Event oldestMeeting = eventsForAccount.get(eventsForAccount.size() - 1);
            
            //set up the account we are going to update
            Account accountToUpdate = new Account();
            accountToUpdate.Id = newestMeeting.AccountId;
            
            accountToUpdate.CASFO_LastMeetingActivityDate__c = newestMeeting.ActivityDate;
            
            if(eventsForAccount.size() > 1) {
                Integer eventSpan = math.abs(newestMeeting.ActivityDate.daysBetween(oldestMeeting.ActivityDate));
                accountToUpdate.CASFO_Customer_Meeting_Frequency__c = eventSpan / (eventsForAccount.size() - 1);
            }    
            
            accountsToUpdate.add(accountToUpdate); 
        }
        
        update accountsToUpdate;
    }
    
    public void startUpdate(List<Event> newEvents, Map<Id, Event> oldEvents) {
        //get only distinct account Ids to use in a Query later
        Set<String> accountIds = new Set<String>();
        
        for(Event newEvent : newEvents)
        {
            //get only events of type customer meeting, which are either new or with certain field changes
            if(newEvent.AccountId != null && customerMeeting.equals(newEvent.Type) && newEvent.CASFO_Visit_Completed__c && (oldEvents == null 
               || (newEvent.ActivityDate != oldEvents.get(newEvent.Id).ActivityDate) 
               || (newEvent.CASFO_Visit_Completed__c != oldEvents.get(newEvent.Id).CASFO_Visit_Completed__c)))
            {
                accountIds.add(newEvent.AccountId);
            }
        }
        if(!accountIds.isEmpty()) {
         	this.updateLastMeetingActivityDate(accountIds);   
        }
    }
}