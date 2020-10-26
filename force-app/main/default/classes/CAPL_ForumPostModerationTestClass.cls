@isTest
private class CAPL_ForumPostModerationTestClass {

		@testSetup
    static void setup() {

    	Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

    	Network net = [SELECT Id, Name FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

        User u = new User();

        u.FirstName = 'TestName';
        u.LastName = 'TestSurname';
        u.Email = 'testedemail@email.com';
        u.Username = 'test@test.com.test!!!';
        u.Alias = 'astest';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
		
        insert u;

    	FeedItem firstFeed = new FeedItem(
    		Title = 'first feed title',
    		Body = 'first feed body',
    		Status = 'Published',
    		Type = 'QuestionPost',
    		ParentId = u.Id,
            NetworkScope = net.Id
    	);

    	FeedItem secondFeed = new FeedItem(
    		Title = 'second feed title',
    		Body = 'second feed body',
    		Status = 'Published',
    		Type = 'QuestionPost',
    		ParentId = u.Id,
            NetworkScope = net.Id
    	);

    	FeedItem thirdFeed = new FeedItem(
    		Title = 'third feed title',
    		Body = 'third feed body',
    		Status = 'Published',
    		Type = 'QuestionPost',
    		ParentId = u.Id,
            NetworkScope = net.Id
    	);

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
   	}
	
	@isTest 
	static void fetchFeedsTest() {
		List<FeedItem> feeds = [
			SELECT Id, Title, Body, Status, CreatedDate, CreatedBy.Name,
				(
				SELECT FeedItemId, CommentBody, Status, CreatedDate, CreatedBy.Name
				FROM FeedComments
				ORDER BY CreatedDate DESC 
				) 
			FROM FeedItem 
			WHERE Type != 'CreateRecordEvent'
				AND Type != 'TrackedChange'
			ORDER BY CreatedDate DESC 
		];

		CAPL_ForumPostModerationClass feed = new CAPL_ForumPostModerationClass();

		Test.startTest();
			FeedItem fi = new FeedItem();
			FeedComment fc = new FeedComment();

			CAPL_ForumPostModerationClass.Comments comment = new CAPL_ForumPostModerationClass.Comments(true, fc);

			CAPL_ForumPostModerationClass.Feeds fe = new CAPL_ForumPostModerationClass.Feeds(true, fi, new List<CAPL_ForumPostModerationClass.Comments>{comment});

			feed.fetchFeeds();
			feed.filterPosts();
			feed.sortFeeds(feeds);
		Test.stopTest();

		System.assertNotEquals(feed.feedList.size(), 1);
	}
	
	@isTest 
	static void removeFlagTest() {
		CAPL_ForumPostModerationClass feedClass = new CAPL_ForumPostModerationClass();

		FeedItem feed = [
			SELECT Id, Title, Body, Status
			FROM FeedItem
			WHERE Title = 'first feed title'
			LIMIT 1
		];

		PageReference pageRef = Page.CAPL_ForumPostModeration;
    	
    	pageRef.getParameters().put('feedId', feed.Id);

    	Test.setCurrentPage(pageRef);

		Test.startTest();
			feedClass.removeFlag();
		Test.stopTest();

		FeedItem approvedFeed = [
			SELECT Id, Title, Body, Status
			FROM FeedItem
			WHERE Title = 'first feed title'
			LIMIT 1
		];

		System.assertEquals(approvedFeed.Status, 'Published');
	}

    @isTest 
    static void deleteFeedTest() {
        CAPL_ForumPostModerationClass feedClass = new CAPL_ForumPostModerationClass();

        List<FeedItem> beforeDeleteList = [
            SELECT Id, Title, Body, Status
            FROM FeedItem
        ];

        FeedItem feed = [
            SELECT Id, Title, Body, Status
            FROM FeedItem
            WHERE Title = 'first feed title'
            LIMIT 1
        ];

        PageReference pageRef = Page.CAPL_ForumPostModeration;
        
        pageRef.getParameters().put('feedId', feed.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
            feedClass.deleteFeed();
        Test.stopTest();

        List<FeedItem> afterDeleteList = [
            SELECT Id, Title, Body, Status
            FROM FeedItem
        ];

        System.assertNotEquals(beforeDeleteList.size(), afterDeleteList.size());
    }
	
    @isTest 
    static void deleteFeedCommentTest() {
        CAPL_ForumPostModerationClass feedClass = new CAPL_ForumPostModerationClass();

        List<FeedComment> beforeDeleteList = [
            SELECT Id
            FROM FeedComment
        ];

        FeedComment feed = [
            SELECT Status
            FROM FeedComment
            WHERE CommentBody = 'test comment'
            LIMIT 1
        ];

        PageReference pageRef = Page.CAPL_ForumPostModeration;
        
        pageRef.getParameters().put('feedCommentId', feed.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
            feedClass.deleteFeedComment();
        Test.stopTest();

        List<FeedComment> afterDeleteList = [
            SELECT Id
            FROM FeedComment
        ];

        System.assertEquals(2, afterDeleteList.size());
    }
	
}