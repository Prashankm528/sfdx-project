/**
 * @author 			Jan Majling
 * @date 			11/09/2018
 * @group			CAJBP
 * @description		testing class for CAJBP_ScorecardDetailsController
 * 
 * history
 * 11/09/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_RecordDetailsSectionControllerTest {
	@testSetup static void setup() {
		Id recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByName().get('Direct JBP').getRecordTypeId();
		CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
			CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
			CAJBP_Year__c = '2080',
            CAJBP_State__c = 'Draft',
            CAJBP_JBP_End_Date__c = Date.today().addDays(5),
			RecordTypeId = recordTypeId
		);
		insert jbp;
	}

	@isTest static void testGetRecordData() {
		Id jbpId = [
			SELECT Id 
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].get(0).Id;

		CAJBP_RecordDetailsSectionController.RecordData recordData;
		Test.startTest();
		recordData = CAJBP_RecordDetailsSectionController.getRecordData(jbpId, null);
		Test.stopTest();

		System.assertEquals(jbpId, recordData.recordId, 'Ids should be equal');
		System.assertEquals('CAJBP_Joint_Business_Plan__c', recordData.recordObjectName, 'Object names should match');
	}

	@isTest static void testGetRecordDataIncorrectRelationship() {
		Id jbpId = [
			SELECT Id 
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].get(0).Id;

		Exception error;
		Test.startTest();
		try {
			CAJBP_RecordDetailsSectionController.getRecordData(jbpId, 'Test__r');
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();

		System.assertNotEquals(null, error);
	}

	@isTest static void testGetRecordDataNoChildren() {
		Id jbpId = [
			SELECT Id 
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].get(0).Id;

		Exception error;
		Test.startTest();
		try {
			CAJBP_RecordDetailsSectionController.getRecordData(jbpId, 'SWOTS__r');
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();
		System.debug(error);

		System.assertNotEquals(null, error);
	}

	@isTest static void testGetChildRecordData() {
		Id jbpId = [
			SELECT Id 
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].get(0).Id;

		List<CAJBP_Scorecard__c> scorecards = [
			SELECT Id
			FROM CAJBP_Scorecard__c
			WHERE CAJBP_Joint_Business_Plan__c = :jbpId
		];
		CAJBP_Scorecard__c scorecard;
		if(scorecards.isEmpty()) {
			scorecard = new CAJBP_Scorecard__c(
				CAJBP_Joint_Business_Plan__c = jbpId
			);
			insert scorecard;
		} else {
			scorecard = scorecards.get(0);
		}

		CAJBP_RecordDetailsSectionController.RecordData recordData;
		Test.startTest();
		recordData = CAJBP_RecordDetailsSectionController.getRecordData(jbpId, 'CAJBP_Scorecards__r');
		Test.stopTest();

		System.assertEquals(scorecard.Id, recordData.recordId, 'Ids should be equal');
		System.assertEquals('CAJBP_Scorecard__c', recordData.recordObjectName, 'Object names should match');
	}
}