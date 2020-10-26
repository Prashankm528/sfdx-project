/*****************************************************************************************
*        Date:          6th June 2020
*       Author:         Praneeth Indraganti
*       Description:    
*       Modifications:  
****************************************************************************************/
global with sharing class LCP_CreateRPPropObjectSharingRulesBatch implements Database.Batchable<Sobject>{

     public Map<String,List<Id>> mapGroupandUsers;
     public List<LCP_Reporting_Period_Proposal__Share> rpProposalShareRecords;
     public List<string> lstGroup;
     public List<Id> projectIds;
     public List<Id> rpIds;
     
     public LCP_CreateRPPropObjectSharingRulesBatch(List<Id> userIds)
     {
         mapGroupandUsers = new Map<String,List<Id>>();
          rpIds = new List<ID>();
           projectIds = new List<Id>();
         rpProposalShareRecords = new List<LCP_Reporting_Period_Proposal__Share>();
         
        for(User contactRelatedToUsers:[select Id,LCP_Grouping__c from User where ID IN: userIds and LCP_Grouping__c!=null limit 10000])
        {
            if(mapGroupandUsers.containsKey(contactRelatedToUsers.LCP_Grouping__c)) {
                List<Id> usersWithGrouping = mapGroupandUsers.get(contactRelatedToUsers.LCP_Grouping__c);
                usersWithGrouping.add(contactRelatedToUsers.Id);
                mapGroupandUsers.put(contactRelatedToUsers.LCP_Grouping__c, usersWithGrouping);
            } else {
                mapGroupandUsers.put(contactRelatedToUsers.LCP_Grouping__c, new List<Id> { contactRelatedToUsers.Id });
            }
        }
     }
       public LCP_CreateRPPropObjectSharingRulesBatch(List<Id> userIds,List<Id> projectId)
     {
         mapGroupandUsers = new Map<String,List<Id>>();
         rpProposalShareRecords = new List<LCP_Reporting_Period_Proposal__Share>();
         rpIds = new List<ID>();
         projectIds = new List<Id>();
         projectIds.addAll(projectId);
        for(User contactRelatedToUsers:[select Id,LCP_Grouping__c from User where ID IN: userIds and LCP_Grouping__c!=null limit 10000])
        {
            if(mapGroupandUsers.containsKey(contactRelatedToUsers.LCP_Grouping__c)) {
                List<Id> usersWithGrouping = mapGroupandUsers.get(contactRelatedToUsers.LCP_Grouping__c);
                usersWithGrouping.add(contactRelatedToUsers.Id);
                mapGroupandUsers.put(contactRelatedToUsers.LCP_Grouping__c, usersWithGrouping);
            } else {
                mapGroupandUsers.put(contactRelatedToUsers.LCP_Grouping__c, new List<Id> { contactRelatedToUsers.Id });
            }
        }
     }
     public LCP_CreateRPPropObjectSharingRulesBatch(List<Id> userIds,List<Id> rpId,List<Id> projectId)
     {
         mapGroupandUsers = new Map<String,List<Id>>();
         rpProposalShareRecords = new List<LCP_Reporting_Period_Proposal__Share>();
         rpIds = new List<ID>();
         rpIds.addAll(rpId);
        for(User contactRelatedToUsers:[select Id,LCP_Grouping__c from User where ID IN: userIds and LCP_Grouping__c!=null limit 10000])
        {
            if(mapGroupandUsers.containsKey(contactRelatedToUsers.LCP_Grouping__c)) {
                List<Id> usersWithGrouping = mapGroupandUsers.get(contactRelatedToUsers.LCP_Grouping__c);
                usersWithGrouping.add(contactRelatedToUsers.Id);
                mapGroupandUsers.put(contactRelatedToUsers.LCP_Grouping__c, usersWithGrouping);
            } else {
                mapGroupandUsers.put(contactRelatedToUsers.LCP_Grouping__c, new List<Id> { contactRelatedToUsers.Id });
            }
        }
     }
    //Method to get the data to be proceesed  
    global database.Querylocator Start(Database.BatchableContext bc){
    
        lstGroup = new List<String>();
        lstGroup.addAll(mapGroupandUsers.keyset());
        
        String query;
        if(rpIds.size()>0)
            query = 'Select Id,LCP_Reporting_Period__r.LCP_Grouping__c from LCP_Reporting_Period_Proposal__c Where LCP_Reporting_Period__r.LCP_Grouping__c IN: lstGroup AND ID IN:rpIds';
        else if(projectIds.size()>0)
            query = 'Select Id,LCP_Reporting_Period__r.LCP_Grouping__c from LCP_Reporting_Period_Proposal__c Where LCP_Reporting_Period__r.LCP_Grouping__c IN: lstGroup AND LCP_Reporting_Period__r.LCP_Project__c IN:projectIds';
        else
            query = 'Select Id,LCP_Reporting_Period__r.LCP_Grouping__c from LCP_Reporting_Period_Proposal__c Where LCP_Reporting_Period__r.LCP_Grouping__c IN: lstGroup';
        
        return Database.getQueryLocator(query);
    }
 
 
    //Method to execute the batch
    global void execute(Database.BatchableContext bc, Sobject[] scope){
        for(Sobject s : scope){ 
            LCP_Reporting_Period_Proposal__c rpPropRecord = (LCP_Reporting_Period_Proposal__c)s;
             List<Id> lstIds = new List<Id>();
             if(mapGroupandUsers.get(rpPropRecord.LCP_Reporting_Period__r.LCP_Grouping__c)!=null)
            {
                lstIds.addAll(mapGroupandUsers.get(rpPropRecord.LCP_Reporting_Period__r.LCP_Grouping__c));
            }
           for(Id idVal2:lstIds)
           {
               LCP_Reporting_Period_Proposal__Share rpPropShareRecord = new LCP_Reporting_Period_Proposal__Share();
                rpPropShareRecord.ParentId = rpPropRecord.Id;
                rpPropShareRecord.UserOrGroupId = idVal2;
                rpPropShareRecord.AccessLevel = 'Edit';
                rpPropShareRecord.RowCause = 'Manual';
                
                rpProposalShareRecords.add(rpPropShareRecord);
            }  
        }
        
        if(rpProposalShareRecords.size()>0)
        {
            Database.SaveResult[] srList = Database.insert(rpProposalShareRecords, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted RP Proposal Share records ' + sr.getId());
                }
                else
                {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }

        }
    }
 
    //Method to be called after the excute
    global void finish(Database.BatchableContext bc){
        
    }
}