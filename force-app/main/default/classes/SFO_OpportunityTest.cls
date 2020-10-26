/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    Test the SFO Opportunity   
****************************************************************************************/

/* SeeAllData = false */
/* individual method can set SeeAllData = true */

@isTest 
private class SFO_OpportunityTest
{
	/*
		Test: SFO_OpportunityTargetService.setOpportunityTargetOnInsert() 
		Test: SFO_OpportunityTargetService.setOpportunityTargetOnUpdate() 
		Test: SFO_OpportunityTargetService.setOpportunityTarget() 
		Test: SFO_OpportunityTriggerHandler.cls 
		Test: OpportunityTrigger.trigger
	*/      
    @isTest 
	private static void SFO_OpportunityTargetService_Test()
    {
		User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
		insert testCastrolUser;

        System.runAs(testCastrolUser) 
		{
			Account castrolAcc = SFO_TestDataService.createCustomerAccount();
			insert castrolAcc;

			Contact testContact = SFO_TestDataService.createContact(castrolAcc.Id);
			insert testContact;

			Date opportunityCloseDate = Date.today().addDays(33);
			string generatedQuarter = String.valueOf(Math.ceil(opportunityCloseDate.month() / 3.0));

			Test.startTest();

			SFO_Target__c target = SFO_TestDataService.createTarget(castrolAcc, String.valueOf(opportunityCloseDate.year()), generatedQuarter);
			insert target;

			target = [SELECT Id, SFO_Account__c, SFO_Year__c, SFO_Quarter__c, SFO_Key__c FROM SFO_Target__c WHERE Id = :target.Id];
			System.assertEquals(castrolAcc.Id + '#' +  target.SFO_Year__c + '#' + target.SFO_Quarter__c, target.SFO_Key__c, 'Exspected key not match with Target record key');

			Opportunity castrolOpp = SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id);
			castrolOpp.Name = 'Test Opportunity Target';
			castrolOpp.StageName = 'Lead';
			castrolOpp.CloseDate = opportunityCloseDate;
			insert castrolOpp;

			castrolOpp = [select id, CASFO_Target__c, accountId, closedate from Opportunity where id = :castrolOpp.Id];
			System.assertEquals(target.Id, castrolOpp.CASFO_Target__c, 'Fail to set Opportunity Target');

			/* set Opportunity.CloseDate to in next quarter then previously set */
			Date updatedOpportunityCloseDate = Date.today().addDays(300);
			string updatedQuarter = String.valueOf(Math.ceil(updatedOpportunityCloseDate.month() / 3.0));
			
			/* created new Target for updated Opportunity.CloseDate */
			SFO_Target__c targetForUpdatedOpportunity = SFO_TestDataService.createTarget(castrolAcc, String.valueOf(updatedOpportunityCloseDate.year()), updatedQuarter);
			insert targetForUpdatedOpportunity;

			castrolOpp.CloseDate = updatedOpportunityCloseDate;
			update castrolOpp;

			Test.stopTest();
        }
        
    }    
}