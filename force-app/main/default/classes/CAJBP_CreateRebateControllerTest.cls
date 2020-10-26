/**
 * @author			Jan Majling
 * @date			09/09/2018
 * @group			CAJBP
 * @description		test class for CAJBP_CreateRebateController
 *
 * history
 * 09/09/2019	Jan Majling			Created 
 * 10/02/2020	Jan Majling			Updated 
 */
@isTest
private class CAJBP_CreateRebateControllerTest {
	static integer dataSize;
	static string jbpState;
	static string jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;
	@isTest static void testGetRecordTypesWithoutMaster() {
		Set<Id> recordTypeIds = CAJBP_Rebate__c.SObjectType.getDescribe().getRecordTypeInfosById().keySet();

		Map<Id,String> recordTypesByIds;
		Test.startTest();
		recordTypesByIds = CAJBP_CreateRebateController.getRecordTypesWithoutMaster();
		Test.stopTest();

		for(Id recordTypeId : recordTypesByIds.keySet()) {
			recordTypeIds.remove(recordTypeId);
		}

		System.assertEquals(1, recordTypeIds.size(), 'RecordTypeIds should contain only master record type.');
	}
	@isTest static void testgetScorecardId()
	{
		dataSize = 1;
		jbpState = 'In Progress';
        Id scoreCardId;
        Id scoreId;
		createTestData();
		CAJBP_Joint_Business_Plan__c cajbp =  [SELECT Id, (SELECT Id from CAJBP_Scorecards__r) from CAJBP_Joint_Business_Plan__c limit 1];
		CAJBP_Joint_Business_Plan__c jbp = CAJBP_CreateRebateController.getScorecardId(cajbp.Id);
		for(CAJBP_Scorecard__c scoreCard : cajbp.CAJBP_Scorecards__r)
		{
			scoreCardId=scoreCard.Id;
        }
        for(CAJBP_Scorecard__c scoreCard : jbp.CAJBP_Scorecards__r)
		{
			scoreId=scoreCard.Id;
		}
		system.assertEquals(scoreId, scoreCardId,'ScoreCard Id is not retrived correctly');

	}
	public static void createTestData()
    {
        Account act = new Account(Name='JBP Account',Type='Sold-To Party');
        insert act;

		Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=act.id);
        insert contact;
        
        List<CAJBP_Joint_Business_Plan__c> createJBP = new List<CAJBP_Joint_Business_Plan__c>();
        for(integer i=0;i<dataSize;i++)
        {
            createJBP.add(new CAJBP_Joint_Business_Plan__c(Name ='JBP' + i,
                    CAJBP_State__c=jbpState,CAJBP_Year__c= string.valueOf(date.today().year()+i), 
                    RecordTypeId=jbpRecordType,CAJBP_Account__c=act.Id, 
					CAJBP_JBP_Start_Date__c = Date.today(),
                	CAJBP_JBP_End_Date__c = Date.today().addDays(10),
                	CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                	CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                	CAJBP_JBP_Agreed_Sign_Off__c=True
					));
        }
        insert createJBP;
    }  
}