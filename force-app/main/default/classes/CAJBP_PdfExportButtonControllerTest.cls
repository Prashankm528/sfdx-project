/**
 * @author			Jan Majling
 * @date			28/09/2018
 * @group			CAJBP
 * @description		test class for CAJBP_PdfExportButtonController
 *
 * history
 * 28/09/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_PdfExportButtonControllerTest {
	@testSetup static void setup() {
		CAJBP_TestFactory.createJointBusinessPlan();
	}

	@isTest static void testGetButtonUrl() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		APXTConga4__Conga_Solution__c congaSolution = new APXTConga4__Conga_Solution__c(
			APXTConga4__Master_Object_Type__c = 'CAJBP_Joint_Business_Plan__c',
			APXTConga4__Button_body_field__c = '/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_370}&Id={!CAJBP_Joint_Business_Plan__c.Id}'
		);
		insert congaSolution;

		Test.startTest();
		String buttonUrl = CAJBP_PdfExportButtonController.getButtonUrl(jbpId);
		Test.stopTest();

		String partnerServerUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId();
		String expectedUrl = String.format(
			'/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={0}&Id={1}',
			new LIST<String>{
				partnerServerUrl,
				jbpId
			}
		);
		System.assertEquals(expectedUrl, buttonUrl);
	}

	@isTest static void testGetButtonUrlDifferentServerUrl() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		APXTConga4__Conga_Solution__c congaSolution = new APXTConga4__Conga_Solution__c(
			APXTConga4__Master_Object_Type__c = 'CAJBP_Joint_Business_Plan__c',
			APXTConga4__Button_body_field__c = '/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!WrongFormat}&Id={!CAJBP_Joint_Business_Plan__c.Id}'
		);
		insert congaSolution;

		Test.startTest();
		String buttonUrl = CAJBP_PdfExportButtonController.getButtonUrl(jbpId);
		Test.stopTest();

		String expectedUrl = '/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!WrongFormat}&Id=' + jbpId;
		System.assertEquals(expectedUrl, buttonUrl);
	}

	@isTest static void testGetButtonUrlEmpty() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		APXTConga4__Conga_Solution__c congaSolution = new APXTConga4__Conga_Solution__c(
			APXTConga4__Master_Object_Type__c = 'CAJBP_Joint_Business_Plan__c'
		);
		insert congaSolution;

		Exception error;
		Test.startTest();
		try {
			CAJBP_PdfExportButtonController.getButtonUrl(jbpId);
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();

		System.assertNotEquals(null, error);
	}

	@isTest static void testGetButtonUrlNoCongaSolution() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;

		Exception error;
		Test.startTest();
		try {
			CAJBP_PdfExportButtonController.getButtonUrl(jbpId);
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();

		System.assertNotEquals(null, error);
	}
}