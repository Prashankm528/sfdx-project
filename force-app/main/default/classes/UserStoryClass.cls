public with sharing class UserStoryClass {
    public UserStoryClass() {

    }

    @AuraEnabled(cacheable = true)
    public static List<User_Story__c> getUserStory(){
        return [select Id,Description__c, Title__c,Name, Project__c, Replication_Step__c, Solution__c, 
        Status__c, Story_Points__c,  AssignedTo__c,Project__r.Name,Project__r.Color__c, Comments__c, AssignedTo__r.Name from User_Story__c];
    }

    @AuraEnabled
    public static void Uploadfile(string Id , string file, string fileName){
       system.debug('inside upload file');
       ContentVersion contentVersionRec = new ContentVersion();  
       contentVersionRec.Title = fileName;  
       contentVersionRec.PathOnClient = '/' + fileName;  
       contentVersionRec.FirstPublishLocationId = Id;  
       contentVersionRec.VersionData = Blob.valueOf('Test Content'); 
       contentVersionRec.IsMajorVersion = true;  
       Insert contentVersionRec;  
       system.debug(contentVersionRec.Id);

    }
}
