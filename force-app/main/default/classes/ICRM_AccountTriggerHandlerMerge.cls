/* @author            Utkarsh Gupta
*  @date              15th July, 2019
*  @description       handles trigger events on Account object for IST CRM Project
*  ----------------------------------
*  Updated on - 30th Oct 2019
*  Changed by - Santosh Verma
*  Details    - Added logic to generate prospect id from custom setting, it is applicable only for IST_prospect record type
* ------------------------------------
* Updated on - 06th Dec 2019
*  Changed by - Karishma Gurjar
*  Details    - 683271: Add "Government" field on Contact record; have data flow from Acct Govt. field to Contact Govt. field
*  ----------------------------------
*  Updated on - 26th Feb 2020
*  Changed by - Santosh Verma
*  Details    - added filter to prevent CS update
*/
public with sharing class ICRM_AccountTriggerHandlerMerge extends BPG_Trigger_Handler_Utilities{
    
    // public static boolean stopUpdate = false;
    
    /*@Description
* handle Before Insert for IST CRM for Accounts to merge Accounts with Record Type 'IST Prospect' with Recort Type 'IST Legal Entity' 
*/
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        /* before insert method */ 
        
        //-------------Get the latest CS value -------------------
        
        Integer prospectId = 0; 
        // Get value from custom setting  
        ICRM_AccProspectID__c CS_locProsId = ICRM_AccProspectID__c.getValues('ACCPROSPECTID');   
        system.debug('CS value '+CS_locProsId);
        
        // Check for null to avoid any issue 
        If(CS_locProsId != Null){
            system.debug('Prospect ID 1= ' +prospectId); 
            prospectId = integer.valueOf(CS_locProsId.ICRM_AProspectID__c); 
            system.debug('Prospect ID 2= ' + prospectId); 
        }
        //--------------------------------
        
        Id accountRecordTypeLEId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();
        Id accountRecordTypeProsId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId(); 
        Set<Account> legalEntityIds = new Set<Account>();
        Set<String> sourceProspects = new Set<String>();
        Set<Id> propspectIds = new Set<Id>();
        List<Account> castLEAccountRecs = new List<Account>();      
        castLEAccountRecs = n;
        String CSUpdate = 'NO';
        
        for(Account acc : castLEAccountRecs) {
            system.debug('acc : '+acc);
            if(acc.RecordTypeId == accountRecordTypeLEId && acc.ICRM_Prospect_ID__c != NULL){
                legalEntityIds.add(acc);
                sourceProspects.add(acc.ICRM_Prospect_ID__c);
            }
            
            // populate prospect_id field for account from CS + 1
            If (acc.RecordTypeId == accountRecordTypeProsId && acc.ICRM_Prospect_ID__c == NULL) 
            { 
                prospectId = prospectId + 1;   // CS value increment 
                CSUpdate = 'YES';
                acc.ICRM_Prospect_ID__c = string.valueOf(prospectId);
            } 
            
        }
        
        for(Account acc : [SELECT ICRM_Prospect_ID__c FROM Account WHERE recordTypeId =: accountRecordTypeProsId AND ICRM_Prospect_ID__c IN: sourceProspects]) {
            propspectIds.add(acc.Id);            
        }
        ICRM_AccountTriggerHandlerMerge.updateAccountsBeforeMerge(propspectIds, legalEntityIds);
        
        //update the custom setting with latest value 
        If(CS_locProsId != Null && CSUpdate == 'YES'){   
            CS_locProsId.ICRM_AProspectID__c = prospectId; 
            Update  CS_locProsId ;
            CSUpdate = 'NO';
            system.debug('Current value updated in CS = '+ CS_locProsId.ICRM_AProspectID__c); 
        }
        
    }
    
    /*@Description
* handle Before Update for IST CRM for Accounts to merge Accounts with Record Type 'IST Prospect' with Recort Type 'IST Legal Entity' 
*/
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        Id accountRecordTypeLEId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();                
        Id accountRecordTypeProsId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        Set<Account> legalEntityIds = new Set<Account>();
        Set<String> sourceProspects = new Set<String>();
        Set<Id> propspectIds = new Set<Id>();
        List<Account> castLEAccountRecs = new List<Account>();      
        castLEAccountRecs = n;
        for(Account acc : castLEAccountRecs) {
            if(acc.recordTypeId == accountRecordTypeLEId && acc.ICRM_Prospect_ID__c != NULL){
                legalEntityIds.add(acc);
                sourceProspects.add(acc.ICRM_Prospect_ID__c);
            } 
            System.debug('acc : '+acc.ICRM_Prospect_ID__c);
        }
        
        for(Account acc : [SELECT Id, ICRM_Prospect_ID__c FROM Account WHERE recordTypeId =: accountRecordTypeProsId AND ICRM_Prospect_ID__c IN: sourceProspects]) {
            propspectIds.add(acc.Id);            
        }
        
        system.debug('existingIds-'+propspectIds);
        // stopUpdate = true;
        // system.debug('stopUpdate:-'+stopUpdate);
        ICRM_AccountTriggerHandlerMerge.updateAccountsBeforeMerge(propspectIds, legalEntityIds);
        
    }
    
    /*@Description
* handle After Insert for IST CRM for Accounts to merge Accounts with Record Type 'IST Prospect' with Recort Type 'IST Legal Entity' 
*/
    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        //        if(stopUpdate) return;
        
        Id accountRecordTypeLEId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();                
        Id accountRecordTypeProsId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        Set<Id> legalEntityIds = new Set<Id>();
        Set<String> sourceProspects = new Set<String>();
        Set<Id> propspectIds = new Set<Id>();
        List<Account> castLEAccountRecs = new List<Account>();      
        castLEAccountRecs = n;
        
        for(Account acc : castLEAccountRecs) {
            system.debug('acc : '+acc);
            if(acc.RecordTypeId == accountRecordTypeLEId && acc.ICRM_Prospect_ID__c != NULL){
                legalEntityIds.add(acc.Id);
                sourceProspects.add(acc.ICRM_Prospect_ID__c);
            }
        }
        
        for(Account acc : [SELECT ICRM_Prospect_ID__c FROM Account WHERE recordTypeId =: accountRecordTypeProsId AND ICRM_Prospect_ID__c IN: sourceProspects]) {
            propspectIds.add(acc.Id);            
        }
        //        stopUpdate = true;
        ICRM_AccountTriggerHandlerMerge.mergeAccount(propspectIds, legalEntityIds);
        
        
        
    }
    
    /*@Description
* handle After update for IST CRM for Accounts to merge Accounts with Record Type 'IST Prospect' with Recort Type 'IST Legal Entity' 
*/
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        //        if(stopUpdate) return;
        
        Id accountRecordTypeLEId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Legal Entity').getRecordTypeId();                
        Id accountRecordTypeProsId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        Set<Id> legalEntityIds = new Set<Id>();
        Set<String> sourceProspects = new Set<String>();
        Set<Id> propspectIds = new Set<Id>();
        List<Account> castLEAccountRecs = new List<Account>();    
        Map<Id,Account> AccMaptoUpdateContact = new Map<Id,Account>();		
        castLEAccountRecs = n;
        for(Account acc : castLEAccountRecs) {
            if(acc.recordTypeId == accountRecordTypeLEId && acc.ICRM_Prospect_ID__c != NULL){
                
                legalEntityIds.add(acc.Id);
                sourceProspects.add(acc.ICRM_Prospect_ID__c);
            } 
            // To Populate Government Owned field on associated Contacts
            if(acc.recordTypeId == accountRecordTypeLEId || acc.recordTypeId == accountRecordTypeProsId){
                if(acc.BPI_Government_Owned__c != ((Account)oMap.get(acc.id)).BPI_Government_Owned__c)
                {
                    
                    AccMaptoUpdateContact.put(acc.id,acc);
                }
            }
        }
        if(!AccMaptoUpdateContact.isEmpty()){
            updateGovernmentOnContact(AccMaptoUpdateContact);
        }
 
        for(Account acc : [SELECT Id, ICRM_Prospect_ID__c FROM Account WHERE recordTypeId =: accountRecordTypeProsId AND ICRM_Prospect_ID__c IN: sourceProspects]) {
            propspectIds.add(acc.Id);            
        }
        //        stopUpdate = true;
        ICRM_AccountTriggerHandlerMerge.mergeAccount(propspectIds, legalEntityIds);
        
        
        
    }
    
    /*@Description
* To merge the existing Account with Record Type 'IST Prospect' with The accounts with Record Type 'IST Legal Entity' 
*/
    
    public static void mergeAccount(Set<Id> propspectIds, Set<Id> legalEntityIds) {
        system.debug('existingIds:-'+propspectIds);
        system.debug('newIds:-'+legalEntityIds);
        Account acct;
        String fields = 'Id, ICRM_Prospect_ID__c, recordTypeId, BPI_GOA_Auth_Date__c';
        Map<String, Account> mapAccProsIdAcc = new Map<String, Account>();
        for(Account acc: database.query('Select '+fields+' from Account where Id IN :propspectIds')){
            if(acc.ICRM_Prospect_ID__c != NULL){
                mapAccProsIdAcc.put(acc.ICRM_Prospect_ID__c, acc);
            }
        }
        system.debug('mapAccProsIdAcc'+mapAccProsIdAcc);
        for(Account acc : database.query('Select '+fields+' from Account where Id IN :legalEntityIds')){      
            system.debug('acc : '+acc);  
            if(mapAccProsIdAcc.get(acc.ICRM_Prospect_ID__c) != Null){
                acct = mapAccProsIdAcc.get(acc.ICRM_Prospect_ID__c); 
            }
            System.debug('acc.ICRM_Prospect_ID__c : '+acc.ICRM_Prospect_ID__c);
            System.debug('mapAccProsIdAcc : '+mapAccProsIdAcc);
            System.debug('acct : '+acct);
            
            if(acct != Null){
                merge acc acct;
            }
            
        }
        
    }
    
    /*@Description
* To update the new Account with Record Type 'IST Legal Entity' with The accounts with Record Type 'IST Prospect Account' values before merge 
*/
    
    public static void updateAccountsBeforeMerge(Set<Id> propspectIds, Set<Account> legalEntityIds) {
        
        List<String> fieldSet = new List<String>();
        ICRM_Merge_Fields__mdt[] allFields = [SELECT Field_API_Name__c, sObject_Name__c FROM ICRM_Merge_Fields__mdt WHERE sObject_Name__c = 'Account'];
        for(ICRM_Merge_Fields__mdt md : allFields){
            fieldSet.add(md.Field_API_Name__c);
        }
        
        string allstring = string.join(fieldSet,',');
        
        Account acct;
        List<Account> lstAccount = new List<Account>();
        Map<String, Account> mapAccProsIdAcc = new Map<String, Account>();
        for(Account acc: database.query('Select '+allstring+' from Account where Id IN :propspectIds')){
            if(acc.ICRM_Prospect_ID__c != NULL){
                mapAccProsIdAcc.put(acc.ICRM_Prospect_ID__c, acc);
            }
        }
        
        Map<sObject,sObject> leAndProsMap = new Map<sObject,sObject>();
        for(Account acc : legalEntityIds){         
            if(mapAccProsIdAcc.get(acc.ICRM_Prospect_ID__c) != Null){
                acct = mapAccProsIdAcc.get(acc.ICRM_Prospect_ID__c); 
            }
            leAndProsMap.put(acc,acct);        
        }
        
        ICRM_AssignValueIfNotNull.assignIfNotNull(leAndProsMap,fieldSet);
    }
    
    public static void updateGovernmentOnContact(Map<Id,Account> AccMaptoUpdateContact) {
        // To Populate Government Owned field on associated Contacts
        List<Contact> ContactListToUpdate = new List<Contact>();
        for(Contact con : [SELECT Id,ICRM_Government_Owned__c,AccountId from Contact where AccountId in:AccMaptoUpdateContact.keyset()]){
            if(AccMaptoUpdateContact.containskey(con.AccountId) && con.ICRM_Government_Owned__c != AccMaptoUpdateContact.get(con.AccountId).BPI_Government_Owned__c)
            {
                con.ICRM_Government_Owned__c = AccMaptoUpdateContact.get(con.AccountId).BPI_Government_Owned__c;
                ContactListToUpdate.add(con);
            }
            
        }
		
        Update ContactListToUpdate;
    }
    
}