public with sharing class CAPL_SaveCommunityUsersAsCSVClass {
	
	private static final String COMMUNITY_PERMISSION_SET = 'CAPL_CommunityPermission';

	public String header {
        get {
            header = 'Name, Username, Email, LanguageLocaleKey, LastLoginDate';

            return header;
        } 
        private set;
    }

	public List<User> dataForCSV {
        get {
            dataForCSV = [
				SELECT Name, Username, Email, LanguageLocaleKey, LastLoginDate 
				FROM User
				WHERE IsActive = true
					AND Id IN (
						SELECT AssigneeId 
						FROM PermissionSetAssignment 
						WHERE PermissionSet.Name = :COMMUNITY_PERMISSION_SET
						)
				LIMIT 10000
			];

            return dataForCSV;
        }
        private set;
    }
}