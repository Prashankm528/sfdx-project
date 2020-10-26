/*****************************************************************************************
*        Date:          6th June 2020
*       Author:         Praneeth Indraganti
*       Description:    
*       Modifications:  
****************************************************************************************/
global with sharing class LCP_CreateProjectObjectSharingRulesBatch implements Database.Batchable<Sobject>,Database.Stateful{

     public Map<String,List<Id>> mapGroupandUsers;
     public List<LCP_Project__Share> projectShareRecords;
     public List<Id> userIdVal;
     public List<string> lstGroup;
     public List<Id> projectIds;
     public LCP_CreateProjectObjectSharingRulesBatch(List<Id> userIds)
     {
         system.debug('hi hello');
         projectIds = new List<Id>();
         mapGroupandUsers = new Map<String,List<Id>>();
         userIdVal = new List<Id>();
         userIdVal.addAll(userIds);
         projectShareRecords = new List<LCP_Project__Share>();
    
         system.debug('userIds is'+userIds);
        for(User contactRelatedToUser:[select Id,LCP_Grouping__c from User where ID IN: userIdVal and LCP_Grouping__c!=null limit 10000])
        {
            if(mapGroupandUsers.containsKey(contactRelatedToUser.LCP_Grouping__c)) {
                List<Id> usersWithGrouping = mapGroupandUsers.get(contactRelatedToUser.LCP_Grouping__c);
                usersWithGrouping.add(contactRelatedToUser.Id);
                mapGroupandUsers.put(contactRelatedToUser.LCP_Grouping__c, usersWithGrouping);
            } else {
                mapGroupandUsers.put(contactRelatedToUser.LCP_Grouping__c, new List<Id> { contactRelatedToUser.Id });
            }
            system.debug('mapGroupandUser is'+mapGroupandUsers);
        }
     }
     
     public LCP_CreateProjectObjectSharingRulesBatch(List<Id> userIds,List<Id> projectId)
     {
         system.debug('hi hello'+projectId);
         mapGroupandUsers = new Map<String,List<Id>>();
         userIdVal = new List<Id>();
         userIdVal.addAll(userIds);
          projectIds = new List<Id>();
          projectIds.addAll(projectId);
         projectShareRecords = new List<LCP_Project__Share>();
        for(User contactRelatedToUser1:[select Id,LCP_Grouping__c from User where ID IN: userIdVal and LCP_Grouping__c!=null limit 10000]){
            if(mapGroupandUsers.containsKey(contactRelatedToUser1.LCP_Grouping__c)) {
                List<Id> usersWithGrouping = mapGroupandUsers.get(contactRelatedToUser1.LCP_Grouping__c);
                usersWithGrouping.add(contactRelatedToUser1.Id);
                mapGroupandUsers.put(contactRelatedToUser1.LCP_Grouping__c, usersWithGrouping);
            } else {
                mapGroupandUsers.put(contactRelatedToUser1.LCP_Grouping__c, new List<Id> { contactRelatedToUser1.Id });
            }
            system.debug('mapGroupandUser is'+mapGroupandUsers);
        }
     }
    //Method to get the data to be proceesed  
    global database.Querylocator Start(Database.BatchableContext bc){
        lstGroup = new List<String>();
        lstGroup.addAll(mapGroupandUsers.keyset());
        system.debug('lstGroup is'+lstGroup);
        String query;
        if(projectIds.size()>0)
            query = 'select Id,LCP_Grouping__c from LCP_Project__c where LCP_Grouping__c IN: lstGroup AND LCP_Grouping__c!=null AND ID IN: projectIds';
        else
            query = 'select Id,LCP_Grouping__c from LCP_Project__c where LCP_Grouping__c IN: lstGroup AND LCP_Grouping__c!=null';
        return Database.getQueryLocator(query);
    }
 
 
    //Method to execute the batch
    global void execute(Database.BatchableContext bc, Sobject[] scope){
        for(Sobject s : scope){ 
            LCP_Project__c projectWithGrouping = (LCP_Project__c)s;
            List<Id> lstIds = new List<Id>();
             if(mapGroupandUsers.get(projectWithGrouping.LCP_Grouping__c)!=null)
            {
                lstIds.addAll(mapGroupandUsers.get(projectWithGrouping.LCP_Grouping__c));
            }
           for(Id idVal:lstIds)
           {
                LCP_Project__Share projectShareRecord = new LCP_Project__Share();
                projectShareRecord.ParentId = projectWithGrouping.Id;
                projectShareRecord.UserOrGroupId = idVal;
                projectShareRecord.AccessLevel = 'Read';
                projectShareRecord.RowCause = 'Manual';
                
                projectShareRecords.add(projectShareRecord);
            }   

        }
        
        if(projectShareRecords.size()>0)
        {
            insert projectShareRecords;
        }
    }
 
    //Method to be called after the excute
    global void finish(Database.BatchableContext bc){
        if(projectIds.size()>0)
        {
            LCP_CreateRPPropObjectSharingRulesBatch createRPSharingRules = new LCP_CreateRPPropObjectSharingRulesBatch(userIdVal,projectIds); 
            database.executeBatch(createRPSharingRules);
        }
        else
        {
            LCP_CreateRPPropObjectSharingRulesBatch createRPSharingRules = new LCP_CreateRPPropObjectSharingRulesBatch(userIdVal); 
            database.executeBatch(createRPSharingRules);
        }
    }
}