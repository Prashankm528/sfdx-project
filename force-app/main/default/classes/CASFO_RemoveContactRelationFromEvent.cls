/**
 * @Who     Maros Zilka maros.zilka@sk.ibm.com
 * @when    19-03-2019
 * @what    To prevent Event deletion when Contact is being deleted will set Event WhoId to null
 *    		and saves Contact name in separate text field on Event.
 **/

public class CASFO_RemoveContactRelationFromEvent {
    public void removeContactRelationFromEvent (Map<Id, Contact> oldContactsMap) {
        Map<Id, Contact> generalContactsMap = new Map<Id, Contact>();
        
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        
        // Get only General Contacts
        for (Contact c : [SELECT Id, FirstName, LastName FROM Contact WHERE RecordTypeId = :recordTypeId AND Id IN :oldContactsMap.keySet()]) {
            generalContactsMap.put(c.Id, c);
        }
        
        List<Event> events = [SELECT Id, WhoId FROM Event WHERE WhoId IN :generalContactsMap.keySet()];
        
        if (events.isEmpty()) {
            return;
        }
        
        for (Event e : events) {
            String firstName = generalContactsMap.get(e.WhoId).FirstName;
            String lastName = generalContactsMap.get(e.WhoId).LastName;
            
            if (!String.isBlank(firstName)) {
                e.CASFO_Last_Deleted_Contact_Name__c = firstName + ' ';
            }
            
            e.CASFO_Last_Deleted_Contact_Name__c += lastName;
            
            e.WhoId = null;
        }
        
        update events;
    }
}