/**
 * @author			Jan Majling
 * @date 			30/08/2018
 * @group			CAJBP
 * @description		testing class for CAJBP_JbpTeamMemberHelper
 * 
 * history
 * 30/08/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_JbpTeamMemberHelperTest {
	@testSetup static void setup() {
		CAJBP_TestFactory.createJointBusinessPlan();
		CAJBP_TestFactory.createUsers(1,0);
	}

	@isTest static void testUniqueKey() {
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only',
            CAJBP_Role__c = 'Others'
		);

		String uniqueKey;
		Test.startTest();
		uniqueKey = new CAJBP_JbpTeamMemberHelper().createUniqueKey(teamMember);
		Test.stopTest();

		String expectedKey = (String)jbpId + userId;
		System.assertEquals(expectedKey, uniqueKey);
	}

	@isTest static void testSetUniqueKeys() {
		List<User> users = CAJBP_TestFactory.createUsers(2,1);
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JbpTeamMemberHelper helper = new CAJBP_JbpTeamMemberHelper();
		Set<String> uniqueKeys = new Set<String>();
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only',
                CAJBP_Role__c = 'Others'
			);
			teamMembers.add(teamMember);
			uniqueKeys.add(helper.createUniqueKey(teamMember));
		}

		Test.startTest();
		helper.setUniqueKeys(teamMembers);
		Test.stopTest();

		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			uniqueKeys.remove(teamMember.CAJBP_Unique_Key__c);
		}

		System.assert(uniqueKeys.isEmpty());
	}

	@isTest static void testNoDuplicatedJbpTeamMember() {
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only',
            CAJBP_Role__c = 'Others'
		);
		insert teamMember;
		CAJBP_JBP_Team_Member__c newTeamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read/Write',
            CAJBP_Role__c = 'Others'
		);

		String errorMessage;
		Test.startTest();
		try {
			insert newTeamMember;
		} catch(Exception e) {
			errorMessage = e.getMessage();
		}
		Test.stopTest();

		System.assert(errorMessage.contains(Label.CAJBP_Duplicated_JBP_Team_Member));
	}
    
    @isTest static void testNoDuplicatedJbpTeamMemberRole() {
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only',
            CAJBP_Role__c = 'Marketing Approver'
		);
		insert teamMember; 
		CAJBP_JBP_Team_Member__c newTeamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = userId,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read/Write',
            CAJBP_Role__c = 'Marketing Approver'
		);

		String errorMessage;
		Test.startTest();
		try {
			insert newTeamMember;
		} catch(Exception e) {
			errorMessage = e.getMessage();
		}
		Test.stopTest();

		System.assert(errorMessage.contains(Label.CAJBP_Duplicated_JBP_Team_Member_Role));
	}

	@isTest static void testJbpTeamMemberUserUpdation() {
		List<User> users = CAJBP_TestFactory.createUsers(2,1);
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		Id jbpId = [
				SELECT Id
				FROM CAJBP_Joint_Business_Plan__c
				WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;

		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = userId,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only',
				CAJBP_Role__c = 'Marketing Approver'
		);
		insert teamMember;

		CAJBP_Objective__c obj = new CAJBP_Objective__c(
				//  Name = 'TestName' + j,
				CAJBP_Joint_Business_Plan__c = jbpId,
				Name = 'Test Objective',
				CAJBP_Description__c = 'Test Description');

		insert obj;

		List<CAJBP_JBP_Activity__c> lstJBPActivities = new List<CAJBP_JBP_Activity__c>();
		for(Integer k = 0; k < 10; k++){
			lstJBPActivities.add(new CAJBP_JBP_Activity__c(
					Name = 'TestName' + k,
					CAJBP_Objective__c = obj.id,
					CAJBP_Paid_for_by__c = 'Castrol',
					CAJBP_Activity_Type__c = 'Promotion',
					CAJBP_Status__c = 'In Progress',
					CAJBP_Start_Date__c = Date.today(),
					CAJBP_End_Date__c = Date.today().addDays(1),
					CAJBP_Activity_Ownership__c = 'Castrol',
					CAJBP_Castrol_Estimated_Cost__c = 1000,
					CAJBP_Partner_Estimated_Cost__c = 900
			));
		}
		insert lstJBPActivities;

		teamMember.CAJBP_User__c = users[1].Id;
		System.assertEquals(userId, [select id, CAJBP_Marketing_Approver__c from CAJBP_JBP_Activity__c limit 1].CAJBP_Marketing_Approver__c);

		Test.startTest();
		update teamMember;
		Test.stopTest();

		System.assertEquals(users[1].Id, [select id, CAJBP_Marketing_Approver__c from CAJBP_JBP_Activity__c limit 1].CAJBP_Marketing_Approver__c);

		try{
			delete teamMember;
		} catch (Exception ex){
			String errorMsg = ex.getMessage();
			System.assertEquals(Label.CAJBP_Cannot_Delete_Team_Member_With_Marketing_Or_Finance_Approver_Role, errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': ['));
		}
	}

}