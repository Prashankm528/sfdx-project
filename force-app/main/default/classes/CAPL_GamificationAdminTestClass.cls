@isTest
private class CAPL_GamificationAdminTestClass {

		@testSetup
	static void setup() {

		UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User userWithRole = new User(
        	alias = 'hasrole', 
        	email='userwithrole@roletest1.com', 
        	userroleid = r.id,
			emailencodingkey='UTF-8', 
			lastname='Testing', 
			languagelocalekey='en_US', 
			localesidkey='en_US', 
			profileid = pf.Id, 
			timezonesidkey='America/Los_Angeles', 
			username='userwithrole@testclass_bp'+System.currentTimeMillis()+'.com'

		);

        Account a;
        Contact con;
        Contact con2;
        
        System.runAs(userWithRole) {
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            a = new Account(
            	RecordTypeId = recordTypeId, 
            	Name = 'testAccountName'
            );

            insert a;

            con = new Contact(
	    		FirstName = 'TestName',
	    		LastName = 'TestSurname',
	    		Email = 'test@test.com',
	    		Home_Location__c = 'United Kingdom',
	    		MailingStreet  = 'abc',
	    		MailingCity  = 'test',
	    		MailingState  = 'te',
	    		MailingPostalCode  = 'test123',
	    		MailingCountry  = 'testcountry',
	    		AccountId = a.Id
	    	);

	    	insert con;

	    	Account acc = [
	        	SELECT PersonContactId 
	        	FROM Account 
	        	WHERE Id = :a.Id
	        ];

	    	Profile p = [SELECT Id FROM Profile WHERE Name = 'RE IDP External Identity'];

	        User u = new User(
		        FirstName = 'TestName',
		        LastName = 'TestSurname',
		        Email = 'testedemail@email.com',
		        Username = 'test@test.com.test!!!',
		        Alias = 'astest',
		        ProfileId = p.Id,
		        TimeZoneSidKey    = 'America/Denver',
		        LocaleSidKey      = 'en_US',
		        EmailEncodingKey  = 'UTF-8',
		        LanguageLocaleKey = 'en_US',
		        ContactId = con.Id,
		        Street = 'teststreet', 
				City = 'testCity',
				State = 'testState',
				PostalCode = 'testCode', 
				Country = 'testCountry',
				CAPL_Birthdate__c = Date.today(),
				CAPL_Job_Role__c = 'testJobRole'
			);
			
	        insert u;

	        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'CAPL_CommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
        }
    }
	
	@isTest 
	static void fetchCommunityUsersTest() {
		CAPL_GamificationAdminClass ctrl = new CAPL_GamificationAdminClass();

		Test.startTest();
			ctrl.fetchCommunityUsers();
		Test.stopTest();

		System.assertNotEquals(ctrl.communityUserList.size(), 3);
	}
	
	@isTest 
	static void addReputationPointsTest() {
		User u = [SELECT Id FROM User WHERE LastName = 'TestSurname' LIMIT 1];

		CAPL_GamificationAdminClass ctrl = new CAPL_GamificationAdminClass();

		PageReference pageRef = Page.CAPL_GamificationAdmin;

		pageRef.getParameters().put('userId', u.Id);
		pageRef.getParameters().put('points', '100');
    	
    	Test.setCurrentPage(pageRef);

		Test.startTest();
			ctrl.addReputationPoints();
		Test.stopTest();

		NetworkMember user = [
			SELECT Id, ReputationPoints
			FROM NetworkMember
			WHERE MemberId = :u.Id
			LIMIT 1
		];

		System.assertNotEquals(user.ReputationPoints, 0);
	}
	
}