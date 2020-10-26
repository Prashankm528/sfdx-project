@isTest
private class CAIDP_ManagePermissionSetsControllerTest {
    
    private static String DEFAULT_COMMUNITY = 'Castrol';
    
    @testSetup
    static void setup() {
        
        insertEmailTemplates();
        
        REIDP_TestFactory.DEFAULT_COMMUNITY = DEFAULT_COMMUNITY;
        User u = REIDP_TestFactory.createCommunityUser(CAIDP_ManagePermissionSetsControllerTest.class);
    }
    
    @future
    static void insertEmailTemplates() {
        
        EmailTemplate testEmailTemplate1 = new EmailTemplate(
            IsActive = true,
            Name = 'Test Email Template',
            DeveloperName = 'CAIDP_Removed_WebServices_Email',
            TemplateType = 'visualforce',
            Markup = '<messaging:emailTemplate subject="Test"><messaging:plainTextEmailBody >{webServices}</messaging:plainTextEmailBody></messaging:emailTemplate>',
            ApiVersion = 40.0,
            FolderId = UserInfo.getUserId()
        );
        insert testEmailTemplate1;
        
        EmailTemplate testEmailTemplate2 = new EmailTemplate(
            IsActive = true,
            Name = 'Test Email Template',
            DeveloperName = 'CAIDP_New_WebServices_Email',
            TemplateType = 'visualforce',
            Markup = '<messaging:emailTemplate subject="Test"><messaging:plainTextEmailBody >{webServices}</messaging:plainTextEmailBody></messaging:emailTemplate>',
            ApiVersion = 40.0,
            FolderId = UserInfo.getUserId()
        );
        insert testEmailTemplate2;
    }
    
    
    @isTest 
    static void testGetOrgUrl() {
        Test.startTest();
        String testUrl = CAIDP_ManagePermissionSetsController.getOrgUrl();
        Test.stopTest();
        
        System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm(), testUrl);
    }
    
    @isTest 
    static void testGetAppPermissions() {
        Account acc = [
            SELECT Id
            FROM Account
            WHERE REIDP_User__pc != null 
            AND REIDP_User__pr.REIDP_Default_Community__c = :DEFAULT_COMMUNITY
            LIMIT 1
        ];
        
        Integer permissionCount = [
            SELECT COUNT()
            FROM REIDP_Connected_App__mdt
            WHERE Community_Name__c = :DEFAULT_COMMUNITY
        ];
        
        Test.startTest();
        List<CAIDP_ManagePermissionSetsController.SelectOption> options = CAIDP_ManagePermissionSetsController.getAppPermissions(acc.Id);
        Test.stopTest();
        
        System.assertEquals(permissionCount, options.size());
    }
    
    @isTest 
    static void testGetAssignedPermissionIds() {
        
        Account acc = [
            SELECT REIDP_User__pc
            FROM Account
            WHERE REIDP_User__pc != null
            AND REIDP_User__pr.REIDP_Default_Community__c = :DEFAULT_COMMUNITY
            LIMIT 1
        ];
        
        Set<Id> permissionSet = new Set<Id>();
        for (REIDP_Connected_App__mdt app : [
            SELECT Permission_Set_Id__c
            FROM REIDP_Connected_App__mdt
            WHERE Community_Name__c = :DEFAULT_COMMUNITY
        ]) {
            permissionSet.add(app.Permission_Set_Id__c);
        }
        
        Integer assignedCount = [
            SELECT COUNT()
            FROM PermissionSet
            WHERE Id IN :permissionSet
            AND Id IN (
                SELECT PermissionSetId 
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :acc.REIDP_User__pc 
            )
        ];
        
        Test.startTest();
        List<String> options = CAIDP_ManagePermissionSetsController.getAssignedPermissionIds(acc.Id);
        Test.stopTest();
        
        System.assertEquals(assignedCount, options.size());
    }
    
    @isTest 
    static void testGetAssignedPermissions() {
        
        Account acc = [
            SELECT REIDP_User__pc
            FROM Account
            WHERE REIDP_User__pc != null
            AND REIDP_User__pr.REIDP_Default_Community__c = :DEFAULT_COMMUNITY
            LIMIT 1
        ];
        
        Set<Id> permissionSet = new Set<Id>();
        for (REIDP_Connected_App__mdt app : [
            SELECT Permission_Set_Id__c
            FROM REIDP_Connected_App__mdt
            WHERE Community_Name__c = :DEFAULT_COMMUNITY
        ]) {
            permissionSet.add(app.Permission_Set_Id__c);
        }
        
        Integer assignedCount = [
            SELECT COUNT()
            FROM PermissionSet
            WHERE Id IN :permissionSet
            AND Id IN (
                SELECT PermissionSetId 
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :acc.REIDP_User__pc 
            )
        ];
        Test.startTest();
        List<PermissionSet> options = CAIDP_ManagePermissionSetsController.getAssignedPermissions(acc.Id);
        Test.stopTest();
        
        System.assertEquals(assignedCount, options.size());
    }
    
    @isTest 
    static void testManagePermissionsEmail() {
        
        Account acc = [
            SELECT Id
            FROM Account
            WHERE REIDP_User__pc != null
            AND REIDP_User__pr.REIDP_Default_Community__c = :DEFAULT_COMMUNITY
            LIMIT 1
        ];
        
        Set<String> permissionSet = new Set<String>();
        for (REIDP_Connected_App__mdt app : [
            SELECT Id, Label, Permission_Set_Id__c
            FROM REIDP_Connected_App__mdt
            WHERE Community_Name__c = :DEFAULT_COMMUNITY
        ]) {
            permissionSet.add(app.Permission_Set_Id__c);
        }
        
        Test.startTest();
        List<PermissionSet> prevPerms = CAIDP_ManagePermissionSetsController.getAssignedPermissions(acc.Id);
        List<String> currPerms = new List<String>(permissionSet);
        CAIDP_ManagePermissionSetsController.managePermissions(acc.Id, currPerms, prevPerms);
        List<String> options = CAIDP_ManagePermissionSetsController.getAssignedPermissionIds(acc.Id);
        Test.stopTest();
        
        System.assertEquals(permissionSet.size(), options.size());
    }
    
    @isTest 
    static void testCheckUsernameSuccess() {
        User phoneUser = REIDP_TestFactory.createCommunityPhoneNumberUser();
        String id = phoneUser.Id;
        Test.startTest();
        Boolean result = CAIDP_ManagePermissionSetsController.isPhoneNumberUser(id);
        Test.stopTest();
        
        System.assertEquals(true, result);
    }
    
    @isTest 
    static void testCheckUsernameFail() {
        User u = REIDP_TestFactory.createCommunityUser(CAIDP_ManagePermissionSetsControllerTest.class);
        String id = u.Id;
        Test.startTest();
        Boolean result = CAIDP_ManagePermissionSetsController.isPhoneNumberUser(id);
        Test.stopTest();
        
        System.assertEquals(false, result);
    }
}