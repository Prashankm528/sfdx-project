/****************************************************************************************************
 *  Date          : 25-JUL-2019
 *  Author        : Sunny Yap
 *  Description   : Helper class for GCM Account Trigger.
 *  Modifications : 25-JUN-2019 SYAP - Initial.
 *                  26-JUN-2019 SYAP - Enable multiple public groups to be assigned to
 *                                     each criteria.
 *                                     Bulkified creation and retirement of entitlements.
 *                  27-JUN-2019 SYAP - Limited scope of execution (execute only when
 *                                     fields affecting the assignment have changed).
 *                                     Fixed errors caused by infinite recursion.
 *                                     Added error handling.
 *                  10-AUG-2019 SYAP - Default logic for SEL.
 ****************************************************************************************************/

public with sharing class GCM_Account_Trigger_Helper {
    
    //Created By: Prasad Kulkarni
    //Description: 1256982 : ANZ Lubes & Fuels : SEL logic for Updates Accounts in Salesforce
    public static void updateAccountServExpLevel(List<Account> newAccounts, Map<Id, Account> oldAccountsMap, Map<Id, Account> newMap){
        Set<String> servExpLevelSet = new Set<String>{'PL Platinum','GD Gold'};
        for(Account account :newAccounts){
            if(((account.Sales_Organisation__c=='AU0A' || account.Sales_Organisation__c=='NZ0A' || account.Sales_Organisation__c=='IB01') && account.Application_ID__c=='019') || ((account.Sales_Organisation__c=='AU0A' || account.Sales_Organisation__c=='NZ0A') && account.Application_ID__c=='018')){
                Id customerAccRecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
                Account oldAccount=(Account)oldAccountsMap.get(account.Id);
                if(account.RecordTypeId==customerAccRecTypeId && account.Service_Experience_Level__c!=null && account.Service_Experience_Level__c!=oldAccount.Service_Experience_Level__c && servExpLevelSet.contains(oldAccount.Service_Experience_Level__c)){
                    account.Service_Experience_Level__c=oldAccount.Service_Experience_Level__c;
                }   
            }
        }
    }
    
/****************************************************************************************************
  Automatically Create Account Entitlement If Matching Entitlement Process Found
  Naming Convention For Entiitlement Process = GCM_<Sales Organisation>_<Business Unit> 
 ****************************************************************************************************/
  public static void createEntitlement(List<Account> accounts, Map<Id, Account> oldMap, Map<Id, Account> newMap, Boolean isInsert) {
    try {
      // Find In Scope Accounts
      Set<Id> accountSet = new Set<Id>();
      if (!isInsert) {
        for (Account thisAccount : accounts) {
          // In Scope If Sales Organisation OR Business Unit Have Changed
          if (thisAccount.Sales_Organisation__c != null && thisAccount.Business_Unit__c != null) {
            if (oldMap.get(thisAccount.Id).Sales_Organisation__c != thisAccount.Sales_Organisation__c || oldMap.get(thisAccount.Id).Business_Unit__c != thisAccount.Business_Unit__c) {
              accountSet.add(thisAccount.Id);
            }
          }
        }
      }
      else {
        // Entire Record Set In Scope For Insert Operation
        accountSet = newMap.keySet();
      }

      // Sales Organisation OR Business Unit Changes Triggers Other Automation (Outside GCM)
      // The Following Line Prevents Infinite Recursion
      if (accountSet.size() == 0) return;
    
      // Initialise Entitlement Process Map
      Map<String, Id> processMap = new Map<String, Id>();
      for (Account thisAccount : accounts) {
        String key = 'GCM' + '_' + thisAccount.Sales_Organisation__c + '_' + thisAccount.Business_Unit__c;
        processMap.put(key, null);
      }
      
      // Get Entitlement Process Map
      List<SlaProcess> processes = [select Id, Name from SlaProcess where Name in :processMap.keySet() and IsActive = true and IsVersionDefault = true];
      for (SlaProcess process : processes) {
        processMap.put(process.Name, process.Id);
      }
    
      Map<String, Id> entitlementMap = new Map<String, Id>();
      List<Entitlement> existingEntitlements = [select Id, AccountId, Name from Entitlement where Name like 'GCM%' and Status = 'Active' and AccountId in :accountSet];
      List<Entitlement> entitlementsToUpdate = new List<Entitlement>();
      for (Entitlement thisEntitlement : existingEntitlements) {
        entitlementMap.put(thisEntitlement.AccountId + '_' + thisEntitlement.Name, thisEntitlement.Id);
        Entitlement entitlementToUpdate = new Entitlement();
      
        // Inactivate Current Entitlement
        entitlementToUpdate.Id = thisEntitlement.Id;
        entitlementToUpdate.EndDate = Date.today().addDays(-1);
        entitlementsToUpdate.add(entitlementToUpdate);
      }
      if (entitlementsToUpdate.size() > 0) update entitlementsToUpdate;
     
      // Create Entitlement
      List<Entitlement> entitlements = new List<Entitlement>();
      for (Account thisAccount : accounts) {
        String key = 'GCM' + '_' + thisAccount.Sales_Organisation__c + '_' + thisAccount.Business_Unit__c;
        if (!entitlementMap.containsKey(thisAccount.Id + '_' + key)) {
          if (processMap.containsKey(key)) {
            if (processMap.get(key) != null) {
              Entitlement entitlement = new Entitlement();
              entitlement.AccountId = thisAccount.Id;
              entitlement.Name = key;
              entitlement.SlaProcessId = processMap.get(key);
              entitlement.StartDate = Date.today().addDays(-1);
              entitlements.add(entitlement);
            }
          }
        }
      }
      if (entitlements.size() > 0) insert entitlements;
    } catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Account_Trigger_Helper', 'createEntitlement', newMap.keySet(), 'GCM_Application_Administrator');
    }
  }

/****************************************************************************************************
  Set Default SEL If Blank
 ****************************************************************************************************/
  public static void setDefaultSEL(List<Account> accounts, Map<Id, Account> oldMap, Map<Id, Account> newMap) {
    try {
      // Get Valid Record Type
      Set<Id> accountRecordTypes = new Set<Id>();
      accountRecordTypes.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId());

      // Get Valid Person Account Id
      String personAccountSOQL = 'select Id from RecordType where SObjectType = \'Account\' and IsPersonType = true and DeveloperName = \'GCM_Person_Account\'';
      RecordType personAccountRT = (RecordType) BPG_Error_Logger.queryFirstRecord(personAccountSOQL);
      if (personAccountRT != null) accountRecordTypes.add(personAccountRT.Id);
      
      //GME Europe - 1338497 - Roselin Hephzibah
      Set<Id> custAccountRecordTypes = new Set<Id>();
      custAccountRecordTypes.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
      
      // Find In Scope Accounts
      Map<Id, Account> accountMap = new Map<Id, Account>();
      for (Account thisAccount : accounts) {
        if (accountRecordTypes.contains(thisAccount.RecordTypeId)) {
          if (String.isBlank(thisAccount.Service_Experience_Level__c)) {
            thisAccount.Service_Experience_Level__c = 'SL Silver';
          }
        } 
        
        //GME Europe - 1338497 - Roselin Hephzibah
        if (custAccountRecordTypes.contains(thisAccount.RecordTypeId)) {
          if (String.isBlank(thisAccount.Service_Experience_Level__c) && thisAccount.Application_ID__c=='020') {
            thisAccount.Service_Experience_Level__c = 'Unallocated';
          }
        }
      }
  
    } catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Account_Trigger_Helper', 'setDefaultSEL', newMap.keySet(), 'GCM_Application_Administrator');
    }
  }   
}