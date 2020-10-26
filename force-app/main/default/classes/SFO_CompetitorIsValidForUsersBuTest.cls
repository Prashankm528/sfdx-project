/**************************************************************************************************************************************
* Description : Testing class for IsValidForUsersBu formula field on Competitor for ease of future maintenance.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2019-JUNE-28   1.0                Adam Janicko        Initial version
***************************************************************************************************************************************/

@isTest
public class SFO_CompetitorIsValidForUsersBuTest {
	@isTest
    static void buMatchTest() {
        //get all User Business unit picklist values
        SObjectField userBusinessUnit = SObjectType.User.fields.Business_Unit__c.getSObjectField();
		List<PicklistEntry> allBusinessUnits = userBusinessUnit.getDescribe().getPicklistValues();
        Set<String> excludedBusinessUnits = new Set<String>{'Lubricants - RKAM','Advanced Mobility Unit', 'Fuels North America', 'Fuels - Dealer','Fuels - Bitumen', 'Fuels - Cards','Fuels - Supply','Fuels - Wholesale','Global Fuels - Air Fuels','Global Fuels - Fuels Air','Lubricants - Energy','Fuels - Chemicals','Lubricants - Automotive & Industrial','Fuels - Convenience Retail','Global Fuels - LPG','Lubricants - Supply Chain'};
    	
        //filtering only the relevant business units
        List<String> relevantBusinessUnits = new List<String>();
        for(PicklistEntry entry : allBusinessUnits) {
            if(entry.isActive() && !excludedBusinessUnits.contains(entry.getValue())) {
                relevantBusinessUnits.add(entry.getValue());
            }
        }
        
        //creating test users
        Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> testUsers = new List<User>();
        for(integer i = 0; i < relevantBusinessUnits.size(); i++) {
            User user = new User(Alias = 'test'+i, Email='test'+i+'@example.castrol.com', 
                        EmailEncodingKey='UTF-8', LastName='test'+i, LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US',
                        TimeZoneSidKey='America/Los_Angeles', UserName='test'+i+'@example.castrol.com',
                        ProfileId = sysAdmin.Id,
                        Business_Unit__c = relevantBusinessUnits[i]);
            testUsers.add(user);
        }
        insert testUsers;
        
        Test.startTest();
        for(User user : testUsers) {
            System.runAs(user) {
                Competitor__c competitor = new Competitor__c(Name = 'Test', CASFO_Business_Unit__c = user.Business_Unit__c, OwnerId = user.Id);
                competitor.recalculateFormulas();
                System.assert(competitor.SFO_IsValidForUsersBu__c, 'Should have been true');
            }
        }
        Test.stopTest();
    }
    @isTest
    static void buMismatchTest() {
		User adminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];    
        adminUser.Business_Unit__c = 'Lubricants - Automotive';
        update adminUser;
        
        Test.startTest();
        Competitor__c competitor = new Competitor__c(Name = 'Test', CASFO_Business_Unit__c = 'Lubricants - Industrial');
        competitor.recalculateFormulas();
        Test.stopTest();
                                                     
        System.assert(!competitor.SFO_IsValidForUsersBu__c, 'Should have been false');                                          
    }
}