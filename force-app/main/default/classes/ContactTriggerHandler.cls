/**
 * @Who     Maros Zilka
 * @when    19-03-2019
 * @what    The Generic Trigger Handler for the Contact. Please add your product specific handler into this class
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/

public class ContactTriggerHandler {
    
    private final List<Contact> newRecords;
    private final List<Contact> oldRecords;
    private final Map<Id, Contact> newMap;
    private final Map<Id, Contact> oldMap;
    
    public ContactTriggerHandler(List<Contact> newRecords, List<Contact> oldRecords, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap     = newMap;
        this.oldMap     = oldMap;
    }
    
    public void handleBeforeInsert() {
    }
    
    public void handleAfterInsert() {
    }

    public void handleBeforeUpdate() {
    }
   
    public void handleAfterUpdate() {
    }

    public void handleBeforeDelete() {
        new CASFO_RemoveContactRelationFromEvent().removeContactRelationFromEvent(oldMap);
    }
    
    public void handleAfterDelete() {
    }
}