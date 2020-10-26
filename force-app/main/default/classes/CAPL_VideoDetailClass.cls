public with sharing class CAPL_VideoDetailClass {

    /*
    * used to fetch recordType of current CAPL_Video__c record 
    */

    @AuraEnabled
    public static String fetchRecordTypeName(String videoId) {
        List<CAPL_Video__c> videoList = [
            SELECT RecordType.Name
            FROM CAPL_Video__c
            WHERE Id = :videoId
        ];

        CAPL_Video__c video = new CAPL_Video__c();

        if (!videoList.isEmpty()) {
            video = videoList.get(0);
        }

        return video.RecordType.Name;
    }

    /*
    * used to fetch current CAPL_Video__c record 
    */    

    @AuraEnabled
    public static CAPL_Video__c fetchVideoDetails(String videoId) {
        List<CAPL_Video__c> videoList = [
            SELECT CAPL_Title__c, CAPL_Image__c, CAPL_Description__c, CAPL_LinkToVideo__c, CreatedDate
            FROM CAPL_Video__c
            WHERE Id = :videoId
        ];

        CAPL_Video__c video = new CAPL_Video__c();

        if (!videoList.isEmpty()) {
            video = videoList.get(0);
        }

        return video;
    }

    /*
    * used to fetch file attached to the current CAPL_Video__c record 
    */ 

    @AuraEnabled
    public static String fetchAttachedDocumentId(String videoId) {
        List<CAPL_Video__c> videoList = [
            SELECT CAPL_Title__c, CreatedDate
            FROM CAPL_Video__c
            WHERE Id = :videoId
        ];

        CAPL_Video__c video = new CAPL_Video__c();

        if (!videoList.isEmpty()) {
            video = videoList.get(0);
        }

        List<ContentDocumentLink> documentList = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :video.Id
        ];

        ContentDocumentLink documentLink = new ContentDocumentLink();

        if (!documentList.isEmpty()) {
            documentLink = documentList.get(0);
        }

        List<ContentVersion> contentVersionList = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId = :documentLink.ContentDocumentId
        ];

        ContentVersion contentVersion = new ContentVersion();

        if (!contentVersionList.isEmpty()) {
            contentVersion = contentVersionList.get(0);
        }

        List<ContentDistribution> contentDistributionList = [
            SELECT Id, Name, ContentDownloadUrl 
            FROM ContentDistribution 
            WHERE ContentVersionId = :contentVersion.Id
            ORDER BY CreatedDate DESC
        ];

        ContentDistribution contentDistribution = new ContentDistribution();

        if (!contentDistributionList.isEmpty()) {
            contentDistribution = contentDistributionList.get(0);
        }

        return contentDistribution.ContentDownloadUrl;
    }

   
}