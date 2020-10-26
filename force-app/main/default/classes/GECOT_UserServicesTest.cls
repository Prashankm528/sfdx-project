@isTest
private class GECOT_UserServicesTest {

	@isTest
	static void itShouldAddTerritoryToUserTest() {
		// Given
		Map<String, String> role2TerritoryMap = new Map<String, String>();
		for(GECOT_Territory_Mapping__mdt mapping : 
				[SELECT Id, MasterLabel, DeveloperName, Territory_Developer_Name__c 
				 FROM GECOT_Territory_Mapping__mdt])
		{
	        role2TerritoryMap.put(
	        	mapping.MasterLabel, 
	        	mapping.Territory_Developer_Name__c.replace('_',' '));
   		}

		List<Group> groups = 
			[SELECT RelatedId, Id, DeveloperName, Type 
	         FROM Group 
	         WHERE Id IN
	          (SELECT UserOrGroupId 
	            FROM GroupMember 
	            WHERE Group.Name IN :role2TerritoryMap.keySet())
	         LIMIT 5];
		
		System.assertEquals(5, groups.size(), 'Less than 5 Public Groups are configured');
		List<User> users = new List<User>();
		for(Group g : groups){
	    	users.add(createUser(g.RelatedId, groups.indexOf(g)));
	    }
		// When
		Test.startTest();
		insert users;
		Test.stopTest();

		// Then
		System.assertEquals(5, [SELECT count() FROM UserTerritory2Association WHERE UserId IN :users]);
	}

	static User createUser(Id roleId, Integer i){
		return new User(
			Alias = 'hasrole',
			Email ='userwithrole@roletest1.com',
			//UserRole = new UserRole(Name = roleName),
        	UserRoleId = roleId,
        	Emailencodingkey = 'UTF-8',
	        Lastname = 'Testing',
	        Languagelocalekey = 'en_US',
	        Localesidkey = 'en_US',
	        Profile = new Profile(Name = 'System Administrator'),
	        Timezonesidkey = 'America/Los_Angeles',
	        Username = 'territoryTestUser' + System.now().getTime() +'@bp.com' + i);
	}
}