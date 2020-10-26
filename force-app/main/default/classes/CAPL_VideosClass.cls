public with sharing class CAPL_VideosClass {

    /*
    * used to fetch CAPL_Video__c records 
    */

	@AuraEnabled
    public static List<CAPL_Video__c> fetchVideos() {
    	List<CAPL_Video__c> videoList = [
            SELECT CAPL_Title__c, CAPL_Image__c, CAPL_Description__c, CAPL_LinkToVideo__c, CreatedDate
            FROM CAPL_Video__c
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];

        return videoList;	
    }
}