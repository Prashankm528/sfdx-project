/************************************************************************************************************
* Description : Apex class to handle auto populating ContentNotes title based on related Event.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-FEB-07   1.0                 Maros Zilka		   	Initial version
* 2018-APR-11						Maros Zilka			Changed name to compli with namimg convention
*************************************************************************************************************/

public class CASFO_FillNoteTitle {
    private final Map<Id, ContentDocumentLink> newContentDocumentLinkMap;
    
    public CASFO_FillNoteTitle(map<Id, ContentDocumentLink> newMap) {
        newContentDocumentLinkMap = newMap;
    }
    
	public void fillNoteTitle() {
		List<ContentNote> cnToUpdate = new List<ContentNote>();
		List<ContentNote> cnl;
		List<ContentDocumentLink> cdl;
		List<Event> el;
		List<Account> al;
		List<Lead> ll;
		List<Contact> cl;
	
		Set<Id> cdids = new Set<Id>();
		Set<Id> cnids = new Set<Id>();
		Set<Id> leids = new Set<Id>();
		Set<Id> whoids = new Set<Id>();
		Set<Id> accountids = new Set<Id>();
		
		Map<Id, String> eventAccountMap = new Map<Id, String>();
		Map<Id, String> eventContactMap = new Map<Id, String>();
		Map<Id, Event> noteEventMap = new Map<Id, Event>();
		
		Event event;
		
		List<String> titlePartsList = new List<String>();
		String title;		

		cdl = newContentDocumentLinkMap.values();

		//Collect ContentDocument IDs so we can query against it
		for(ContentDocumentLink cd : cdl) {
			if(cd.LinkedEntityID.getSObjectType().getDescribe().getName() == 'Event') {
        		cdids.add(cd.ContentDocumentId);
        	}
        }

        if(cdids.isEmpty()) {
        	return;
        }

        cnl = [SELECT Id, Title FROM ContentNote WHERE Id IN :cdids AND ( Title = '' OR Title = 'Untitled Note')];
        
        //Collect Content Note IDs so we can query against it
        for(ContentNote cn : cnl) {
        	cnids.add(cn.Id);
        }
		
		//To get Linked Entities only for Content Notes
		for(ContentDocumentLink cd : cdl) {
			if(cnids.contains(cd.ContentDocumentId)) {
				leids.add(cd.LinkedEntityId);
			}
		}
        
        //Select events which are linked to our notes
		el = [SELECT Id, Subject, AccountId, StartDateTime, Location, WhoId FROM Event WHERE Id IN :leids];
		
		//START - Collect contact/lead info. WhoId field can point to Contact or Lead.
		for (Event e : el) {
			whoids.add(e.WhoId);
		}
		
		cl = [SELECT Id, Name FROM Contact WHERE Id IN :whoids];
		
		for (Event e : el) {
			for (Contact c : cl) {
				if (c.Id == e.WhoId) {
					eventContactMap.put(e.ID, c.Name);
				}
			}
		}
		//END - Collect contact/lead info
		
		//START - Collect Account info
		for (Event e : el) {
			accountids.add(e.AccountId);
		}
		
		al = [SELECT Id, Name FROM Account WHERE Id IN :accountids];
		
		for (Event e : el) {
			for (Account a : al) {
				if (a.Id == e.AccountId) {
					eventAccountMap.put(e.ID, a.Name);
				}
			}
		}
		//END - Collect Account info
		
		//Create map between notes and events, there will be only one event for note ID
		//If there is more events linked to Note last one in list will be saved to map
		for (ContentDocumentLink cd : cdl) {
			for (Event e : el) {
				if (cnids.contains(cd.ContentDocumentId) && e.Id == cd.LinkedEntityId) {
					noteEventMap.put(cd.ContentDocumentId, e);
				}
			}
		}
	
		//Iterate through notes and update title
		// List of only (cn.Title == '' || cn.Title == 'Untitled Note') condition is in SOQL
		for(ContentNote cn : cnl) {
			// If there is no DocumentLink between Note and Event this condition will be false
			if(noteEventMap.containsKey(cn.Id)) {
				titlePartsList.clear();
				event = noteEventMap.get(cn.Id);
				
				if(eventAccountMap.containsKey(event.Id)) {
					titlePartsList.add(eventAccountMap.get(event.Id));
				}
				
				if(String.isNotBlank(event.subject)) {
					titlePartsList.add(event.subject);
				}
				
				if(String.isNotBlank(event.StartDateTime.format())) {
					titlePartsList.add(event.StartDateTime.format());
				}
				
				if(String.isNotBlank(event.Location)) {
					titlePartsList.add(event.Location);
				}
				
				if(eventContactMap.containsKey(event.Id)) {
					titlePartsList.add(eventContactMap.get(event.Id));
				}
				
				title = String.join(titlePartsList, ', ');
				
				cn.Title = title;
				cnToUpdate.add(cn);
			}
		}
		
		try {
			update cnToUpdate;
		} catch(Exception e) {
               System.debug('An exception occurred: ' + e.getMessage());
               return;
    	}
    }
}