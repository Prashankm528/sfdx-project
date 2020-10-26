/****************************************************************************************************
 *  Date          : 25-AUG-2020 
 *  Author        : Sunny Yap
 *  Description   : Lead Trigger Helper Class.
 *  Modifications :
 *  25-AUG-2020   : SYAP Set team name.
 ****************************************************************************************************/

public with sharing class GCM_Lead_Trigger_Helper {

/****************************************************************************************************
 Set Team Name - References GCM_Data_Map__mdt Custom Metadata
 ****************************************************************************************************/ 
    public static void setTeamName(Map<Id, Lead> oldMap, Map<Id, Lead> newMap, List<Lead> leadList) {
        // Get In-Scope Cases
        try {
            List<Lead> leadSubSet = new List<Lead>();
            List<Id> ownerList = new List<Id>();
            for (Lead thisLead : leadList) {
                if (oldMap == null) {
                    leadSubSet.add(thisLead);
                    ownerList.add(thisLead.OwnerId);
                }
                else {
                    if (oldMap.get(thisLead.Id).OwnerId != thisLead.OwnerId) {
                        leadSubSet.add(thisLead);
                        ownerList.add(thisLead.OwnerId);
                    }
                }
            }
        
            if (leadSubSet.size() == 0) return;
        
            // Get User Map
            Map<Id, String> userMap = new Map<Id, String>();
            List<User> users = [select Id, GCM_Team_Name__c from User where Id in :ownerList];
            for (User thisUser : users) {
                userMap.put(thisUser.Id, thisUser.GCM_Team_Name__c);
            }
        
            // Get Queue Map
            Map<Id, String> queueMap = new Map<Id, String>();
            List<Group> queues = [select Id, DeveloperName from Group where Type = 'Queue' and Id in :ownerList];
            for (Group queue : queues) {
                queueMap.put(queue.Id, queue.DeveloperName);
            }
        
            // Get Data Map
            Map<String, String> valueMap = new Map<String, String>();
            List<GCM_Data_Map__mdt> dataMaps = [
                select
                    GCM_Source__c,
                    GCM_Target__c
                from
                    GCM_Data_Map__mdt
                where
                    GCM_Active__c = true and 
                    GCM_Source__c in :queueMap.values() and
                    GCM_Type__c = 'Queue_Team'
            ];
            for (GCM_Data_Map__mdt dataMap : dataMaps) {
                valueMap.put(dataMap.GCM_Source__c, dataMap.GCM_Target__c);
            }
        
            // Translate Values
            for (Lead thisLead : leadSubSet) {
                if (queueMap.containsKey(thisLead.OwnerId)) {
                    String queueName = queueMap.get(thisLead.OwnerId);
                    if (valueMap.containsKey(queueName)) {
                        thisLead.GCM_Owner_Team_Name__c = valueMap.get(queueName);
                    }
                    else {
                        thisLead.GCM_Owner_Team_Name__c = null;
                    }            
                }
                else if (userMap.containsKey(thisLead.OwnerId)) {
                    thisLead.GCM_Owner_Team_Name__c = userMap.get(thisLead.OwnerId);
                }
                else {
                    thisLead.GCM_Owner_Team_Name__c = null;
                }
            }
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Lead_Trigger_Helper', 'setTeamName', newMap.keySet(), 'GCM_Application_Administrator');               
        }
    }
}