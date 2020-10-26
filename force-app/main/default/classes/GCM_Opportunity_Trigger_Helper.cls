/****************************************************************************************************
 *  Date          : 25-AUG-2020 
 *  Author        : Sunny Yap
 *  Description   : Opportunity Trigger Helper Class.
 *  Modifications :
 *  25-AUG-2020   : SYAP Set team name.  Queue capability commented waiting for Summer 2021 Release.
 ****************************************************************************************************/

public with sharing class GCM_Opportunity_Trigger_Helper {

/****************************************************************************************************
 Set Team Name - References GCM_Data_Map__mdt Custom Metadata
 ****************************************************************************************************/ 
    public static void setTeamName(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap, List<Opportunity> optyList) {
        // Get In-Scope Cases
        try {
            List<Opportunity> optySubSet = new List<Opportunity>();
            List<Id> ownerList = new List<Id>();
            for (Opportunity thisOpty : optyList) {
                if (oldMap == null) {
                    optySubSet.add(thisOpty);
                    ownerList.add(thisOpty.OwnerId);
                }
                else {
                    if (oldMap.get(thisOpty.Id).OwnerId != thisOpty.OwnerId) {
                        optySubSet.add(thisOpty);
                        ownerList.add(thisOpty.OwnerId);
                    }
                }
            }
        
            if (optySubSet.size() == 0) return;
        
            // Get User Map
            Map<Id, String> userMap = new Map<Id, String>();
            List<User> users = [select Id, GCM_Team_Name__c from User where Id in :ownerList];
            for (User thisUser : users) {
                userMap.put(thisUser.Id, thisUser.GCM_Team_Name__c);
            }
        
            // Get Queue Map
            /*
            Map<Id, String> queueMap = new Map<Id, String>();
            List<Group> queues = [select Id, DeveloperName from Group where Type = 'Queue' and Id in :ownerList];
            for (Group queue : queues) {
                queueMap.put(queue.Id, queue.DeveloperName);
            }
			*/
        
            // Get Data Map
            /*
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
        	*/
            
            // Translate Values
            for (Opportunity thisOpty : optySubSet) {
                /*
                if (queueMap.containsKey(thisOpty.OwnerId)) {
                    String queueName = queueMap.get(thisOpty.OwnerId);
                    if (valueMap.containsKey(queueName)) {
                        thisOpty.GCM_Owner_Team_Name__c = valueMap.get(queueName);
                    }
                    else {
                        thisOpty.GCM_Owner_Team_Name__c = null;
                    }            
                }
                else
				*/
				if (userMap.containsKey(thisOpty.OwnerId)) {
                    thisOpty.GCM_Owner_Team_Name__c = userMap.get(thisOpty.OwnerId);
                }
                else {
                    thisOpty.GCM_Owner_Team_Name__c = null;
                }
            }
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Opportunity_Trigger_Helper', 'setTeamName', newMap.keySet(), 'GCM_Application_Administrator');               
        }
    }
}