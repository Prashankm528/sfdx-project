/******************************************************************************************
 *  Date          : 8-MAR-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Metadata
 * Modifications  : 8-MAR-2019 SYAP - Initial
 *                  12-MAR-2019 SYAP - Including testing of add or remove roles.
 *                  14-MAR-2019 SYAP - Added send email capability.
 *                  11-APR-2019 SYAP - Added with sharing clause.
 *                  19-APR-2019 SYAP - Removed SOQL in loop.
 ******************************************************************************************/
@isTest
public with sharing class GCM_Metadata_Test 
{

/******************************************************************************************
  Generate Test Data
 ******************************************************************************************/
  @testSetup
  static void createTestData() {
    List <GCM_Metadata_Object__c> metaObjects = new List<GCM_Metadata_Object__c>();
    List <User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];
    

    if (users.size() > 0) {
      System.runAs (users[0]) {
        // Create Queue
        Group queue = new Group();
        queue.Name = 'Test Queue';
        queue.DeveloperName = 'Test_1_Queue';
        queue.Type = 'Queue';
        insert queue;
        
        // Create Public Group
        Group publicGroup = new Group();
        publicGroup.Name = 'Test 2 Public Group';
        publicGroup.DeveloperName = 'Test_2_Public_Group';
        publicGroup.Type = 'Regular';
        insert publicGroup;
        
        // Create Permission Set
        PermissionSet permission = new PermissionSet();
        permission.Label = 'Test 3 Permission Set';
        permission.Name = 'Test_3_Permission_Set';
        insert permission;
        
        // Create Role
        UserRole testRole = new UserRole();
        testRole.Name= 'Test 4 Role';
        testRole.DeveloperName = 'Test_4_Role';
        insert testRole;
    
        // Create Metadata Object Reference
        GCM_Metadata_Object__c metaObject1 = new GCM_Metadata_Object__c();
        metaObject1.Name = 'Test_1_Queue';
        metaObject1.GCM_Metadata_Type__c = 'Queue';
        metaObjects.add(metaObject1);
        GCM_Metadata_Object__c metaObject2 = new GCM_Metadata_Object__c();
        metaObject2.Name = 'Test_2_Public_Group';
        metaObject2.GCM_Metadata_Type__c = 'Public Group';
        metaObjects.add(metaObject2);
        GCM_Metadata_Object__c metaObject3 = new GCM_Metadata_Object__c();
        metaObject3.Name = 'Test_3_Permission_Set';
        metaObject3.GCM_Metadata_Type__c = 'Permission Set';
        metaObjects.add(metaObject3);
        GCM_Metadata_Object__c metaObject4 = new GCM_Metadata_Object__c();
        metaObject4.Name = 'Test_4_Role';
        metaObject4.GCM_Metadata_Type__c = 'Role';
        metaObjects.add(metaObject4);
        insert metaObjects;
      }
    }
  }

/******************************************************************************************
  Test Add Operation
 ******************************************************************************************/
  @isTest
  static void testAdd() {
    List <User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];
    if (users.size() > 0) {
      System.runAs (users[0]) {
        // Create Add Change
        GCM_Metadata_Change__c changeAdd = new GCM_Metadata_Change__c();
        changeAdd.GCM_Status__c = 'Draft';
        insert changeAdd;
    
        // Create Line Item
        List <GCM_Metadata_Object__c> metaObjects = [select Id, Name, GCM_Metadata_Type__c from GCM_Metadata_Object__c where Name like 'Test%' order by Name];
        System.assert(metaObjects.size() == 4, 'Test Data Creation');
        List <GCM_Metadata_Item__c> itemsAdd = new List<GCM_Metadata_Item__c>();

        for (GCM_Metadata_Object__c metaObject : metaObjects) {
          GCM_Metadata_Item__c item = new GCM_Metadata_Item__c();
          item.GCM_Operation__c = 'Add';
          item.GCM_Metadata_Type__c = metaObject.GCM_Metadata_Type__c;
          item.GCM_Metadata_Object__c = metaObject.Id;
          item.GCM_User__c = UserInfo.getUserId();
          item.GCM_Metadata_Change__c = changeAdd.Id;
          itemsAdd.add(item);
        }
        insert itemsAdd;

        Test.startTest();
        changeAdd.GCM_Status__c = 'Submitted';
        update changeAdd;
        Test.stopTest();
        
        // Update Job Refresh Date
        List<GCM_Metadata_Change__c> changes = [select Id, GCM_Job_Refresh_Date__c from GCM_Metadata_Change__c where Id = :changeAdd.Id limit 1];
        if (changes.size() > 0) {
          GCM_Metadata_Change__c changeUpdate = new GCM_Metadata_Change__c();
          changeUpdate.Id = changes[0].Id;
          changeUpdate.GCM_Job_Refresh_Date__c = Datetime.now() + 1;
          update changeUpdate;
        }

        // Assert Results        
        List <GroupMember> checkGroups = [select Id from GroupMember where Group.DeveloperName in (:metaObjects[0].Name, :metaObjects[1].Name)];
        System.assert(checkGroups.size() == 2, 'Check Queue, Public Group Members');
        List <PermissionSetAssignment> checkPermissions = [select Id from PermissionSetAssignment where PermissionSet.Name = :metaObjects[2].Name];
        System.assert(checkPermissions.size() == 1, 'Check Permission Set Assignment');
        List <UserRole> checkRoles = [select Id from UserRole where DeveloperName = :metaObjects[3].Name];
        System.assert(checkRoles.size() == 1, 'Test Role Created');
        List <User> checkUsers = [select Id from User where UserRoleId = :checkRoles[0].Id];
        System.assert(checkUsers.size() == 1, 'Check User Role Assignment');
      }
    }
  }

/******************************************************************************************
  Test Remove Operation
 ******************************************************************************************/
  @isTest
  public static void testRemove() {
    List <User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];
    if (users.size() > 0) {
      System.runAs (users[0]) {    
        // Create Records For Deletion
        List <GCM_Metadata_Object__c> metaObjects = [select Id, Name, GCM_Metadata_Type__c from GCM_Metadata_Object__c where Name like 'Test%' order by Name];
        System.assert(metaObjects.size() == 4, 'Test Data Creation');
        
        // Store In Memory
        Map<String, GCM_Metadata_Object__c> metaMap = new Map<String, GCM_Metadata_Object__c>();
        for (GCM_Metadata_Object__c metaObject : metaObjects) {
          metaMap.put(metaObject.GCM_Metadata_Type__c, metaObject);
        }
        
        // Queue
        List<Group> queues = [select Id from Group where DeveloperName = :metaMap.get('Queue').Name and Type = 'Queue'];
        if (queues.size() == 1) {
          GroupMember member = new GroupMember();
          member.GroupId = queues[0].Id;
          member.UserOrGroupId = UserInfo.getUserId();
          insert member;
        }

        // Public Group
        List<Group> groups = [select Id from Group where DeveloperName = :metaMap.get('Public Group').Name and Type = 'Regular'];
        if (groups.size() == 1) {
          GroupMember member = new GroupMember();
          member.GroupId = groups[0].Id;
          member.UserOrGroupId = UserInfo.getUserId();
          insert member;
        }

        List<PermissionSet> permissions = [select Id from PermissionSet where Name = :metaMap.get('Permission Set').Name];
        if (permissions.size() == 1) {
          PermissionSetAssignment member = new PermissionSetAssignment();
          member.PermissionSetId = permissions[0].Id;
          member.AssigneeId = UserInfo.getUserId();
          insert member;
        }

        // Create Remove Change
        GCM_Metadata_Change__c changeRemove = new GCM_Metadata_Change__c();
        changeRemove.GCM_Status__c = 'Draft';
        insert changeRemove;

        // Create Line Item
        List <GCM_Metadata_Item__c> itemsRemove = new List<GCM_Metadata_Item__c>();
        for (GCM_Metadata_Object__c metaObject : metaObjects) {
          GCM_Metadata_Item__c item = new GCM_Metadata_Item__c();
          item.GCM_Operation__c = 'Remove';
          item.GCM_Metadata_Type__c = metaObject.GCM_Metadata_Type__c;
          item.GCM_Metadata_Object__c = metaObject.Id;
          item.GCM_User__c = UserInfo.getUserId();
          item.GCM_Metadata_Change__c = changeRemove.Id;
          itemsRemove.add(item);
        }
        insert itemsRemove;

        Test.startTest();
        changeRemove.GCM_Status__c = 'Submitted';
        update changeRemove;
        Test.stopTest();

        List <GroupMember> checkGroups = [select Id from GroupMember where Group.DeveloperName in (:metaObjects[0].Name, :metaObjects[1].Name)];
        System.assert(checkGroups.size() == 0, 'Check Queue, Public Group Members Removal');
        List <PermissionSetAssignment> checkPermissions = [select Id from PermissionSetAssignment where PermissionSetId = :metaObjects[2].Id];
        System.assert(checkPermissions.size() == 0, 'Check Permission Set Assignment Removal');
        List <User> checkUsers = [select UserRoleId from User where Id = :UserInfo.getUserId()];
        System.assert(checkUsers.size() == 1, 'Check User');
        System.assert(checkUsers[0].UserRoleId == null, 'Check User Role');
      }
    }
  }

/******************************************************************************************
  Test Email Metadata
 ******************************************************************************************/ 
  @isTest
  static void testMetadataEmail() {
    List <User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];
    if (users.size() > 0) {
      System.runAs (users[0]) { 
        List <GCM_Metadata_Object__c> metaObjects = [select Id, Name, GCM_Metadata_Type__c, GCM_Report_Date__c from GCM_Metadata_Object__c where Name like 'Test%' order by Name];
        System.assert(metaObjects.size() == 4, 'Test Data Creation');

        // Store In Memory
        Map<String, GCM_Metadata_Object__c> metaMap = new Map<String, GCM_Metadata_Object__c>();
        for (GCM_Metadata_Object__c metaObject : metaObjects) {
          metaMap.put(metaObject.GCM_Metadata_Type__c, metaObject);
        }
        
        // Assign Queue
        List<Group> queues = [select Id from Group where DeveloperName = :metaMap.get('Queue').Name];
        if (queues.size() == 1) {
          GroupMember member = new GroupMember();
          member.GroupId = queues[0].Id;
          member.UserOrGroupId = UserInfo.getUserId();
          insert member;
        }

        // Assign Public Group
        List<Group> groups = [select Id from Group where DeveloperName = :metaMap.get('Public Group').Name];
        if (groups.size() == 1) {
           GroupMember member = new GroupMember();
           member.GroupId = groups[0].Id;
           member.UserOrGroupId = UserInfo.getUserId();
           insert member;
        }

        // Assign Permission Set
        List<PermissionSet> permissions = [select Id from PermissionSet where Name = :metaMap.get('Permission Set').Name];
        if (permissions.size() == 1) {
          PermissionSetAssignment member = new PermissionSetAssignment();
          member.PermissionSetId = permissions[0].Id;
          member.AssigneeId = UserInfo.getUserId();
          insert member;
        }

        // Assign Role
        List<UserRole> roles = [select Id from UserRole where DeveloperName = :metaMap.get('Role').Name];
        if (roles.size() == 1) {
          User member = new User();
          member.Id = UserInfo.getUserId();
          member.UserRoleId = roles[0].Id;
          update member;
        }

        // Bulk Generate Report
        List<GCM_Metadata_Object__c> metaUpdatedObjects = new List<GCM_Metadata_Object__c>();
        for (GCM_Metadata_Object__c metaObject : metaObjects) {
          GCM_Metadata_Object__c metaUpdatedObject = new GCM_Metadata_Object__c();
          metaUpdatedObject.Id = metaObject.Id;
          metaUpdatedObject.GCM_Report_Date__c = Datetime.now() + 1;
          metaUpdatedObjects.add(metaUpdatedObject); 
        }
        if (metaUpdatedObjects.size() > 0) update metaUpdatedObjects;
      }
    }
  }
}