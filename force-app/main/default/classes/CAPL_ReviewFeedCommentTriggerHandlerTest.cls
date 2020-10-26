@isTest
private class CAPL_ReviewFeedCommentTriggerHandlerTest {

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

	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User u = new User(
	        FirstName = 'TestName2222',
	        LastName = 'TestSurname2222',
	        Email = 'testedemail2222@email.com',
	        Username = 'test2222@test2222alt.com',
	        Alias = 'astest2',
	        ProfileId = p.Id,
	        TimeZoneSidKey    = 'America/Denver',
	        LocaleSidKey      = 'en_US',
	        EmailEncodingKey  = 'UTF-8',
	        LanguageLocaleKey = 'en_US',
	        Street = 'teststreet', 
			City = 'testCity',
			State = 'testState',
			PostalCode = 'testCode', 
			Country = 'testCountry',
			CAPL_Birthdate__c = Date.today(),
			CAPL_Job_Role__c = 'testJobRole'
		);
		
        insert u;

	    List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

        System.runAs(u) {

        	CollaborationGroup group2 = new CollaborationGroup(
        	 	Name = 'NotAllowedGroup', 
        	 	CollaborationType= 'Public',
        	 	NetworkId = networks.get(0).Id
        	 );

        	insert group2;
        	

			FeedItem thirdFeed = new FeedItem(
	    		Title = 'third feed title',
	    		Body = 'third feed body',
	    		Status = 'Published',
	    		Type = 'QuestionPost',
	    		ParentId = group2.Id,
	    		NetworkScope = networks.get(0).Id
	    	);

	    	insert thirdFeed;

	        FeedComment firstComment = new FeedComment(
	            FeedItemId = thirdFeed.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        insert firstComment;

	         FeedComment secondComment = new FeedComment(
	            FeedItemId = thirdFeed.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        insert secondComment;

	         FeedComment thirdComment = new FeedComment(
	            FeedItemId = thirdFeed.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        insert thirdComment;

	         FeedComment fourthComment = new FeedComment(
	            FeedItemId = thirdFeed.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        insert fourthComment;

	        FeedComment fifthComment = new FeedComment(
	            FeedItemId = thirdFeed.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        //insert fifthComment;

	    }
    }
	
	@isTest static void limitPointsForComment() {
		User u = [SELECT Id FROM User WHERE LastName = 'TestSurname2222' LIMIT 1];
		FeedItem feedItem = [SELECT Id FROM FeedItem WHERE Title  = 'third feed title' LIMIT 1];

	    FeedComment firstComment;

        System.runAs(u) {
	        firstComment = new FeedComment(
	            FeedItemId = feedItem.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        //insert firstComment;

	        //delete firstComment;
	    }
	}
}