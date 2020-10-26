/**
 * @author Jan Majling
 * @date 23/08/2018
 * @description		testing class for CAJBP_JbpSharing
 * 
 * history
 * 23/08/2018	Jan Majling			    Created
 * 18/06/2020	Venkatesh Muniyasamy	Updated for Risk Sharing
 * 30/07/2020	Venkatesh Muniyasamy	Updated for Customer Contact Sharing
 */
@isTest
private class CAJBP_JbpSharingTest {
	@testSetup static void setup() {
        CAJBP_Joint_business_plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
        CAJBP_TestFactory.createObjective(jbp.Id);
        CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -1000, -1000, Date.today().addMonths(1));
	}

	@isTest static void testGrantAccessForTeamMembers() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		Integer teamMembersCount = 2;
		Set<Id> userIds = new Set<Id>();
		List<User> users = CAJBP_TestFactory.createUsers(teamMembersCount, 0);
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only',
                CAJBP_Role__c = 'Others'
			);
			teamMembers.add(teamMember);
			userIds.add(user.Id);
		}

		Test.startTest();
		insert teamMembers;
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId AND UserOrGroupId IN :userIds AND AccessLevel = 'Read'
		];

		System.assertEquals(teamMembersCount, jbpShareObjects.size());
	}

	@isTest static void testGrantAccessForInvalidTeamMember() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
			CAJBP_User__c = null,
			CAJBP_Joint_Business_Plan__c = jbpId,
			CAJBP_Access__c = 'Read Only',
            CAJBP_Role__c = 'Others'
		);
		String errorMessage;

		Test.startTest();
		try {
			insert teamMember;
		} catch(DmlException error) {
			errorMessage = error.getMessage();
		}
		Test.stopTest();

		System.assert(errorMessage.contains(Label.CAJBP_GrantAccessError));
	}

	@isTest static void testUpdateAccessForTeamMembers() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		Integer teamMembersCount = 2;
		Set<Id> userIds = new Set<Id>();
		List<User> users = CAJBP_TestFactory.createUsers(teamMembersCount, 0);
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only',
                CAJBP_Role__c = 'Others'
			);
			teamMembers.add(teamMember);
			userIds.add(user.Id);
		}

		insert teamMembers;
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			teamMember.CAJBP_Access__c = 'Read/Write';
		}

		Test.startTest();
		update teamMembers;
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId
				AND UserOrGroupId IN :userIds
				AND AccessLevel = 'Edit'
		];

		System.assertEquals(teamMembersCount, jbpShareObjects.size());
	}

	@isTest static void testRevokeAccessForTeamMembers() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		Integer teamMembersCount = 2;
		Set<Id> userIds = new Set<Id>();
		List<User> users = CAJBP_TestFactory.createUsers(teamMembersCount, 0);
		List<CAJBP_JBP_Team_Member__c> teamMembers = new List<CAJBP_JBP_Team_Member__c>();
		for(User user : users) {
			CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
				CAJBP_User__c = user.Id,
				CAJBP_Joint_Business_Plan__c = jbpId,
				CAJBP_Access__c = 'Read Only',
                CAJBP_Role__c = 'Others'
			);
			teamMembers.add(teamMember);
			userIds.add(user.Id);
		}

		insert teamMembers;

		Test.startTest();
		delete teamMembers;
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId
				AND UserOrGroupId IN :userIds
				AND AccessLevel = 'Read'
		];

		System.assertEquals(0, jbpShareObjects.size());
    }

    @isTest static void testShareObjectivesToJBPOwner() {

        CAJBP_Joint_business_plan__c jbp = [Select Id From CAJBP_Joint_business_plan__c Limit 1];
        Id userId = [Select Id From User Limit 1].Id;

        Test.startTest();
            jbp.OwnerId = userId;
            update jbp;
            CAJBP_Objective__c objective = CAJBP_TestFactory.createObjective(jbp.Id);  
            CAJBP_Objective__Share objShare = [Select ParentId, UserOrGroupId, AccessLevel 
                                       From CAJBP_Objective__Share Where ParentId =: objective.Id Limit 1];
        Test.stopTest();

        System.assertEquals(objective.Id, objShare.ParentId);
    }

    @isTest static void testShareRisksToJBPOwner() {

        CAJBP_Joint_business_plan__c jbp = [Select Id From CAJBP_Joint_business_plan__c Limit 1];
        Id userId = [Select Id From User Limit 1].Id;

        Test.startTest();
            jbp.OwnerId = userId;
            update jbp;
            CAJBP_Risk__c risk = CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -1000, -1000, Date.today().addMonths(1));
            insert risk;
            CAJBP_Risk__Share riskShare = [Select ParentId, UserOrGroupId, AccessLevel
                                       From CAJBP_Risk__Share Where ParentId =: risk.Id Limit 1];
        Test.stopTest();

        System.assertEquals(risk.Id, riskShare.ParentId);
    }

    @isTest static void testShareCustomerContactToJBPOwner()
    {
        CAJBP_Joint_business_plan__c jbp = [Select Id, CAJBP_Account__c From CAJBP_Joint_business_plan__c Limit 1];
        //CAJBP_TestFactory.createCustomerContact(jbp);
        Id userId = [Select Id From User Limit 1].Id;

        Test.startTest();
            jbp.OwnerId = userId;
            update jbp;
            CAJBP_Customer_Contact__c customer = CAJBP_TestFactory.createCustomerContact(jbp);
            CAJBP_Customer_Contact__Share customerShare = [Select ParentId, UserOrGroupId, AccessLevel
                                       From CAJBP_Customer_Contact__Share Where ParentId =: customer.Id Limit 1];
        Test.stopTest();

        System.assertEquals(customer.Id, customerShare.ParentId);
    }
}