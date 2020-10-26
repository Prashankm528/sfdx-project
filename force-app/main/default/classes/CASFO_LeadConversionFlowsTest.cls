/***************************************************************************************************
* Description : Unit Tests for lead related process builder flows.
*				- CASFO_PopulateSalesOrgWhenBlankOnLead
*				- CASFO_AssociateContactToOpportunityAfterLeadConversion
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-FEB-21   1.0                 Maros Zilka     	Initial version
*
***************************************************************************************************/

@isTest
public class CASFO_LeadConversionFlowsTest {
	
    @testSetup static void setup() {
        User testUser = new User();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'Castrol_UK_IR_FWS_Sales'];
        
        testUser.Username = 'test.SetOwnerOfAccountTest@test.com';
        testUser.FirstName = 'Test';
        testUser.LastName = 'SetOwnerOfAccountTest';
        testUser.Email = 'test.SetOwnerOfAccountTest@test.com';
        testUser.NTID__c = 'testNTID';
        testUser.Alias = 'testSFO';
        testUser.TimeZoneSidKey = 'Europe/London';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LocaleSidKey = 'en_GB';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Sales_Organisation__c = 'UK01';
        testUser.ProfileId = p.Id;
        testuser.UserRoleId = r.Id;
        
        insert testUser;     
    }

    @isTest
    static void populateSalesOrgWhenBlankOnLead() {
        User u = [SELECT Id, Sales_Organisation__c FROM User WHERE Alias = 'testSFO'];
        
        Lead l = new Lead();
        
        l.Title = 'Test';
        l.LastName = 'Testing';
		l.OwnerId = u.Id;
        l.CASFO_Sales_Organisation__c = '';
        l.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE DeveloperName = 'General_Lead' AND SobjectType = 'Lead' LIMIT 1].Id;
        
        insert l;
        
        Lead result = [SELECT Id, CASFO_Sales_Organisation__c FROM Lead WHERE Title = 'Test'];
        
        system.assert(
            result.CASFO_Sales_Organisation__c == u.Sales_Organisation__c,
            'Lead should have Sales Org set according owners Sales Org'
        );
    }
    
    @isTest
    static void associateContactToOpportunityAfterLeadConversion() {
        Lead l = new Lead();
        
        l.Title = 'Test';
        l.FirstName = 'First';
        l.LastName = 'Last';
        l.Company = 'Acme corp.';
        l.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE DeveloperName = 'General_Lead' AND SobjectType = 'Lead' LIMIT 1].Id;
        insert l;
        
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(l.id);

		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel = 'Qualified'];
		lc.setConvertedStatus(convertStatus.MasterLabel);

		Database.LeadConvertResult lcr = Database.convertLead(lc);
		
        System.assert(lcr.isSuccess());
        
        List<CASFO_Opportunity_Contact__c> oppoContacts = [SELECT Id FROM CASFO_Opportunity_Contact__c];
                
        System.assert(
            oppoContacts.size() == 1,
            'There should be exactly one CASFO_Opportunity_Contact__c record.'
        );
    }
}