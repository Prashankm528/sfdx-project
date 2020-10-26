@isTest
private class CAPL_AdviceOfTheWeekTestClass {
	@testSetup
	static void setup() {
		List<CAPL_BestVideoArticleComment__c> commentComponents = new List<CAPL_BestVideoArticleComment__c>();

		CAPL_BestVideoArticleComment__c commentBody = new CAPL_BestVideoArticleComment__c(
			Name = 'BestCommentBody',
			Identifier__c = 'test comment'
		);

		CAPL_BestVideoArticleComment__c commentCreatedBy = new CAPL_BestVideoArticleComment__c(
			Name = 'BestCommentCreatedBy',
			Identifier__c = 'test user'
		);

		CAPL_BestVideoArticleComment__c commentBackground = new CAPL_BestVideoArticleComment__c(
			Name = 'BestCommentBackground',
			Identifier__c = 'https://images.com/testimage'
		);

		commentComponents.add(commentBody);
		commentComponents.add(commentCreatedBy);
		commentComponents.add(commentBackground);

		insert commentComponents;
	}
	
	@isTest 
	static void fetchBestCommentTest() {
		Test.startTest();
			CAPL_AdviceOfTheWeekClass.BestComment bestComment = CAPL_AdviceOfTheWeekClass.fetchBestComment();
		Test.stopTest();

		System.assertNotEquals(bestComment, null);
	}
	
	@isTest 
	static void fetchBestCommentBackgroundTest() {
		Test.startTest();
			String background = CAPL_AdviceOfTheWeekClass.fetchBestCommentBackground();
		Test.stopTest();

		System.assertNotEquals(background, null);
	}
	
}