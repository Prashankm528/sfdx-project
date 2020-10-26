/****************************************************************************************************
 *  Date          : 03-JAN-2020
 *  Author        : Sunny Yap
 *  Description   : Helper class for GCM_Service_Request_Trigger_Handler.
 *  Modifications :
 *  03-JAN-2020   : SYAP - Initial.
 *  24-FEB-2020   : SYAP - Added bulk conversion into Cases capability.
 ****************************************************************************************************/

public with sharing class GCM_Service_Request_Trigger_Helper {

/****************************************************************************************************
  Pre-calculates Case Record Type Id and assign to the right queue.
 ****************************************************************************************************/
  public static void postCreate(List<GCM_Service_Request__c> requests, Map<Id, GCM_Service_Request__c> oldMap, Map<Id, GCM_Service_Request__c> newMap) {
    try {
      // Get Record Type Map
      Map<String, Id> recordTypeMap = new Map<String, Id>();
      List<RecordType> recordTypes = [select Id, DeveloperName from RecordType where SObjectType = 'Case' and DeveloperName like 'GCM%'];
      for (RecordType thisRecordType : recordTypes) {
        recordTypeMap.put(thisRecordType.DeveloperName, thisRecordType.Id);
      }
      
      // Get Queue Map
      Map<String, Id> queueMap = new Map<String, Id>();
      for (GCM_Service_Request__c request : requests) {
        String groupName = '';
        groupName += 'GCM_';
        groupName += request.GCM_Business_Unit__c + '_';
        groupName += request.GCM_Sales_Organization__c;
        queueMap.put(groupName, null);
      }
      List<Group> queues = [select Id, Name from Group where Type = 'Queue' and Name in :queueMap.keySet()];
      for (Group queue : queues) {
        queueMap.put(queue.Name, queue.Id);
      }
      
      // Set Record Type Id + Owner Id
      for (GCM_Service_Request__c request : requests) {
        // Set Record Type Id
        if (recordTypeMap.containsKey(request.GCM_Case_Record_Type__c)) {
          request.GCM_Case_Record_Type_Id__c = recordTypeMap.get(request.GCM_Case_Record_Type__c);
        }
        
        // Set Owner Id
        String groupName = '';
        groupName += 'GCM_';
        groupName += request.GCM_Business_Unit__c + '_';
        groupName += request.GCM_Sales_Organization__c;
        if (queueMap.containsKey(groupName)) {
          request.OwnerId = queueMap.get(groupName);
        }
      }
    } catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Service_Request_Trigger_Helper', 'postCreate', newMap.keySet(), 'GCM_Application_Administrator');
    }
  }
    
/****************************************************************************************************
  Bulk Case Conversion Capability
 ****************************************************************************************************/
	public static void convertIntoCases(List<GCM_Service_Request__c> requests, Map<Id, GCM_Service_Request__c> oldMap, Map<Id, GCM_Service_Request__c> newMap) {
        try {
            // Bulk Create Cases
            List<Case> cases = new List<Case>();
            List<GCM_Service_Request__c> updatedRequests = new List<GCM_Service_Request__c>();
            for (GCM_Service_Request__c request : requests) {
                if (oldMap.get(request.Id).GCM_Trigger_Automation__c != request.GCM_Trigger_Automation__c) {
	                if (request.GCM_Related_Case_Id__c == null) {
    	                Case newCase = new Case();
        	            newCase.RecordTypeId = request.GCM_Case_Record_Type_Id__c;
            	        newCase.Type = request.GCM_Type__c;
	                    newCase.Area__c = request.GCM_Area__c;
    	                newCase.Sub_Area__c = request.GCM_Sub_Area__c;
        	            newCase.Complaint__c = request.GCM_Complaint__c;
	                    newCase.Status = request.GCM_Status__c;
    	                newCase.Sub_Status__c = request.GCM_Sub_Status__c;
	                    newCase.Due__c = request.GCM_Due__c;
                        if (request.GCM_Detailed_Description__c != null) {
                        	if (request.GCM_Detailed_Description__c.length() > 32000) {
	                    		newCase.Description = request.GCM_Detailed_Description__c.substring(0, 32000);
                        	}
                        	else {
                            	newCase.Description = request.GCM_Detailed_Description__c;
                        	}
                        }
    	                newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
						cases.add(newCase);
	                    updatedRequests.add(request);
	                }
                }
            }
			insert cases;
            
            // Update Related Case Id Back Into Service Request
			Integer count = 0;
			for (Case thisCase : cases) {
            	if (updatedRequests.size() > count) {
                	updatedRequests[count].GCM_Related_Case_Id__c = thisCase.Id;
                    updatedRequests[count].GCM_Related_Case_Number__c = thisCase.CaseNumber;
                    count++;
				}
            }
		} catch (Exception exceptionObject) {
			BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Service_Request_Trigger_Helper', 'convertIntoCases', newMap.keySet(), 'GCM_Application_Administrator');
		}
	}
}