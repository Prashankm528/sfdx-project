/****************************************************************************************************
 *  Date          : 6-MAR-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Query
 * Modifications  : 6-MAR-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Query_Test
{
/****************************************************************************************************
  Test Query Nested
 ****************************************************************************************************/
    @isTest static void testQueryNested() {
        Test.startTest();

        // Create Account
        Account newAccount = new Account();
        newAccount.Name = 'Test';
        insert newAccount;

        // Create Related Account
        Account relatedAccount = new Account();
        relatedAccount.Name = 'Test Related';
        insert relatedAccount;
        
        // Create Contact
        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Test';
        newContact.AccountId = newAccount.Id;
        insert newContact;
        
        // Insert Contact Relation
        AccountContactRelation relation = new AccountContactRelation();
        relation.AccountId = relatedAccount.Id;
        relation.ContactId = newContact.Id;
        insert relation;
        
        String soql = 'select AccountId, Account.Name from AccountContactRelation where ContactId in {!IdList}';
        String subsoql = 'select ContactId from AccountContactRelation where AccountId = \'{!Id}\'';
		List<SObject> records = GCM_Query.queryNested(newAccount.Id, soql, subsoql, 'ContactId');
        System.assert(records.size() > 0, 'Results Returned');

		// Test Simple Query        
        soql = 'select Id from Contact where Id = \'{!Id}\'';
        records = GCM_Query.query(newContact.Id, soql);
        System.assert(records.size() > 0, 'Results Returned');
        
        Test.stopTest();
    }

/****************************************************************************************************
  Test Query Nested
 ****************************************************************************************************/
    @isTest static void testGetValueSet() {
        Test.startTest();
        List<Map<String, String>> valueSet = GCM_Query.getValueSet('Account', 'Type');
        System.assert(valueSet.size() > 0, 'Value Set Returned');
        Test.stopTest();
    }
    
/****************************************************************************************************
  Test Get Time Zone Offset
 ****************************************************************************************************/
    @isTest static void testGetTimeZoneOffset() {
        Test.startTest();
        Object offset = (Object) GCM_Query.getTimeZoneOffset();
        System.assert(offset instanceof Integer, 'Number Returned');
        String userOffset=GCM_Query.getTimeZoneName();
        Test.stopTest();
    }
    
/****************************************************************************************************
  Test Query API
 ****************************************************************************************************/
    @isTest static void testQueryAPI() {
        Test.startTest();
        String result = GCM_Query.queryAPI('Test');
        System.assert(result == '', 'Method Called');
        Test.stopTest();
    }
}