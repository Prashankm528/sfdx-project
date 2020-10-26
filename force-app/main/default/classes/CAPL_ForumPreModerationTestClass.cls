@isTest
private class CAPL_ForumPreModerationTestClass {

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
    		Status = 'PendingReview',
    		Type = 'TextPost',
    		ParentId = u.Id,
            NetworkScope = net.Id
    	);

    	FeedItem secondFeed = new FeedItem(
    		Title = 'second feed title',
    		Body = 'second feed body',
    		Status = 'PendingReview',
    		Type = 'TextPost',
    		ParentId = u.Id,
            NetworkScope = net.Id
    	);

    	FeedItem thirdFeed = new FeedItem(
    		Title = 'third feed title',
    		Body = 'third feed body',
    		Status = 'Published',
    		Type = 'TextPost',
    		ParentId = u.Id,
            NetworkScope = net.Id
    	);

    	insert firstFeed;
    	
    	insert thirdFeed;

        FeedComment firstComment = new FeedComment(
            FeedItemId = thirdFeed.Id,
            CommentBody = 'test comment',
            Status = 'PendingReview'
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
	static void fetchPendingFeedsTest() {
		CAPL_ForumPreModerationClass feed = new CAPL_ForumPreModerationClass();

		Test.startTest();
			feed.fetchFeeds();
		Test.stopTest();

		System.assertNotEquals(feed.feedList.size(), 1);
	}
	
	@isTest 
	static void approveFeedTest() {
		CAPL_ForumPreModerationClass feedClass = new CAPL_ForumPreModerationClass();

		FeedItem feed = [
			SELECT Id, Title, Body, Status
			FROM FeedItem
			WHERE Title = 'first feed title'
			LIMIT 1
		];

		PageReference pageRef = Page.CAPL_ForumPreModeration;
    	
    	pageRef.getParameters().put('feedId', feed.Id);

    	Test.setCurrentPage(pageRef);

		Test.startTest();
			feedClass.approveFeed();
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
        CAPL_ForumPreModerationClass feedClass = new CAPL_ForumPreModerationClass();

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

        PageReference pageRef = Page.CAPL_ForumPreModeration;
        
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
    static void approveFeedCommentTest() {
        CAPL_ForumPreModerationClass feedClass = new CAPL_ForumPreModerationClass();

        FeedComment feed = [
            SELECT Status
            FROM FeedComment
            WHERE CommentBody = 'test comment'
            LIMIT 1
        ];

        PageReference pageRef = Page.CAPL_ForumPreModeration;
        
        pageRef.getParameters().put('feedCommentId', feed.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
            feedClass.approveFeedComment();
        Test.stopTest();

        FeedComment approvedFeed = [
            SELECT Status
            FROM FeedComment
            WHERE CommentBody = 'test comment'
            LIMIT 1
        ];

        System.assertEquals(approvedFeed.Status, 'Published');
    }
	
        @isTest 
    static void deleteFeedCommentTest() {
        CAPL_ForumPreModerationClass feedClass = new CAPL_ForumPreModerationClass();

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

        PageReference pageRef = Page.CAPL_ForumPreModeration;
        
        pageRef.getParameters().put('feedCommentId', feed.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
            feedClass.deleteFeedComment();
        Test.stopTest();

        List<FeedComment> afterDeleteList = [
            SELECT Id
            FROM FeedComment
        ];

        System.assertNotEquals(beforeDeleteList.size(), afterDeleteList.size());
    }
	
}