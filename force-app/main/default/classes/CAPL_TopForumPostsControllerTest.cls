@isTest
private class CAPL_TopForumPostsControllerTest {
	@testSetup
    static void setup() {

		UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        Network net = [SELECT Id, Name FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];
        
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
	static void fetchForumPostsTest() {
		//User u = [SELECT Id FROM User WHERE FirstName = 'TestName'];
		List<CAPL_TopForumPostsController.FeedWrapper> posts = new List<CAPL_TopForumPostsController.FeedWrapper>();

        List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

		//User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
		User u = [SELECT Id FROM User WHERE Username = 'test@test.com.test!!!'];
        FeedItem firstFeed = new FeedItem(
    		Title = 'first feed title',
    		Body = 'first feed body',
    		Status = 'Published',
    		ParentId = u.Id,
            NetworkScope = networks.get(0).Id
    	);

    	FeedItem secondFeed = new FeedItem(
    		Title = 'second feed title',
    		Body = 'second feed body',
    		Status = 'Published',
    		ParentId = u.Id,
            NetworkScope = networks.get(0).Id
    	);

    	FeedItem thirdFeed = new FeedItem(
    		Title = 'third feed title',
    		Body = 'third feed body',
    		Status = 'Published',
    		ParentId = u.Id,
            NetworkScope = networks.get(0).Id
    	);

    	List<FeedItem> feedItemList = new List<FeedItem>();
    	insert firstFeed;
    	insert thirdFeed;

    	FeedComment firstComment = new FeedComment(
            FeedItemId = thirdFeed.Id,
            CommentBody = 'test comment',
            Status = 'Published'
        );

        FeedComment secondComment = new FeedComment(
            FeedItemId = thirdFeed.Id,
            CommentBody = 'second test comment',
            Status = 'Published'
        );

        List<FeedComment> feedCommentList = new List<FeedComment>();
        feedCommentList.add(firstComment);
        feedCommentList.add(secondComment);

        insert feedCommentList;

        CAPL_TopForumPostsController.FeedWrapper wrp = 
        	new CAPL_TopForumPostsController.FeedWrapper('photo url', firstFeed);

        CAPL_TopForumPostsController.FeedWrapper wrpToCompare = 
            new CAPL_TopForumPostsController.FeedWrapper('photo url', firstFeed);

        wrp.compareTo(wrpToCompare);

	    posts = CAPL_TopForumPostsController.fetchForumPosts();
		

		System.assertNotEquals(posts.size(), 1);
	}

}