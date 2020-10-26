/**
 * @author			Venkatesh Muniyasamy
 * @date			30/01/2020
 * @group			CAJBP
 * @description		Test class for CAJBP_Objective Trigger
 *
 * history
 * 30/01/2020	Venkatesh Muniyasamy		Created
 */
@isTest (seeAllData=false)
public with sharing class CAJBP_ScorecardTriggerHandlerTest
{
    Static String scorecardCurrency;
    @isTest
    public static void testScorecardJbpCurrency()
    {
        CAJBP_Joint_Business_Plan__c jbp = [SELECT Id, Name,CurrencyisoCode, (SELECT id,name,currencyisocode FROM CAJBP_Scorecards__r) FROM CAJBP_Joint_Business_Plan__c WHERE CurrencyisoCode = 'EUR' Limit 1];

        for(CAJBP_Scorecard__c score : jbp.CAJBP_Scorecards__r)
        {
            scorecardCurrency = score.CurrencyIsoCode;
        }

        system.assertEquals(jbp.CurrencyIsoCode, scorecardCurrency,'Scorecard currency is not updated correctly');
    }

    @TestSetup
    static void makeData()
    {
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
    }
}