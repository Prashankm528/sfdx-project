/**
 * @author			Venkatesh Muniyasamy
 * @date			28/01/2020
 * @group			CAJBP
 * @description		Test class for CAJBP_Objective Trigger
 *
 * history
 * 28/01/2020	Venkatesh Muniyasamy		Created
 */
@isTest (seeAllData=false)
public with sharing class CAJBP_ObjectiveTriggerHandlerTest
{
    @isTest
    public static void testObjectiveJBPCurrency()
    {
        CAJBP_Joint_Business_Plan__c jbp = [SELECT Id, Name,CurrencyisoCode FROM CAJBP_Joint_Business_Plan__c WHERE CurrencyisoCode = 'EUR' Limit 1];

        Test.startTest();
            CAJBP_Objective__c objective = CAJBP_TestFactory.createObjective(jbp.Id);
        Test.stopTest();

        String objectiveCurrency = [SELECT Id, CurrencyisoCode FROM CAJBP_Objective__c WHERE Id =: objective.Id Limit 1].CurrencyIsoCode;

        system.assertEquals(jbp.CurrencyIsoCode, objectiveCurrency,'Object currency is not updated correctly');

        delete objective;
    }

    @TestSetup
    static void makeData()
    {
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
        system.debug('JBP is ' + jbp.Name);
    }
}