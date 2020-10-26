/*****************************************************************************************
*	    Date:		    22APR2020
*       Author:         Rahma Belghouti - Infosys
*       Description:    Test CASFO_FillNoteTitle class
*       Modifications:  
****************************************************************************************/
@isTest
private with sharing class CASFO_FillNoteTitleTest {
   
    @isTest
    static void testFillNoteTitle(){
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser.isActive = True;    
        insert testCastrolUser;
        
        System.runAs(testCastrolUser) 
        {
            Account account = SFO_TestDataService.createCustomerAccount();
            insert account;
            Contact contact = SFO_TestDataService.createContact(account.Id);
            insert contact;
            
            Datetime dt = DateTime.parse('10/14/2011 11:46 AM');
            
            Event newEvent =  SFO_TestDataService.createEvent(Schema.SObjectType.Event.getRecordTypeInfosByName().get('SFO Event').getRecordTypeId());
            newEvent.ownerId = testCastrolUser.Id;       
            newEvent.WhoId = contact.Id;
            newEvent.StartDateTime= dt;
            newEvent.EndDateTime= dt+2;
            insert newEvent;
            
            ContentVersion content = SFO_TestDataService.createContent();
            insert content;
            
            ContentNote contentNote = SFO_TestDataService.createContentNote('Untitled Note', 'Testing Note');
            insert contentNote;
            
            
            ContentDocumentLink note = SFO_TestDataService.createDocumentLink(contentNote.Id, newEvent.Id);
            insert note;
            
            map<Id, ContentDocumentLink> newMap = new map<Id, ContentDocumentLink>();
            newMap.put(note.Id, note);
            CASFO_FillNoteTitle controller = new CASFO_FillNoteTitle(newMap);
            
            String noteTitle = account.Name+', Call, '+dt.format()+', ';
            noteTitle+=contact.Firstname+' '+contact.LastName;
            ContentNote noteUpdated = [SELECT Title FROM ContentNote WHERE Id= :contentNote.Id];
            System.assertEquals(noteTitle, noteUpdated.Title);            
        }
    }
}