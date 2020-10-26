/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 12/06/2018
*
**/

@isTest
public with sharing class REIDP_AppAccessRequestControllerTest {
    
    @testSetup static void setup() {
        List<REIDP_Application__c> appList = new List<REIDP_Application__c>();
        Integer n = 5;
        System.runAs(createUserWithRole()) {
            while(n > 0) {
                appList.add(new REIDP_Application__c(Name = 'Test App ' + n,  
                                                     Description__c = 'This is a test app ' + n,
                                                     Can_User_Request_Access__c = true,
                                                     Is_Active__c = true,
                                                     Is_Restricted__c = true,
                                                     Community__c = 'Castrol',
                                                     Permission_Set__c = 'DummyId',
                                                     Connected_App__c = 'DummyId',
                                                     Approver__c = UserInfo.getUserId(),
                                                     Short_Name__c = 'Name' + n));
                
                appList.add(new REIDP_Application__c(Name = 'Test App Inactive ' + n,  
                                                     Description__c = 'This is a test app ' + n,
                                                     Can_User_Request_Access__c = true,
                                                     Is_Active__c = false,
                                                     Community__c = 'Castrol',
                                                     Is_Restricted__c = true,
                                                     Permission_Set__c = 'DummyId',
                                                     Connected_App__c = 'DummyId',
                                                     Approver__c = UserInfo.getUserId(),
                                                     Short_Name__c = 'Name Inactive' + n));
                
                appList.add(new REIDP_Application__c(Name = 'Test App Public  ' + n,  
                                                     Description__c = 'This is a test app ' + n,
                                                     Can_User_Request_Access__c = true,
                                                     Is_Active__c = true,
                                                     Community__c = 'Castrol',
                                                     Is_Restricted__c = false,
                                                     Permission_Set__c = 'DummyId',
                                                     Connected_App__c = 'DummyId',
                                                     Approver__c = UserInfo.getUserId(),
                                                     Short_Name__c = 'Name Public' + n));
                
                appList.add(new REIDP_Application__c(Name = 'Test App User cant request access  ' + n,  
                                                     Description__c = 'This is a test app ' + n,
                                                     Can_User_Request_Access__c = false,
                                                     Is_Active__c = true,
                                                     Community__c = 'Castrol',
                                                     Is_Restricted__c = true,
                                                     Permission_Set__c = 'DummyId',
                                                     Connected_App__c = 'DummyId',
                                                     Approver__c = UserInfo.getUserId(),
                                                     Short_Name__c = 'Name No Access' + n));
                n--;
            }
            insert appList;   
        }
    }

    @isTest
    public static void getListOfRestrictedApps_Success() {
        
        Test.startTest();
        List<REIDP_AppAccessRequestController.Application> result = REIDP_AppAccessRequestController.getListOfRestrictedApps();
        Test.stopTest();
        
        System.assertEquals(5, result.size());
        
    }
    
    @isTest
    public static void getListOfRestrictedApps_Success_Pending() {
        List<REIDP_AppAccessRequestController.Application> result = REIDP_AppAccessRequestController.getListOfRestrictedApps();
        REIDP_AppAccessRequestController.Application app = result.get(0);

        System.runAs(createTestUser(createUserWithRole())) {
            
            REIDP_AppAccessRequestController.createNewAccessRequest(app.Id);
            
            Test.startTest();
            result = REIDP_AppAccessRequestController.getListOfRestrictedApps();
            Test.stopTest();
        }
        
        Boolean testPassed = FALSE;
        
        for(REIDP_AppAccessRequestController.Application appl : result) {
            if(appl.actionDisabled = TRUE && appl.actionLabel == 'Approval Pending' && appl.Id == app.Id)
                testPassed = TRUE;
        }
        
        System.assert(testPassed);
        
    }
    
    @isTest
    public static void getListOfRestrictedApps_Success_Blocked() {
        
        List<REIDP_AppAccessRequestController.Application> result = REIDP_AppAccessRequestController.getListOfRestrictedApps();
        String appId = result.get(0).Id;
        REIDP_AppAccessRequestController.createNewAccessRequest(appId);
        
        List<REIDP_Application_Access_Request__c> appRequest = [SELECT Id,
                                                                Application__c, 
                                                                Status__c,
                                                                User__c,
                                                                Contact__c
                                                                FROM REIDP_Application_Access_Request__c LIMIT 50000];
        
		appRequest.get(0).Status__c = 'Rejected';
		appRequest.get(0).Status_Reason__c = 'Blocked';
        update appRequest;            
            
        result = REIDP_AppAccessRequestController.getListOfRestrictedApps();
            
        
        Boolean testPassed = TRUE;
        
        for(REIDP_AppAccessRequestController.Application appl : result) {
            if(appl.Id == appId)
                testPassed = FALSE;
        }
        
        System.assert(testPassed);
    }
    
    @isTest
    public static void createNewAccessRequest_Success() {
        
        REIDP_AppAccessRequestController.Application app = REIDP_AppAccessRequestController.getListOfRestrictedApps().get(0);
        System.assertNotEquals(NULL, app);
        
        String uid;
        
        System.runAs(createTestUser(createUserWithRole())) {

			uid = UserInfo.getUserId();
            
            Test.startTest();
            REIDP_AppAccessRequestController.createNewAccessRequest(app.Id);
            Test.stopTest();
            
        }
        
        List<REIDP_Application_Access_Request__c> appRequest = [SELECT Id,
                                                                Application__c, 
                                                                Status__c,
                                                                User__c,
                                                                Contact__c
                                                                FROM REIDP_Application_Access_Request__c LIMIT 50000];
        
        User u = [SELECT Id, ContactId FROM User WHERE Id = :uid];
        
        System.assertEquals(1, appRequest.size());
        System.assertEquals('New', appRequest.get(0).Status__c);
        System.assertEquals(uid, appRequest.get(0).User__c);
        System.assertEquals(u.ContactId, appRequest.get(0).Contact__c);
    }
    
    private static User createUserWithRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userWithRole = new User(alias = 'hasrole', email='userwithNewrole@roletest1.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username='userwithNewrole@testorg' + System.currentTimeMillis() + '.com');
        return userWithRole;
    }
    
    private static User createTestUser(User userWithRole) {
        
        Account a;
        String email = 'REIDP_AppAccessRequestControllerTest@email' + UserInfo.getOrganizationId() + System.currentTimeMillis() + '.com';
        
        System.runAs(userWithRole) {
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, 
                            FirstName = 'TestPersonAccountFirst', 
                            LastName = 'TestPersonAccount', 
                            PersonEmail = email);
            insert a;
        }
        
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        String profileName = '';
        for(String pName : REIDP_Constants.SET_OF_WELCOME_PROFILE_NAMES) {
            profileName = pName;
            break;
        }
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User(
            FirstName = 'testFirstName',
            LastName = 'testLastName',
            Email = email,
            Username = email,
            Alias = 'TestBP', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId);
        return u;
    }
}