/**********************************************************************************************
 *  Date:           29UG18
 *  Author:         Andrey Dedovets
 *  Description:    Designed for CAPL admins. The purpose is to see articles/videos/posts(comments) 
 *                  created for the last week. Also Admin can assign article/video/comment as the best 
 *                  and it will be visible on the community home page.
 * ********************************************************************************************/
public without sharing class CAPL_BestArticleAndVideoController {

    public List<FeedComment> comments {get; set;} 
    public List<CAPL_Video__c> videosList {get; set;}
	public List<Knowledge__kav> articlesList {get; set;}
    public String backgroundURL {get; set;}

	public CAPL_BestArticleAndVideoController() {
		fetchBestVideo();
		fetchBestArticle();
        fetchBestComments();
        fetchCommentBackgroundURL();
	}

	public void fetchBestVideo() {
		videosList = [
            SELECT CAPL_Title__c, CAPL_Image__c, CAPL_Description__c, CAPL_LinkToVideo__c, CreatedDate
            FROM CAPL_Video__c
            WHERE CreatedDate > :Date.today().addDays(-7)
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
	} 

    Id caplRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge') != null ? Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge').getRecordTypeId() : '';

	public void fetchBestArticle() {
		articlesList = [
    		SELECT Id, Title, Summary, CAPL_ArticleBody__c, CAPL_ArticleImage__c, LastPublishedDate,
    		ArticleTotalViewCount
    		FROM Knowledge__kav
    		WHERE PublishStatus = 'Online'
    			AND Language = 'en_US'
                AND RecordTypeId = :caplRecordTypeId
                AND CreatedDate > :Date.today().addDays(-7)
    		ORDER BY ArticleTotalViewCount DESC
    		LIMIT 50
    	];
	}

    public void assingBestArticle() {
        String articleId = Apexpages.currentPage().getParameters().get('articleId');

        CAPL_BestVideoArticleComment__c article = CAPL_BestVideoArticleComment__c.getValues('BestArticle');
        article.Identifier__c = articleId;

        try {
            update article;

        } catch (DmlException ex) {
            ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(erorMessage);
        }
    }

    public void assingBestVideo() {
        String videoId = Apexpages.currentPage().getParameters().get('videoId');

        CAPL_BestVideoArticleComment__c video = CAPL_BestVideoArticleComment__c.getValues('BestVideo');
        video.Identifier__c = videoId;

        try {
            update video;

        } catch (DmlException ex) {
            ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(erorMessage);
        }
    }

    public void assingBestComment() {
        String commentId = Apexpages.currentPage().getParameters().get('commentId');

        FeedComment comment = new FeedComment();

        for (FeedComment item: comments) {
            if (item.Id == commentId) {
                comment = item;
            }
        }

        CAPL_BestVideoArticleComment__c commentBody = CAPL_BestVideoArticleComment__c.getValues('BestCommentBody');
        commentBody.Identifier__c = comment.CommentBody;

        CAPL_BestVideoArticleComment__c commentCreatedBy = CAPL_BestVideoArticleComment__c.getValues('BestCommentCreatedBy');
        commentCreatedBy.Identifier__c = comment.CreatedBy.Name;

        try {
            update commentBody;
            update commentCreatedBy;

        } catch (DmlException ex) {
            ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(erorMessage);
        }

        List<NetworkMember> communityUsersList = [
            SELECT ReputationPoints, MemberId
            FROM NetworkMember
            WHERE MemberId = :comment.CreatedById
            ORDER BY CreatedDate DESC
        ];

        if (!communityUsersList.isEmpty()) {
            communityUsersList.get(0).ReputationPoints += 2500;

            try {
                update communityUsersList.get(0);

            } catch (DmlException ex) {
                ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                ApexPages.addMessage(erorMessage);
            }
        }
        
    }
    
     public void fetchBestComments() {
        Network net = [SELECT Id, Name FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

        if (net == null) {return;}

        comments = new List<FeedComment>();

        List<FeedItem> feedItemsList = [
            SELECT Id, 
            	(
                	SELECT Id, FeedItemId, CommentBody, CreatedBy.Name, CreatedById 
                    FROM FeedComments
                    WHERE CreatedDate > LAST_WEEK
                ) 
            FROM FeedItem
            WHERE NetworkScope = :net.Id
            LIMIT 10000
        ];

        for (FeedItem item : feedItemsList) {
            comments.addAll(item.FeedComments);
        } 
    }

    public void fetchCommentBackgroundURL() {
        CAPL_BestVideoArticleComment__c background = CAPL_BestVideoArticleComment__c.getValues('BestCommentBackground');

        if (background != null) {
            backgroundURL = background.Identifier__c;
        } else {
            backgroundURL = '';
        }
    }

    public void assingCommentBackground() {
        String backgroundURL = Apexpages.currentPage().getParameters().get('backgroundURL');

        CAPL_BestVideoArticleComment__c background = CAPL_BestVideoArticleComment__c.getValues('BestCommentBackground');
        background.Identifier__c = backgroundURL;

        try {
            update background;

        } catch (DmlException ex) {
            ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(erorMessage);
        }
    }
}