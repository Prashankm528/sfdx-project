public with sharing class CAPL_BestVideoAndArticleController {

	@AuraEnabled
	public static CAPL_Video__c fetchBestVideo() {
        String videoId = CAPL_BestVideoArticleComment__c.getValues('BestVideo').Identifier__c;

        if (videoId != null) {
            List<CAPL_Video__c> videoList = [
                SELECT CAPL_Title__c, CAPL_Image__c, CAPL_Description__c, CAPL_LinkToVideo__c, CreatedDate
                FROM CAPL_Video__c
                WHERE Id = :videoId
            ];

            return !videoList.isEmpty() ? videoList.get(0) : new CAPL_Video__c();
        } else {
            List<CAPL_Video__c> videoList = [
                SELECT CAPL_Title__c, CAPL_Image__c, CAPL_Description__c, CAPL_LinkToVideo__c, CreatedDate
                FROM CAPL_Video__c
                ORDER BY CreatedDate DESC
                LIMIT 10
            ];

            return videoList.get(0);
        }

		
	}

	@AuraEnabled
	public static Knowledge__kav fetchBestArticle() {
        String articleId = CAPL_BestVideoArticleComment__c.getValues('BestArticle').Identifier__c;
        Id caplRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge') != null ? Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge').getRecordTypeId() : '';


        if (articleId != null) {
            List<Knowledge__kav> articles = [
                SELECT Id, Title, Summary, CAPL_ArticleBody__c, CAPL_ArticleImage__c, 
                LastPublishedDate, ArticleTotalViewCount
                FROM Knowledge__kav
                WHERE Id = :articleId
                    AND RecordTypeId = :caplRecordTypeId
            ];

            return !articles.isEmpty() ? articles.get(0) : new Knowledge__kav();
        } else {
            List<Knowledge__kav> articles = [
                SELECT Id, Title, Summary, CAPL_ArticleBody__c, CAPL_ArticleImage__c, 
                LastPublishedDate, ArticleTotalViewCount
                FROM Knowledge__kav
                    WHERE RecordTypeId = :caplRecordTypeId
                ORDER BY ArticleTotalViewCount DESC
                LIMIT 10
            ];

            return articles.get(0);
        }
	}
}