/* @author            Karishma Gurjar
*  @date              06th Dec, 2019
*  @description       handles trigger events on Contact object for IST CRM Project
*  @ -----------------------------------
*/

public without sharing class ICRM_ContactTriggerHandler  extends BPG_Trigger_Handler_Utilities{            
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        /*  Before Insert of Contact */
        Id contactRecordTypeLEId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();  
        List<Contact> newContactList = new List<Contact>(); 
        Set<Id> AccountIDSet = new Set<Id>();
        List<Contact> contactListtoUpdate = new List<Contact>();
        newContactList=n;
        for(Contact con : newContactList) {
            
            if(con.RecordTypeId == contactRecordTypeLEId && con.AccountId != null && con.ICRM_Government_Owned__c == False){
                
                contactListtoUpdate.add(con);
                AccountIDSet.add(con.AccountId);
            }
        }
        if(contactListtoUpdate.size() > 0){
            updateContactGovernment(contactListtoUpdate, AccountIDSet);
        }
    }
    
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /*  Before Update of Contact */
    {   
        Id contactRecordTypeLEId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();  
        List<Contact> newContactList = new List<Contact>(); 
        Set<Id> AccountIDSet = new Set<Id>();
        List<Contact> contactListtoUpdate = new List<Contact>();
        newContactList=n;
        for(Contact con : newContactList) {
            
            if(con.RecordTypeId == contactRecordTypeLEId && con.AccountId != null){
                if(con.AccountId != ((Contact)oMap.get(con.id)).AccountId)
                {
                    contactListtoUpdate.add(con);
                    AccountIDSet.add(con.AccountId);
                }
            }
        }
        if(contactListtoUpdate.size() > 0){
            updateContactGovernment(contactListtoUpdate, AccountIDSet);
        }
    }
    
    
    
    public void updateContactGovernment(List<Contact> contactListtoUpdate,Set<Id> AccountIDSet){
        //Method to update Governemnt Owned Field on Contact
        map<id,Account> acountMap= new map<id,Account>([SELECT Id, BPI_Government_Owned__c from Account WHERE Id in: AccountIDSet]);
        for(Contact con : contactListtoUpdate){
            if(acountMap.containskey(con.AccountId) && (acountMap.get(con.AccountId).BPI_Government_Owned__c) && Trigger.isInsert)
            {
                con.ICRM_Government_Owned__c = True;
            }
            else if(Trigger.isUpdate)
            {
                con.ICRM_Government_Owned__c = acountMap.get(con.AccountId).BPI_Government_Owned__c;
            }
        }
        
    }
}