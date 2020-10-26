@isTest
private class CAPL_BestArticleAndVideoTestController {

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

	        Knowledge__kav newArticleOne = new Knowledge__kav(
	    		Title='test article', 
	    		UrlName='testarticleurl', 
	    		CAPL_ArticleImage__c = 'image',
	    		Language='en_US'
	        );

	        insert newArticleOne;

	        Knowledge__kav newArticleTwo = new Knowledge__kav(
	    		Title='test article2', 
	    		UrlName='testarticleurl2', 
	    		CAPL_ArticleImage__c = 'image',
	    		Language='en_US'
	        );

	        insert newArticleTwo;

	        Knowledge__kav newArticleThree = new Knowledge__kav(
	    		Title='test article3', 
	    		UrlName='testarticleurl3', 
	    		CAPL_ArticleImage__c = 'image',
	    		Language='en_US'
	        );

	        insert newArticleThree;


	        Id newVideoRecordType = Schema.SObjectType.CAPL_Video__c.getRecordTypeInfosByName().get('Upload new video').getRecordTypeId();
            Id existingVideoRecordType = Schema.SObjectType.CAPL_Video__c.getRecordTypeInfosByName().get('Use link to existing video').getRecordTypeId();

            List<CAPL_Video__c> videoList = new List<CAPL_Video__c>();

            CAPL_Video__c newVideo = new CAPL_Video__c(
                Name = 'new video',
                CAPL_Title__c = 'test title',
                RecordtypeId = newVideoRecordType
            );

            videoList.add(newVideo);

            CAPL_Video__c existingVideo = new CAPL_Video__c(
                Name = 'existing video',
                CAPL_Title__c = 'test title',
                CAPL_LinkToVideo__c = 'https://testsite.com/testVideo',
                RecordtypeId = existingVideoRecordType
            );

            videoList.add(existingVideo);

            insert videoList;

            CAPL_BestVideoArticleComment__c background = new CAPL_BestVideoArticleComment__c(
            	Name = 'BestCommentBackground',
            	Identifier__c = 'https://test.com'
            );

            insert background;

            CAPL_BestVideoArticleComment__c bestCommentBody = new CAPL_BestVideoArticleComment__c(
            	Name = 'BestCommentBody',
            	Identifier__c = 'test comment'
            );

            insert bestCommentBody;

            CAPL_BestVideoArticleComment__c bestCommentCreatedBy = new CAPL_BestVideoArticleComment__c(
            	Name = 'BestCommentCreatedBy',
            	Identifier__c = 'test user'
            );

            insert bestCommentCreatedBy;

            CAPL_BestVideoArticleComment__c bestVideo = new CAPL_BestVideoArticleComment__c(
            	Name = 'BestVideo',
            	Identifier__c = 'test id'
            );

            insert bestVideo;

            CAPL_BestVideoArticleComment__c bestArticle = new CAPL_BestVideoArticleComment__c(
            	Name = 'BestArticle',
            	Identifier__c = 'test id'
            );

            insert bestArticle;
        }
    }
	
	@isTest 
	static void assingBestArticleTest() {
		CAPL_BestArticleAndVideoController ctrl = new CAPL_BestArticleAndVideoController();

		PageReference pageRef = Page.CAPL_BestArticleAndVideo;
    	
    	pageRef.getParameters().put('articleId', 'article id');
    	
    	Test.setCurrentPage(pageRef);

    	Test.startTest();
			ctrl.assingBestArticle();
		Test.stopTest();

		CAPL_BestVideoArticleComment__c article = CAPL_BestVideoArticleComment__c.getValues('BestArticle');

		System.assertEquals(article.Identifier__c, 'article id');
	}
	
	@isTest 
	static void assingBestVideoTest() {
		CAPL_BestArticleAndVideoController ctrl = new CAPL_BestArticleAndVideoController();

		PageReference pageRef = Page.CAPL_BestArticleAndVideo;
    	
    	pageRef.getParameters().put('videoId', 'video id');
    	
    	Test.setCurrentPage(pageRef);

    	Test.startTest();
			ctrl.assingBestVideo();
		Test.stopTest();

		CAPL_BestVideoArticleComment__c video = CAPL_BestVideoArticleComment__c.getValues('BestVideo');

		System.assertEquals(video.Identifier__c, 'video id');
	}

	@isTest 
	static void assingBestCommentTest() {
		Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		Network net = [SELECT Id, Name FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];
        
        User userWithRole = new User(
        	alias = 'role', 
        	email='user@role.com', 
			emailencodingkey='UTF-8', 
			lastname='Testing', 
			languagelocalekey='en_US', 
			localesidkey='en_US', 
			profileid = pf.Id, 
			timezonesidkey='America/Los_Angeles', 
			username='testeruser@test.com'

		);

		FeedComment firstComment;

        System.runAs(userWithRole) {

			FeedItem thirdFeed = new FeedItem(
	    		Title = 'third feed title',
	    		Body = 'third feed body',
	    		Status = 'Published',
	    		Type = 'QuestionPost',
	    		ParentId = userWithRole.Id,
	    		NetworkScope = net.Id
	    	);

	    	insert thirdFeed;

	        firstComment = new FeedComment(
	            FeedItemId = thirdFeed.Id,
	            CommentBody = 'test comment',
	            Status = 'Published'
	        );

	        insert firstComment;

	    }

		CAPL_BestArticleAndVideoController ctrl = new CAPL_BestArticleAndVideoController();

		PageReference pageRef = Page.CAPL_BestArticleAndVideo;
    	
    	pageRef.getParameters().put('commentId', firstComment.Id);
    	
    	Test.setCurrentPage(pageRef);
    	//Test.setFixedSearchResults(new List<Id>{firstComment.Id});

    	Test.startTest();
    		ctrl.fetchBestComments();
			ctrl.assingBestComment();
		Test.stopTest();

		CAPL_BestVideoArticleComment__c comment = CAPL_BestVideoArticleComment__c.getValues('BestCommentBody');

		System.assertEquals(comment.Identifier__c, firstComment.CommentBody);
	}

	@isTest 
	static void assingCommentBackgroundTest() {
		CAPL_BestArticleAndVideoController ctrl = new CAPL_BestArticleAndVideoController();

		PageReference pageRef = Page.CAPL_BestArticleAndVideo;
    	
    	pageRef.getParameters().put('backgroundURL', 'background url');
    	
    	Test.setCurrentPage(pageRef);

    	Test.startTest();
			ctrl.assingCommentBackground();
		Test.stopTest();

		CAPL_BestVideoArticleComment__c background = CAPL_BestVideoArticleComment__c.getValues('BestCommentBackground');

		System.assertEquals(background.Identifier__c, 'background url');

	}
	
}