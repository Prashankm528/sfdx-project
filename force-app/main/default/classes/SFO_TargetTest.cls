/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    Test the SFO Target object   
****************************************************************************************/

/* SeeAllData = false */
/* individual method can set SeeAllData = true */

@isTest
private class SFO_TargetTest
{
	/*
		Test: SFO_TargetService.setTargetKey() 
		Test: SFO_TargetService.processOpportunityOnTargetAfterInsert() 
		Test: SFO_TargetService.processOpportunityOnTargetAfterUpdate() 
		Test: SFO_TargetTriggerHandler.cls  
		Test: SFO_TargetTrigger.trigger 
		Test: SFO_OpportunityTargetService.setOpportunityTarget()
		Test: SFO_AccountService.getSfoAccountListByRecordTypeDeveloperName()
		Test: SFO_AccountService.getSfoAccountList()
		Test: SFO_AccountService.setSfoAccountFieldsBeforeInsert()
		Test: SFO_AccountService.setSfoCustomerAccountFieldsBeforeInsert()
		Test: SFO_AccountService.setSfoProspectAccountFieldsBeforeInsert()
	*/      
    @isTest 
	private static void SFO_TargetService_Test()
    {
		User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
		insert testCastrolUser;

        System.runAs(testCastrolUser) 
		{
			Account castrolAcc = SFO_TestDataService.createCustomerAccount();
			castrolAcc.Channel__c = 'VW6';
			insert castrolAcc;

			Contact testContact = SFO_TestDataService.createContact(castrolAcc.Id);
			insert testContact;

			Date opportunityCloseDate1 = Date.today().addDays(33);
			string generatedQuarter1 = String.valueOf(Math.ceil(opportunityCloseDate1.month() / 3.0));

			Test.startTest();

            List<Opportunity> opportunityList = new List<Opportunity>();

			Opportunity castrolOpp1 = SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id);
			castrolOpp1.Name = 'Test Opportunity Target';
			castrolOpp1.StageName = 'Lead';
			castrolOpp1.CloseDate = opportunityCloseDate1;

			Date opportunityCloseDate2 = Date.today().addDays(133);
			string generatedQuarter2 = String.valueOf(Math.ceil(opportunityCloseDate2.month() / 3.0));

			Opportunity castrolOpp2 = SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id);
			castrolOpp2.Name = 'Test Opportunity Target';
			castrolOpp2.StageName = 'Lead';
			castrolOpp2.CloseDate = opportunityCloseDate2;

            opportunityList.add(castrolOpp1);
            opportunityList.add(castrolOpp2);
			insert opportunityList;

			SFO_Target__c target = SFO_TestDataService.createTarget(castrolAcc, String.valueOf(opportunityCloseDate1.year()), generatedQuarter1);
			insert target;

			castrolOpp1 = [select id, CASFO_Target__c, accountId, closedate from Opportunity where id = :castrolOpp1.Id];
			System.assertEquals(target.Id, castrolOpp1.CASFO_Target__c, 'Fail to set Opportunity Target');

            target.SFO_Year__c = String.valueOf(opportunityCloseDate2.year());
            target.SFO_Quarter__c = generatedQuarter2;
			update target;

			castrolOpp2 = [select id, CASFO_Target__c, accountId, closedate from Opportunity where id = :castrolOpp2.Id];
			System.assertEquals(target.Id, castrolOpp2.CASFO_Target__c, 'Fail to set Opportunity Target');

			Test.stopTest();
        }
        
    }    
}