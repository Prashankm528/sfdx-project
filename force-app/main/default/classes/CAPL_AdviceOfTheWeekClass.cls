public with sharing class CAPL_AdviceOfTheWeekClass {

	public class BestComment {
		@AuraEnabled
		public String commentBody {get; set;}
		@AuraEnabled
		public String commentCreatedBy {get; set;}

		public BestComment(String body, String createdBy) {
			commentBody = body;
			commentCreatedBy = createdBy;
		}
	}
	
	@AuraEnabled
	public static BestComment fetchBestComment() {
        String commentBody = CAPL_BestVideoArticleComment__c.getValues('BestCommentBody').Identifier__c;
        String commentCreatedBy = CAPL_BestVideoArticleComment__c.getValues('BestCommentCreatedBy').Identifier__c;

        BestComment bestComment = new BestComment(commentBody, commentCreatedBy);

        System.debug(bestComment);

	    return bestComment;
	}

	@AuraEnabled
	public static String fetchBestCommentBackground() {
        String backgroundURL = CAPL_BestVideoArticleComment__c.getValues('BestCommentBackground').Identifier__c != null ?
        	CAPL_BestVideoArticleComment__c.getValues('BestCommentBackground').Identifier__c :
        	'';

	    return backgroundURL;
	}
}