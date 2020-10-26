/******************************************************************************************
 *  Date          : 27-JUN-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Account_Trigger
 * Modifications  : 27-JUN-2019 SYAP - Initial
 ******************************************************************************************/
@isTest
public with sharing class GCM_Account_Trigger_Test 
{
  static String getRecordTypeIdHelper(String objectName, String recordType) {
    RecordType[] recordTypes = [select Id from RecordType where DeveloperName = :recordType AND sObjectType = :objectName limit 1];
    for (RecordType thisRecordType : recordTypes) {
      return thisRecordType.Id;
    }
    return null;
  }

  public testMethod static void updateAccountServExpLevelTest(){
	// Create New Account
	Account insertAccount = new Account();
	insertAccount.Name = 'Test Account';
	insertAccount.Sales_Organisation__c = 'AU0A';
	insertAccount.Application_ID__c = '019';
	insertAccount.Business_Unit__c = 'Fuels - Dealer';
	insertAccount.Sales_Division_Code__c = '01';
	insertAccount.Sales_Distribution_Channel__c = '04';
	insertAccount.Service_Experience_Level__c = 'PL Platinum';
	String recordTypeId = getRecordTypeIdHelper('Account', 'Customer');
	System.assert(recordTypeId != null, 'Record Type Not Found');
	insertAccount.RecordTypeId = recordTypeId;
	insert insertAccount;

	insertAccount.Service_Experience_Level__c='SL Silver';
	update insertAccount;
  }
  
  @isTest static void createAccount() {
    // Create New Account
    Account insertAccount = new Account();
    insertAccount.Name = 'Test Account';
    insertAccount.Sales_Organisation__c = 'MX02';
    insertAccount.Business_Unit__c = 'Fuels - Dealer';
    insertAccount.Sales_Division_Code__c = '01';
    insertAccount.Sales_Distribution_Channel__c = '04';
    String recordTypeId = getRecordTypeIdHelper('Account', 'Prospect');
    System.assert(recordTypeId != null, 'Record Type Not Found');
    insertAccount.RecordTypeId = recordTypeId;
    insert insertAccount;
    
    // Assert If Account Is Shared
    List<AccountShare> shareList = [select Id from AccountShare where AccountId = :insertAccount.Id and RowCause = 'Manual'];
    System.assert(shareList.size() > 0, 'Account Not Shared');
    
    // Assert If Entitlement Is Created
    List<Entitlement> entitlements = [select Id from Entitlement where AccountId = :insertAccount.Id];
    System.assert(shareList.size() > 0, 'Entitlement Not Created');
    
    // Update Account
    Account updateAccount = new Account();
    updateAccount.Id = insertAccount.Id;
    updateAccount.Sales_Organisation__c = 'XX01';
    update updateAccount;
    
    // Assert If Account Share Is Removed
    shareList = [select Id from AccountShare where AccountId = :insertAccount.Id and RowCause = 'Manual'];
    System.assert(shareList.size() == 0, 'Account Share Not Deleted');

    // Assert If Entitlement Is Expired
    entitlements = [select Id from Entitlement where AccountId = :insertAccount.Id and Status = 'Active'];
    System.assert(shareList.size() == 0, 'Entitlement Not Expired');    
  }
}