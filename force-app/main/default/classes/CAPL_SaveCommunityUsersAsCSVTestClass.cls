@isTest
private class CAPL_SaveCommunityUsersAsCSVTestClass {

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

	    	con2 = new Contact(
	    		FirstName = 'john',
	    		LastName = 'james',
	    		Email = 'johnjames@test.com',
	    		Home_Location__c = 'United Kingdom',
	    		MailingStreet  = 'abc2321',
	    		MailingCity  = 'test2321',
	    		MailingState  = 'te2321',
	    		MailingPostalCode  = 'test1232321',
	    		MailingCountry  = 'testcountry',
	    		AccountId = a.Id
	    	);

	    	insert con2;

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

	        User u2 = new User(
		        FirstName = 'TestName2',
		        LastName = 'TestSurname2',
		        Email = 'testedemail2@email.com',
		        Username = 'test2@test.com.test!!!',
		        Alias = 'astest2',
		        ProfileId = p.Id,
		        TimeZoneSidKey    = 'America/Denver',
		        LocaleSidKey      = 'en_US',
		        EmailEncodingKey  = 'UTF-8',
		        LanguageLocaleKey = 'en_US',
		        ContactId = con2.Id,
		        Street = 'teststreet2', 
				City = 'testCity2',
				State = 'testState2',
				PostalCode = 'testCode2', 
				Country = 'testCountry2',
				CAPL_Birthdate__c = Date.today().addDays(1),
				CAPL_Job_Role__c = 'testJobRole2'
			);

			insert u2;

			PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'CAPL_CommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
            insert new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = ps.Id );
        }    
	}
	
	@isTest static void test_method_one() {
		CAPL_SaveCommunityUsersAsCSVClass ctrl = new CAPL_SaveCommunityUsersAsCSVClass();

		String test = ctrl.header;
		List<User> dataForCSV = ctrl.dataForCSV;

		System.assertNotEquals(dataForCSV.size(), 0);
	}
	
}