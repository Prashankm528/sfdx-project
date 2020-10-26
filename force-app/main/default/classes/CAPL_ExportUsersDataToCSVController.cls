public with sharing class CAPL_ExportUsersDataToCSVController {

	public static final String COMMUNITY_PERMISSION_SET = 'CAPL_CommunityPermission';

	@AuraEnabled
	public static List<User> fetchUsers() {
		List<User> userList = [
			SELECT Name, Username, LanguageLocaleKey, LastLoginDate 
			FROM User
			WHERE IsActive = true
				AND Id IN (
					SELECT AssigneeId 
					FROM PermissionSetAssignment 
					WHERE PermissionSet.Name = :COMMUNITY_PERMISSION_SET
					)
			LIMIT 10000
		];

		return userList;
	}

	@AuraEnabled
	public static User fetchUserProfile() {
		User u = [
			SELECT Id, Profile.Name 
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		return u;
	}

}