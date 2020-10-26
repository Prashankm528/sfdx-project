/**
 * @author			Venkatesh Muniyasamy
 * @date			24/04/2020
 * @group			CAJBP
 * @description		Validate whether the latest scorecard values are entered.
 *
 * history
 * 24/04/2020 	Venkatesh Muniyasamy	Created
 */
public with sharing class CAJBP_ScorecardConfirm
{
    @AuraEnabled
    public static Boolean confirmYTDMonth(Id jbpId)
    {
        Boolean confirmScorecard;
        CAJBP_Joint_Business_Plan__c jbp = [SELECT Id,CAJBP_Account_Status__c, CAJBP_Year__c, (SELECT Id, CAJBP_YTD_Month__c FROM CAJBP_Scorecards__r LIMIT 1)
                        FROM CAJBP_Joint_Business_Plan__c WHERE Id =:jbpId LIMIT 1];

        if((String.valueOf(Date.today().year())==jbp.CAJBP_Year__c) &&
            (Datetime.now().addMonths(-1).format('MMMMM') != jbp.CAJBP_Scorecards__r[0].CAJBP_YTD_Month__c) &&
            Datetime.now().format('MMMMM')!='January' && jbp.CAJBP_Account_Status__c !='Prospect')
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    @AuraEnabled
    public static string updateYTDMonth(Id jbpId)
    {
        CAJBP_Scorecard__c jbpScorecard = [SELECT Id, CAJBP_YTD_Month__c FROM CAJBP_Scorecard__c
                                            WHERE CAJBP_Joint_Business_Plan__c =:jbpId LIMIT 1];
        jbpScorecard.CAJBP_YTD_Month__c = Datetime.now().addMonths(-1).format('MMMMM');

        update jbpScorecard;

        return jbpScorecard.CAJBP_YTD_Month__c;
    }
}