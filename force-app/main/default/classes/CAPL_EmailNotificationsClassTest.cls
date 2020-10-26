@isTest
private class CAPL_EmailNotificationsClassTest {
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
	static void fetchUserIdTest() {
		User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
		String userId;

		System.runAs(u) {
			Test.startTest();
				userId = CAPL_EmailNotificationsClass.fetchUserId();
			Test.stopTest();
		}

		System.assertEquals(u.id, userId);
	}
	
	@isTest 
	static void fetchEmailNotificationsTest() {
		User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
		NetworkMember member;

		System.runAs(u) {
			Test.startTest();
				member = CAPL_EmailNotificationsClass.fetchEmailNotifications();
			Test.stopTest();
		}

		System.assertNotEquals(member, null);
	}

	@isTest 
	static void updateEmailNotificationsTest() {
		User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
		NetworkMember memberBefore = [SELECT ReputationPoints FROM NetworkMember WHERE MemberId = :u.Id LIMIT 1];
		memberBefore.ReputationPoints +=20;

		System.runAs(u) {
			Test.startTest();
				CAPL_EmailNotificationsClass.updateEmailNotifications(memberBefore);
			Test.stopTest();
		}

		NetworkMember memberAfter = [SELECT ReputationPoints FROM NetworkMember WHERE MemberId = :u.Id LIMIT 1];

		System.assertNotEquals(memberAfter.ReputationPoints, 70);
	}
	
}