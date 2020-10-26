/*****************************************************************************************
*        Date:          6th June 2020
*       Author:         Praneeth Indraganti
*       Description:    
*       Modifications:  
****************************************************************************************/
public with sharing class LCP_RecordSharingClassOnProjectUpsert{

    @InvocableMethod(label='Project_SharingRules' description='Creating Sharing Rules for Project and Reporting Period Proposal')
    public static void creatingSharingRulesBasedonProject(List<Id> projectIds) {
       
        Set<String> groupStrings = new Set<String>();
        List<Id> userIds = new List<Id>();
        List<Id> projectId = new List<Id>();
        
       for(LCP_Project__c projectWithGrouping:[select Id,LCP_Grouping__c from LCP_Project__c where ID IN: projectIds limit 10000]){
           projectId.add(projectWithGrouping.Id);
           groupStrings.add(projectWithGrouping.LCP_Grouping__c);
       }
       for(User userWithGrouping:[select Id from User where LCP_Grouping__c IN:groupStrings]){
           userIds.add(userWithGrouping.Id);
       }
       system.debug('project Id values are'+projectId);
       LCP_CreateProjectObjectSharingRulesBatch createSharingRules = new LCP_CreateProjectObjectSharingRulesBatch(userIds,projectId); 
        database.executeBatch(createSharingRules);
    }
    
}