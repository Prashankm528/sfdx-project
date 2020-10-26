/****************************************************************************************************
 *  Date          : 27-APR-2020
 *  Author        : Sunny Yap
 *  Description   : Implement business rules that augment standard Salesforce entitlement
 * Modifications  : 27-APR-2020 SYAP - Initial
 ****************************************************************************************************/
 
public with sharing class GCM_Entitlement_Engine {
/****************************************************************************************************
 Updates User Map (User Id > Business Hours Id) Map
 Based On Business Hours Assigned In User Object (Optional)
 ****************************************************************************************************/
    public static void updateUserEntitlementMap(Map<Id, Id> userMap) {
        // Get User Map
        List<User> users = [
            select
                Id,
                GCM_Business_Hours__c
            from
                User
            where
                Id in :userMap.keySet() and 
                GCM_Business_Hours__c != null
        ];
        if (users.size() == 0) return;
        Map<Id, String> userHourMap = new Map<Id, String>();
        Map<String, Id> hoursMap = new Map<String, Id>();
        for (User thisUser : users) {
            userHourMap.put(thisUser.Id, thisUser.GCM_Business_Hours__c);
            hoursMap.put(thisUser.GCM_Business_Hours__c, null);
        }
        
        // Get Business Hours
		List<BusinessHours> hours = [select Id, Name from BusinessHours where Name in :hoursMap.keySet()];
		if (hours.size() == 0) return;
        for (BusinessHours thisHour : hours) {
        	hoursMap.put(thisHour.Name, thisHour.Id);      
		}
        
        for (Id userId : userMap.keySet()) {
            String hourName = null;
            hourName = userHourMap.containsKey(userId) ? userHourMap.get(userId) : null;
            if (hourName != null) {
                Id hourId = null;
                hourId = hoursMap.containsKey(hourName) ? hoursMap.get(hourName) : null;
                if (hourId != null) {
                    userMap.put(userId, hourId);
                }
            }
        }
    }

/****************************************************************************************************
 Updates Queue Map (Queue Id > Business Hours Id) Map
 Based On Business Hours Mapped To Queue In GCM_Data_Map__mdt (Optional)
 ****************************************************************************************************/
    public static void updateQueueEntitlementMap(Map<Id, Id> userMap) {
        // Get Queue Id > Queue Name Map
        Map<Id, String> queueNameMap = new Map<Id, String>();
        List<Group> queues = [select Id, DeveloperName from Group where Type = 'Queue' and Id in :userMap.keySet()];
        if (queues.size() == 0) return;
        for (Group queue : queues) {
            queueNameMap.put(queue.Id, queue.DeveloperName);
        }
        
        // Get Queue Name > Business Hours Map
        Map<String, String> queueHoursMap = new Map<String, String>();
        List<GCM_Data_Map__mdt> dataMaps = [
            select
                GCM_Source__c,
                GCM_Target_Two__c
            from
                GCM_Data_Map__mdt
            where
                GCM_Source__c in :queueNameMap.values() and
            	GCM_Type__c = 'Queue_Team' and
            	GCM_Active__c = true
        ];
        if (dataMaps.size() == 0) return;
        for (GCM_Data_Map__mdt dataMap : dataMaps) {
            queueHoursMap.put(dataMap.GCM_Source__c, dataMap.GCM_Target_Two__c);
        }

        Map<String, Id> hoursMap = new Map<String, Id>();
		List<BusinessHours> hours = [select Id, Name from BusinessHours where Name in :queueHoursMap.values()];
        if (hours.size() == 0) return;
		for (BusinessHours thisHour : hours) {
			hoursMap.put(thisHour.Name, thisHour.Id);      
		}
        
        for (Id queueId : userMap.keySet()) {
            String queueName = null;
            queueName = queueNameMap.containsKey(queueId) ? queueNameMap.get(queueId) : null;
            if (queueName != null) {
                String hourName = null;
                hourName = queueHoursMap.containsKey(queueName) ? queueHoursMap.get(queueName) : null;
                if (hourName != null) {
                	Id hourId = null;
                	hourId = hoursMap.containsKey(hourName) ? hoursMap.get(hourName) : null;
                	if (hourId != null) {
                    	userMap.put(queueId, hourId);
                	}
                }
            }
        }
    }

/****************************************************************************************************
 Update Entitlement Id > Business Hours Id Mapping
 Mapped In GCM_Data_Map__mdt
 Automates Business Hours Selection Based On Entitlement (Sales Organisation + Business Unit)
 Case Level Business Hours Adopted In Entitlements For Full Flexibility
 ****************************************************************************************************/
    public static void updateEntitlementMap(Map<Id, Id> entitlementMap) {
        // Entitlement Name Map - Entitlement Id > Entitlement Name
        Map<Id, String> entitlementNameMap = new Map<Id, String>();
        
        // Get Entitlement Details
        List<Entitlement> entitlements = [
          select
            Id, 
            SlaProcess.BusinessHoursId,
            SlaProcess.Name
          from
            Entitlement
          where
            Id in :entitlementMap.keySet()
        ];
        if (entitlements.size() == 0) return;
        for (Entitlement thisEntitlement : entitlements) {
            entitlementMap.put(thisEntitlement.Id, thisEntitlement.SlaProcess.BusinessHoursId);
            entitlementNameMap.put(thisEntitlement.Id, thisEntitlement.SlaProcess.Name);
        }

        // Query Entitlement Name > Business Hours Name Mapping
        List<GCM_Data_Map__mdt> dataMaps = [
            select
                GCM_Source__c,
                GCM_Target__c
            from
                GCM_Data_Map__mdt
            where
                GCM_Type__c = 'Entitlement' and 
                GCM_Active__c = true and 
                GCM_Source__c in :entitlementNameMap.values()
        ];
        if (dataMaps.size() == 0) return;
        Map<String, String> entitlementHoursMap = new Map<String, String>();
        for (GCM_Data_Map__mdt dataMap : dataMaps) {
            entitlementHoursMap.put(dataMap.GCM_Source__c, dataMap.GCM_Target__c);
        }
        
        // Query Business Hours
        Map<String, Id> hoursMap = new Map<String, Id>();
        if (entitlementHoursMap.size() > 0) {
            List<BusinessHours> hours = [select Id, Name from BusinessHours where Name in :entitlementHoursMap.values()];
            for (BusinessHours thisHour : hours) {
                hoursMap.put(thisHour.Name, thisHour.Id);
            }
        }
        if (hoursMap.size() == 0) return;
        
        // Update Entitlement Map
        for (Id entitlementId : entitlementMap.keySet()) {
            String entitlementName = null;
            entitlementName = entitlementNameMap.containsKey(entitlementId) ? entitlementNameMap.get(entitlementId) : null;
            if (entitlementName != null) {
                String businessHoursName = null;
                businessHoursName = entitlementHoursMap.containsKey(entitlementName) ? entitlementHoursMap.get(entitlementName) : null;
                if (businessHoursName != null) {
                    Id businessHoursId = null;
                    businessHoursId = hoursMap.containsKey(businessHoursName) ? hoursMap.get(businessHoursName) : null;
                    if (businessHoursId != null) {
                        entitlementMap.put(entitlementId, businessHoursId);
                    }
                }
            }            
        }        
    }
}