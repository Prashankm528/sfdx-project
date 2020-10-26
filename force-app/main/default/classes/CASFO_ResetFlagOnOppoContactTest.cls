/***************************************************************************************************
* Description : Unit Tests for CASFO_ResetPrimaryFlagOnOpportunityContact Process Builder and
*				Reset Primary Flag on Old Opportunity Contacts flow
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-JAN-30   1.0                 Maros Zilka     	Initial version
*
***************************************************************************************************/

@isTest
public class CASFO_ResetFlagOnOppoContactTest {
	@isTest
    static void resetFlagOnOppoContactTest() {
        Account testAccount;
        Contact testContact;
        Opportunity testOpportunity;
        CASFO_Opportunity_Contact__c testOpportunityContact;
        
        Integer numberOfPrimaryOppoContacts;
        
        testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Business_Unit__c = 'Lubricants - Automotive';
        testAccount.Sales_Organisation__c = 'UK01';

        insert testAccount;
        
        testContact = new Contact();
        testContact.FirstName = 'First';
        testContact.LastName = 'Last';
        testContact.Email = 'example@example.com';
        testContact.Home_Location__c = 'United Kingdom';
        testContact.Preferred_Language__c = 'English-British';
        testContact.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        testContact.AccountId = testAccount.Id;

        insert testContact;
        
        testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName = 'Lead';
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.CloseDate = Date.today();
        testOpportunity.Supply_Start_Date__c = Date.today();
        
        insert testOpportunity;
        
        testOpportunityContact = new CASFO_Opportunity_Contact__c();
        testOpportunityContact.CASFO_Contact__c = testContact.Id;
        testOpportunityContact.CASFO_Opportunity__c = testOpportunity.Id;
        testOpportunityContact.CASFO_Primary_Contact__c = true; 
        
        insert testOpportunityContact;
        
        numberOfPrimaryOppoContacts = [SELECT Id 
                                       FROM CASFO_Opportunity_Contact__c 
                                       WHERE CASFO_Primary_Contact__c = true
                                      ].size();
        
        // Initial test
        system.assert(numberOfPrimaryOppoContacts == 1);
        
        testOpportunityContact = new CASFO_Opportunity_Contact__c();
        testOpportunityContact.CASFO_Contact__c = testContact.Id;
        testOpportunityContact.CASFO_Opportunity__c = testOpportunity.Id;
        testOpportunityContact.CASFO_Primary_Contact__c = true; 
        
        insert testOpportunityContact;
        
        numberOfPrimaryOppoContacts = [SELECT Id 
                                       FROM CASFO_Opportunity_Contact__c 
                                       WHERE CASFO_Primary_Contact__c = true
                                      ].size();
        
        // We should still have only one primary contact
        system.assert(numberOfPrimaryOppoContacts == 1);
    }
}