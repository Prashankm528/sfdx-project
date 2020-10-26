/**
 * @author			Jan Majling
 * @date 			23/08/2018
 * @group			CAJBP
 * @description		testing class for CAJBP_SharingSerevice
 * 
 * history
 * 23/08/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_SharingServiceTest {
	private final static String PERMISSION_SET_CAJBP_USER_NAME = 'CAJBP_Standard_User';

	@testSetup static void setup() {
		CAJBP_TestFactory.createUsers(1, 0);
		CAJBP_TestFactory.createJointBusinessPlan();
	}

	@isTest static void testGrantAccess() {
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
		sharedItem.sharedRecordId = jbpId;
		sharedItem.userOrGroupId = userId;
		sharedItem.sharingReason = 'Manual';
		sharedItem.accessLevel = 'Read-only';
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>{
			sharedItem
		};

		Test.startTest();
		new CAJBP_SharingService().grantAccess(sharedItems);
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareRecords = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId AND UserOrGroupId = :userId AND AccessLevel = 'Read'
		];

		System.assertEquals(1, jbpShareRecords.size());
	}

	@isTest static void testGrantAccessInvalidUser() {
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
		sharedItem.sharedRecordId = jbpId;
		sharedItem.userOrGroupId = null;
		sharedItem.sharingReason = 'Manual';
		sharedItem.accessLevel = 'Read-only';
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>{
			sharedItem
		};
		List<CAJBP_SharedItem> sharedItemsWithError;

		Test.startTest();
		sharedItemsWithError = new CAJBP_SharingService().grantAccess(sharedItems);
		Test.stopTest();

		System.assert(sharedItemsWithError.get(0).errorMessage.contains(Label.CAJBP_GrantAccessError));
	}

	@isTest static void testGrantAccessNoData() {
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();
		Exception error;

		Test.startTest();
		try {
			new CAJBP_SharingService().grantAccess(sharedItems);
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();

		System.assertEquals(null, error);
	}

	@isTest static void testRevokeAccess() {
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		Id jbpId = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__c
			WHERE Name = 'Test Account Customer Group JBP 2080'
		].Id;
		CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
		sharedItem.sharedRecordId = jbpId;
		sharedItem.userOrGroupId = userId;
		sharedItem.sharingReason = 'Manual';
		sharedItem.accessLevel = 'Read-only';
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>{
			sharedItem
		};
		CAJBP_SharingService sharingService = new CAJBP_SharingService();
		sharingService.grantAccess(sharedItems);

		Test.startTest();
		sharingService.revokeAccess(sharedItems);
		Test.stopTest();

		List<CAJBP_Joint_Business_Plan__Share> jbpShareObjects = [
			SELECT Id
			FROM CAJBP_Joint_Business_Plan__Share
			WHERE ParentId = :jbpId AND UserOrGroupId = :userId AND AccessLevel = 'Read'
		];

		System.assertEquals(0, jbpShareObjects.size());
	}

	@isTest static void testRevokeAccessNoData() {
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();
		Exception error;

		Test.startTest();
		try {
			new CAJBP_SharingService().revokeAccess(sharedItems);
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();

		System.assertEquals(null, error);
	}

	@isTest static void testAssignPermissionSetToUsers() {
		Id permissionSetId = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = :PERMISSION_SET_CAJBP_USER_NAME
			LIMIT 1
		].Id;
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		List<String> userStringIds = new List<String>{userId};

		Test.startTest();
		CAJBP_SharingService.assignPermissionSetToUsers(permissionSetId, userStringIds);
		Test.stopTest();

		List<PermissionSetAssignment> permissionAssignments = [
			SELECT Id
			FROM PermissionSetAssignment
			WHERE PermissionSetId = :permissionSetId AND AssigneeId = :userId
		];
		System.assertEquals(1, permissionAssignments.size());
	}

	@isTest static void testRemovePermissionSetFromUsers() {
		Id permissionSetId = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = :PERMISSION_SET_CAJBP_USER_NAME
			LIMIT 1
		].Id;
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		List<String> userStringIds = new List<String>{userId};
		CAJBP_SharingService.assignPermissionSetToUsers(permissionSetId, userStringIds);

		Test.startTest();
		CAJBP_SharingService.removePermissionSetFromUsers(permissionSetId, userStringIds);
		Test.stopTest();

		List<PermissionSetAssignment> permissionAssignments = [
			SELECT Id
			FROM PermissionSetAssignment
			WHERE PermissionSetId = :permissionSetId AND AssigneeId = :userId
		];
		System.assertEquals(0, permissionAssignments.size());
	}

	@isTest static void testRemoveNonExistentPermissionSet() {
		Id permissionSetId = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = :PERMISSION_SET_CAJBP_USER_NAME
			LIMIT 1
		].Id;
		Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
		List<String> userStringIds = new List<String>{userId};

		Exception error;
		Test.startTest();
		try {
			CAJBP_SharingService.removePermissionSetFromUsers(permissionSetId, userStringIds);
		} catch(Exception e) {
			error = e;
		}
		Test.stopTest();

		System.assertEquals(null, error);
	}
}