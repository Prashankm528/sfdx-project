public with sharing class UserStoryClass {
    public UserStoryClass() {

    }

    @AuraEnabled(cacheable = true)
    public static List<User_Story__c> getUserStory(){
        return [select Id,Description__c, Title__c,Name, Project__c, Replication_Step__c, Solution__c, 
        Status__c, Story_Points__c,  AssignedTo__c,Project__r.Name, Comments__c, AssignedTo__r.Name from User_Story__c];
    }
}
