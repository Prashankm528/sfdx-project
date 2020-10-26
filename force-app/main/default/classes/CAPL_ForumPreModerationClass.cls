public without sharing class CAPL_ForumPreModerationClass {

	public List<FeedItem> feedList {get; set;}

	public CAPL_ForumPreModerationClass() {
		fetchFeeds();
	}

	public void fetchFeeds() {
		feedList = new List<FeedItem>();

		List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

	    if (networks.isEmpty()) {
	        return;
	    }

		List<FeedItem> preFeedList = [
			SELECT Id, Title, Body, Status, CreatedDate, CreatedBy.Name,
				(
				SELECT FeedItemId, CommentBody, Status, CreatedDate, CreatedBy.Name
				FROM FeedComments
				ORDER BY CreatedDate DESC 
				) 
			FROM FeedItem 
			WHERE NetworkScope = :networks.get(0).Id
			ORDER BY CreatedDate DESC 
			LIMIT 50000
		];

		for (FeedItem feed : preFeedList) {
			if (feed.Status == 'PendingReview') {
				feedList.add(feed);
			} else {
				for (FeedComment comment : feed.FeedComments) {
					if (comment.Status == 'PendingReview') {
						feedList.add(feed);
					}
				}
			}			
		}
	}

	/*
	* used to change status of FeedItem from 'Pending Review' to 'Published'
	*/

	public void approveFeed() {
		String feedId = Apexpages.currentPage().getParameters().get('feedId');

		List<FeedItem> feedList = [
			SELECT Id, Title, Body, Status
			FROM FeedItem
			WHERE Id = :feedId
		];

		if (!feedList.isEmpty()) {
			feedList.get(0).Status = 'Published';

			try {
				update feedList.get(0);

			} catch(DmlException ex) {
				ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
				ApexPages.addMessage(erorMessage);
			}
		}

		fetchFeeds();
	}

	/*
	* used to delete selected FeedItem and all his comments
	*/

	public void deleteFeed() {
		String feedId = Apexpages.currentPage().getParameters().get('feedId');

		List<FeedItem> feedList = [
			SELECT Id, Title, Body, Status
			FROM FeedItem
			WHERE Id = :feedId
		];

		if (!feedList.isEmpty()) {

			try {
				delete feedList.get(0);

			} catch(DmlException ex) {
				ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
				ApexPages.addMessage(erorMessage);
			}
		}

		fetchFeeds();
	}

	/*
	* used to approve selected FeedComment and all his comments
	*/

	public void approveFeedComment() {
		String feedCommentId = Apexpages.currentPage().getParameters().get('feedCommentId');

		List<FeedComment> feedCommentList = [
			SELECT Status
			FROM FeedComment
			WHERE Id = :feedCommentId
		];

		if (!feedCommentList.isEmpty()) {
			feedCommentList.get(0).Status = 'Published';

			try {
				update feedCommentList.get(0);

			} catch(DmlException ex) {
				ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
				ApexPages.addMessage(erorMessage);
			}
		}

		fetchFeeds();
	}

	/*
	* used to approve selected FeedComment and all his comments
	*/

	public void deleteFeedComment() {
		String feedCommentId = Apexpages.currentPage().getParameters().get('feedCommentId');

		List<FeedComment> feedCommentList = [
			SELECT Status
			FROM FeedComment
			WHERE Id = :feedCommentId
		];

		if (!feedCommentList.isEmpty()) {

			try {
				delete feedCommentList.get(0);

			} catch(DmlException ex) {
				ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
				ApexPages.addMessage(erorMessage);
			}
		}

		fetchFeeds();
	}
}