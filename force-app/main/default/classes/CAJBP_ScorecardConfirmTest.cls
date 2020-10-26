/**
 * @author			Venkatesh Muniyasamy
 * @date			24/04/2020
 * @group			CAJBP
 * @description		Test Class for YTD Month Field Validation and Update.
 *
 * history
 * 27/04/2020 	Venkatesh Muniyasamy	Created
 */
@isTest
public with sharing class CAJBP_ScorecardConfirmTest
{
    @isTest
    public static void testYTDValidation()
    {
        Boolean ytdResult;
        Id jbpId = [SELECT id FROM CAJBP_Joint_Business_Plan__c LIMIT 1].id;

        Test.startTest();
            ytdResult = CAJBP_ScorecardConfirm.confirmYTDMonth(jbpId);
        Test.stopTest();
        system.assertEquals(true, ytdResult, 'YTD Validation is not correct');
    }

    @isTest
    public static void testYTDUpdate()
    {
        String scoreCardYTDMonth;
        Id jbpId = [SELECT id FROM CAJBP_Joint_Business_Plan__c LIMIT 1].id;

        Test.startTest();
            scoreCardYTDMonth = CAJBP_ScorecardConfirm.updateYTDMonth(jbpId);
        Test.stopTest();

        system.assertEquals(scoreCardYTDMonth, Datetime.now().addMonths(-1).format('MMMMM'), 'YTD Month is not updated');
    }

    @TestSetup
    static void createData()
    {
        String year = '2020';
        String state = 'Draft';
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan(year,state);
    }
}