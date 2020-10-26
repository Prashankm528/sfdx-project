public with sharing class CAPL_ArticlesListController {

    @AuraEnabled
    public static List<Knowledge__kav> fetchArticles(String topicId) {

        User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];

        List<TopicAssignment> tsa = [
            SELECT EntityId 
            FROM TopicAssignment 
            WHERE TopicId = :topicId
            LIMIT 1000
        ];

        Set<Id> ids = new Set<Id>();

        for (TopicAssignment t : tsa) {
            ids.add(t.EntityId);
        }

        String online = 'Online';

        Id caplRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge') != null ? Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge').getRecordTypeId() : '';

        String query  = 'SELECT Id, Title, Summary, CAPL_ArticleBody__c, CAPL_ArticleImage__c, LastPublishedDate, ' +
            ' ArticleCreatedBy.Name, ArticleTotalViewCount ' +
            ' FROM Knowledge__kav ' +
            ' WHERE PublishStatus = ' +   '\'' + String.escapeSingleQuotes(online)+ '\'' +
                ' AND Language = ' + '\'' + String.escapeSingleQuotes(u.LanguageLocaleKey)+ '\'' +
                ' AND RecordTypeId = '  + '\'' + String.escapeSingleQuotes(caplRecordTypeId)+ '\'' +
                ' AND Id IN :ids' +
            ' ORDER BY LastPublishedDate DESC ' +
            ' LIMIT 10';

        List<Knowledge__kav> articles = Database.query(query);


        return articles;
    }

}