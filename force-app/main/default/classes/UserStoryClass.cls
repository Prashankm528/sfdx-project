public with sharing class UserStoryClass {
    public UserStoryClass() {

    }

    @AuraEnabled(cacheable = true)
    public static List<User_Story__c> getUserStory(){
        return [select Id,Description__c, Title__c,Name, Project__c, Replication_Step__c, Solution__c, 
        Status__c, Story_Points__c, Priorty__c, AssignedTo__c,Project__r.Name,Project__r.Color__c, AssignedTo__r.Picture__c,
        Comments__c, AssignedTo__r.Name from User_Story__c];
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

    @AuraEnabled
    public static list<contentversion> releatedFiles(Id idParent){
        list<id> lstConDocs = new list<id>();
        for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:idParent]) {
            lstConDocs.add(cntLink.ContentDocumentId);
        }
        if(!lstConDocs.isEmpty()) {
            return [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :lstConDocs];
        }
        else {
            return null;
        }
     
    }

    @AuraEnabled
    public static ContentVersion saveFile(Id idParent, String strFileName, String base64Data) {
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        return cv;
    }
}
