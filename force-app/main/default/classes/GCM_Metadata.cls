/****************************************************************************************************
 *  Date          : 8-MAR-2019
 *  Author        : Sunny Yap
 *  Description   : Class that creates metadata in the background.
 *                  Run asynchronously to avoid MIXED-DML-OPERATION error.
 *                  "process" method handles non metadata insert or update DMLs.
 *                  GCM_Metadata_DML class is the asynchronous object that runs metadata DMLs
 * Modifications  : 8-MAR-2019 SYAP - Initial
 *                  12-MAR-2019 SYAP - Added second method to handle Role that is a non-meta
 *                  data to avoid MIXED DML Operation error.
 *                  14-MAR-2019 SYAP - Bulkified SOQL queries.  Added send email capability.
 *                  19-APR-2019 SYAP - Fixed bug in Get Metadata where the report does not work
 *                                     with multiple record selection.  Cleaned up code.
 *                  23-JUL-2019 SYAP - Added comments.
 *                  27-JUL-2019 SYAP - Added exception handling.
 *                  30-JUL-2019 SYAP - Added user call center capability.
 ****************************************************************************************************/
global with sharing class GCM_Metadata {

/****************************************************************************************************
  Process Metadata Change Record
 ****************************************************************************************************/
  public static void process(List<GCM_Metadata_Change__c> changesIn, Map<Id, GCM_Metadata_Change__c> oldMap, Map<Id, GCM_Metadata_Change__c> newMap) {
    try {
      // Process Only Records Where Status Changed + Status = 'Submitted'
      List<Id> changeIds = new List<Id>();
      for (GCM_Metadata_Change__c change : changesIn) {
        if (change.GCM_Status__c == 'Submitted' && oldMap.get(change.Id).get('GCM_Status__c') != 'Submitted') {
          changeIds.add(change.Id);
        }
      }
  
      List<GCM_Metadata_Item__c> items = [
        select 
          Id,
          GCM_Operation__c,
          GCM_Metadata_Type__c,
          GCM_Metadata_Object__r.Name,
          GCM_User__c
        from
          GCM_Metadata_Item__c
        where
          GCM_Metadata_Change__c in :changeIds
      ];

      Map<String, Id> queueMap = new Map<String, Id>();
      Map<Id, Map<String, Id>> queueMemberMap = new Map<Id, Map<String, Id>>();
      Map<String, Id> groupMap = new Map<String, Id>();
      Map<Id, Map<String, Id>> groupMemberMap = new Map<Id, Map<String, Id>>();   
      Map<String, Id> permissionMap = new Map<String, Id>();
      Map<Id, Map<String, Id>> permissionMemberMap = new Map<Id, Map<String, Id>>(); 
      Map<String, Id> roleMap = new Map<String, Id>();
      Map<String, Id> callCenterMap = new Map<String, Id>();
      List<GroupMember> groupMemberInsert = new List<GroupMember>();
      List<GroupMember> groupMemberDelete = new List<GroupMember>();
      List<PermissionSetAssignment> permissionMemberInsert = new List<PermissionSetAssignment>();
      List<PermissionSetAssignment> permissionMemberDelete = new List<PermissionSetAssignment>();
      List<User> userRoleUpdate = new List<User>();
      List<User> userCallCenterUpdate = new List<User>();
    
      // ### STAGE 1: CACHE LINE ITEMS ###
      for (GCM_Metadata_Item__c item : items) {
        if (item.GCM_Metadata_Type__c == 'Public Group') {
          // Initialise Public Group Map
          groupMap.put(item.GCM_Metadata_Object__r.Name, null);
          
          // Initialise Public Group Member Map
          groupMemberMap.put(item.GCM_User__c, new Map<String, Id>());
        }

        if (item.GCM_Metadata_Type__c == 'Queue') {
          // Initialise Queue Map
          queueMap.put(item.GCM_Metadata_Object__r.Name, null);
          
          // Initialise Queue Member Map
          queueMemberMap.put(item.GCM_User__c, new Map<String, Id>());
        }
        
        if (item.GCM_Metadata_Type__c == 'Permission Set') {
          // Initialise Queue Map
          permissionMap.put(item.GCM_Metadata_Object__r.Name, null);
          
          // Initialise Queue Member Map
          permissionMemberMap.put(item.GCM_User__c, new Map<String, Id>());
        }

        if (item.GCM_Metadata_Type__c == 'Role') {
          // Initialise Role Map
          roleMap.put(item.GCM_Metadata_Object__r.Name, null);
        }

        if (item.GCM_Metadata_Type__c == 'Call Center') {
          // Initialise Call Center Map
          callCenterMap.put(item.GCM_Metadata_Object__r.Name, null);
        }

      }
      
      // ### STAGE 2: QUERY AND CACHE EXISTING DATA ###
      // Bulk Query Public Group
      List<Group> publicGroups = [select Id, DeveloperName from Group where DeveloperName in :groupMap.keySet() and Type = 'Regular'];
      for (Group publicGroup : publicGroups) {
        groupMap.put(publicGroup.DeveloperName, publicGroup.Id);
      }
      
      // Bulk Query Public Group Member
      List<GroupMember> groupMembers = [select Id, Group.DeveloperName, UserOrGroupId from GroupMember where UserOrGroupId in :groupMemberMap.keySet() and Group.Type = 'Regular'];
      for (GroupMember groupMember : groupMembers) {
        Map <String, Id> groupMemberItem = groupMemberMap.get(groupMember.UserOrGroupId);
        groupMemberItem.put(groupMember.Group.DeveloperName, groupMember.Id);
        groupMemberMap.put(groupMember.UserOrGroupId, groupMemberItem);
      }
      
      // Bulk Query Queue
      List<Group> queues = [select Id, DeveloperName from Group where DeveloperName in :queueMap.keySet() and Type = 'Queue'];
      for (Group queue : queues) {
        queueMap.put(queue.DeveloperName, queue.Id);
      }
  
      // Bulk Query Queue Member
      List<GroupMember> queueMembers = [select Id, Group.DeveloperName, UserOrGroupId from GroupMember where UserOrGroupId in :queueMemberMap.keySet() and Group.Type = 'Queue'];
      for (GroupMember queueMember: queueMembers) {
        Map <String, Id> queueMemberItem = queueMemberMap.get(queueMember.UserOrGroupId);
        queueMemberItem.put(queueMember.Group.DeveloperName, queueMember.Id);
        queueMemberMap.put(queueMember.UserOrGroupId, queueMemberItem);
      }

      // Bulk Query Permission Set
      List<PermissionSet> permissions = [select Id, Name from PermissionSet where Name in :permissionMap.keySet()];
      for (PermissionSet permission : permissions) {
        permissionMap.put(permission.Name, permission.Id);
      }
      
      // Bulk Query Permission Set Assignment
      List<PermissionSetAssignment> permissionMembers = [select Id, PermissionSet.Name, AssigneeId from PermissionSetAssignment where AssigneeId in :permissionMemberMap.keySet()];
      for (PermissionSetAssignment permissionMember : permissionMembers) {
        Map <String, Id> permissionMemberItem = permissionMemberMap.get(permissionMember.AssigneeId);
        permissionMemberItem.put(permissionMember.PermissionSet.Name, permissionMember.Id);
        permissionMemberMap.put(permissionMember.AssigneeId, permissionMemberItem);
      }

      // Bulk Query Role
      List<UserRole> roles = [select Id, DeveloperName from UserRole where DeveloperName in :roleMap.keySet()];
      for (UserRole thisRole : roles) {
        roleMap.put(thisRole.DeveloperName, thisRole.Id);
      }
      
      // Bulk Query Call Center
      List<CallCenter> callCenters = [select Id, Name from CallCenter where Name in :callCenterMap.keySet()];
      for (CallCenter thisCallCenter : callCenters) {
        callCenterMap.put(thisCallCenter.Name, thisCallCenter.Id);
      }      

      // ### STAGE 3: CONSTRUCT BULK ADD OR REMOVE LIST ###
      for (GCM_Metadata_Item__c item : items) {
        if (item.GCM_Metadata_Type__c == 'Public Group') {
          Id groupMemberId = null;
          if (groupMemberMap.containsKey(item.GCM_User__c)) {
            if (groupMemberMap.get(item.GCM_User__c).containsKey(item.GCM_Metadata_Object__r.Name)) {
              groupMemberId = groupMemberMap.get(item.GCM_User__c).get(item.GCM_Metadata_Object__r.Name);
            }
          }
          if (item.GCM_Operation__c == 'Add') {
            if (groupMemberId == null) {
              GroupMember member = new GroupMember();
              member.GroupId = groupMap.get(item.GCM_Metadata_Object__r.Name);
              member.UserOrGroupId = item.GCM_User__c;
              groupMemberInsert.add(member);
            }
          }
          else {
            if (groupMemberId != null) {
              GroupMember member = new GroupMember();
              member.Id = groupMemberMap.get(item.GCM_User__c).get(item.GCM_Metadata_Object__r.Name);
              groupMemberDelete.add(member);
            }
          }
        }
        
        if (item.GCM_Metadata_Type__c == 'Queue') {
          Id queueMemberId = null;
          if (queueMemberMap.containsKey(item.GCM_User__c)) {
            if (queueMemberMap.get(item.GCM_User__c).containsKey(item.GCM_Metadata_Object__r.Name)) {
              queueMemberId = queueMemberMap.get(item.GCM_User__c).get(item.GCM_Metadata_Object__r.Name);
            }
          }
          if (item.GCM_Operation__c == 'Add') {
            if (queueMemberId == null) {
              GroupMember member = new GroupMember();
              member.GroupId = queueMap.get(item.GCM_Metadata_Object__r.Name);
              member.UserOrGroupId = item.GCM_User__c;
              groupMemberInsert.add(member);
            }
          }
          else {
            if (queueMemberId != null) {
              GroupMember member = new GroupMember();
              member.Id = queueMemberMap.get(item.GCM_User__c).get(item.GCM_Metadata_Object__r.Name);
              groupMemberDelete.add(member);
            }
          }
        }
        
        if (item.GCM_Metadata_Type__c == 'Permission Set') {
          Id permissionMemberId = null;
          if (permissionMemberMap.containsKey(item.GCM_User__c)) {
            if (permissionMemberMap.get(item.GCM_User__c).containsKey(item.GCM_Metadata_Object__r.Name)) {
              permissionMemberId = permissionMemberMap.get(item.GCM_User__c).get(item.GCM_Metadata_Object__r.Name);
            }
          }
          if (item.GCM_Operation__c == 'Add') {
            if (permissionMemberId == null) {
              PermissionSetAssignment member = new PermissionSetAssignment();
              member.PermissionSetId = permissionMap.get(item.GCM_Metadata_Object__r.Name);
              member.AssigneeId = item.GCM_User__c;
              permissionMemberInsert.add(member);
            }
          }
          else {
            if (permissionMemberId != null) {
              PermissionSetAssignment member = new PermissionSetAssignment();
              member.Id = permissionMemberMap.get(item.GCM_User__c).get(item.GCM_Metadata_Object__r.Name);
              permissionMemberDelete.add(member);
            }
          }
        }
        
        if (item.GCM_Metadata_Type__c == 'Role') {
          if (item.GCM_Operation__c == 'Add') {
            // Create Group Member
            User member = new User();
            member.Id = item.GCM_User__c;
            member.UserRoleId = roleMap.get(item.GCM_Metadata_Object__r.Name); 
            userRoleUpdate.add(member);
          }
          else {
            // Clear User Role
            User member = new User();
            member.Id = item.GCM_User__c;
            member.UserRoleId = null; 
            userRoleUpdate.add(member);
          }          
        }

        if (item.GCM_Metadata_Type__c == 'Call Center') {
          if (item.GCM_Operation__c == 'Add') {
            // Create Group Member
            User member = new User();
            member.Id = item.GCM_User__c;
            member.CallCenterId = callCenterMap.get(item.GCM_Metadata_Object__r.Name); 
            userCallCenterUpdate.add(member);
          }
          else {
            // Clear User Role
            User member = new User();
            member.Id = item.GCM_User__c;
            member.CallCenterId = null; 
            userCallCenterUpdate.add(member);
          }          
        }
      }

      // ### STAGE 4: BULK INSERT OR DELETE ###
      GCM_Metadata_DML metaDML = new GCM_Metadata_DML(groupMemberInsert, groupMemberDelete, permissionMemberInsert, permissionMemberDelete, userRoleUpdate, userCallCenterUpdate);
      Id jobId = System.enqueueJob(metaDML);
      List<GCM_Metadata_Change__c> changes = [select GCM_Job_Id__c from GCM_Metadata_Change__c where Id in :changeIds];
      for (GCM_Metadata_Change__c thisChange : changes) {
        thisChange.GCM_Job_Id__c = jobId;
      }
      update changes;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Metadata', 'process', newMap.keySet(), 'GCM_Application_Administrator');
    }
  }

/****************************************************************************************************
  Email Metadata To Users
 ****************************************************************************************************/
  public static void getMetadata(List<GCM_Metadata_Object__c> objectsIn, Map<Id, GCM_Metadata_Object__c> oldMap, Map<Id, GCM_Metadata_Object__c> newMap) {
    try {
      // Identify Objects For Report Generation
      List<GCM_Metadata_Object__c> metaObjects = new List<GCM_Metadata_Object__c>();
      for (GCM_Metadata_Object__c metaObject : objectsIn) {
        if (metaObject.GCM_Report_Date__c != oldMap.get(metaObject.Id).get('GCM_Report_Date__c')) {
          metaObjects.add(metaObject);
        }
      }
  
      List<String> groupNames = new List<String>();
      List<String> permissionNames = new List<String>();
      List<String> roleNames = new List<String>();
      List<String> callCenterNames = new List<String>();
      for (GCM_Metadata_Object__c metaObject : metaObjects) {
        if (metaObject.GCM_Metadata_Type__c == 'Public Group' || metaObject.GCM_Metadata_Type__c == 'Queue') {
          groupNames.add(metaObject.Name);
        }
        if (metaObject.GCM_Metadata_Type__c == 'Permission Set') {
          permissionNames.add(metaObject.Name);
        }
        if (metaObject.GCM_Metadata_Type__c == 'Role') {
          roleNames.add(metaObject.Name);
        }
        if (metaObject.GCM_Metadata_Type__c == 'Call Center') {
          callCenterNames.add(metaObject.Name);
        }        
      }

      // Bulk Query Call Center
      Map<Id, String> callCenterMap = new Map<Id, String>();
      List<CallCenter> callCenters = [select Id, Name from CallCenter];
      for (CallCenter thisCallCenter : callCenters) {
        callCenterMap.put(thisCallCenter.Id, thisCallCenter.Name);
      }
      
      // Initialise Report    
      String report = 'Type,Name,User,User ID\n';
    
      if (groupNames.size() > 0) {
        Map<Id, User> userMap = new Map<Id, User>([select Id, Email from User where Id in (select UserOrGroupId from GroupMember where Group.DeveloperName in :groupNames)]);
        List<GroupMember> groupMemberList = [select Group.Name, Group.Type, UserOrGroupId from GroupMember where Group.DeveloperName in :groupNames];
        for (GroupMember groupMemberRecord: groupMemberList) {
          if (userMap.containsKey(groupMemberRecord.UserOrGroupId)) {
            report = report + groupMemberRecord.Group.Type + ',' + groupMemberRecord.Group.Name + ',' + userMap.get(groupMemberRecord.UserOrGroupId).Email + ',' + groupMemberRecord.UserOrGroupId + '\n';
          }
        }
      }
      if (permissionNames.size() > 0) {
        List<PermissionSetAssignment> permissionMemberList = [select PermissionSet.Name, Assignee.Email, Assignee.Id from PermissionSetAssignment where PermissionSet.Name in :permissionNames];
        for (PermissionSetAssignment permissionMember: permissionMemberList) {
           report = report + 'Permission Set' + ',' + permissionMember.PermissionSet.Name + ',' + permissionMember.Assignee.Email + ',' + permissionMember.Assignee.Id + '\n';
        }
      }
      if (roleNames.size() > 0) {
        List<User> userList = [select Id, UserRole.DeveloperName, Email from User where UserRole.DeveloperName in :roleNames];
        for (User thisUser: userList) {
           report = report + 'Role' + ',' + thisUser.UserRole.DeveloperName + ',' + thisUser.Email + ',' + thisUser.Id + '\n';
        }
      }
      if (callCenterNames.size() > 0) {
        List<User> userList = [select Id, CallCenterId, Email from User where CallCenterId in :callCenterMap.keySet()];
        for (User thisUser: userList) {
           report = report + 'Call Center' + ',' + callCenterMap.get(thisUser.CallCenterId) + ',' + thisUser.Email + ',' + thisUser.Id + '\n';
        }
      }
            
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
      email.setTargetObjectId(UserInfo.getUserId());
      email.saveAsActivity = false; 
      email.setSubject('Metadata Report');  
      email.setPlainTextBody(report);  
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });      
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Metadata', 'getMetadata', newMap.keySet(), 'GCM_Application_Administrator');
    }
  }

/**************************************************************************************************** 
  Update Asynchronous Job Status
 ****************************************************************************************************/
  public static void updateJobStatus(List<GCM_Metadata_Change__c> changesIn, Map<Id, GCM_Metadata_Change__c> oldMap, Map<Id, GCM_Metadata_Change__c> newMap) {
    try {
      Map<Id, Id>changeIds = new Map<Id, Id>();
      for (GCM_Metadata_Change__c change : changesIn) {       
        if (change.GCM_Job_Refresh_Date__c != oldMap.get(change.Id).get('GCM_Job_Refresh_Date__c')) {
          if (change.GCM_Job_Id__c != null) changeIds.put(change.Id, change.GCM_Job_Id__c);
        }
      }
  
      List<AsyncApexJob> jobs = [select Status, ExtendedStatus from AsyncApexJob where Id in :changeIds.values()];
      Map<Id, String> status = new Map<Id, String>();
      Map<Id, String> extendedStatus = new Map<Id, String>();
    
      for (AsyncApexJob job : jobs) {
        status.put(job.Id, job.Status);
        extendedStatus.put(job.Id, job.ExtendedStatus);
      }
    
      List<GCM_Metadata_Change__c> changes = new List<GCM_Metadata_Change__c>();
      for (Id changeId : changeIds.keySet()) {
        GCM_Metadata_Change__c updatedChange = new GCM_Metadata_Change__c();
        updatedChange.Id = changeId;
        updatedChange.GCM_Job_Status__c = status.get(changeIds.get(changeId));
        updatedChange.GCM_System_Message__c = extendedStatus.get(changeIds.get(changeId));
        changes.add(updatedChange);
      }
      if (changes.size() > 0) update changes;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Metadata', 'updateJobStatus', newMap.keySet(), 'GCM_Application_Administrator');
    }
  }
}