/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * A test class for REIDP_UserServices that adds default Permission Sets to User and Sync Contact
 */
@isTest 
public class REIDP_UserServicesTest {
    
    @isTest
    static void testAssignDefaultPermissionSets() {
        Id uId;
        String profileId = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME].Id;
        System.runAs(createTestUser()) {
            uId = UserInfo.getUserId();
        }

        //Wrapping into try/catch to prevent deployment fails because of row locks
        Boolean lockException = false;
        try {
            Test.startTest();
            update new User (Id = uid,
                            ProfileId = profileId);
            Test.stopTest();
        } catch(Exception ex){
			lockException = true;
        }

        if(!lockException) {
            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :uId];
            System.assert(psa.size() > 1);
        }
    }
    
    @isTest
    static void testSetGeneralIDPProfileForUser() {
        Id uId;
        System.runAs(createTestUser()) {
            uId = UserInfo.getUserId();
        }

        //Wrapping into try/catch to prevent deployment fails because of row locks
        Boolean lockException = false;
        try {
            Test.startTest();    
	        REIDP_UserServices.setGeneralIDPProfileForUser(uid);
            Test.stopTest();            
        } catch(Exception ex){
			lockException = true;
        }

        if(!lockException) {
            User u = [SELECT Id, Profile.Name FROM User WHERE Id = :uid];
            System.assertEquals(REIDP_Constants.GENERAL_IDP_PROFILE_NAME, u.Profile.Name);
        }
    }
    
    @isTest
    static void testSetUserOnContact() {
        Id uId;
        Test.startTest();
        System.runAs(createTestUser()) {
            uId = UserInfo.getUserId();
        }
        Test.stopTest();
        List<Contact> con = [SELECT Id, REIDP_User__c FROM Contact WHERE Id in (SELECT ContactId FROM User WHERE Id = :uId)];
        System.assert(con.size() > 0);
        System.assertEquals(con.get(0).REIDP_User__c, uId);
                
        List<Account> acc = [SELECT Id, Integration_Id__c, REIDP_User__pc FROM Account WHERE Id in (SELECT AccountId FROM Contact WHERE Id =: con.get(0).Id)];
        System.assert(acc.size() > 0);
        System.assertEquals(acc.get(0).Integration_Id__c, uId);
        System.assertEquals(acc.get(0).REIDP_User__pc, uId);
    }
    
    @isTest
    static void testSyncContactRecord() {
        Id uId;
        String newEmail = 'newREIDP_UserServicesTest' + System.now().getTime() +'@test' + UserInfo.getOrganizationId() + '.org';
        Test.startTest();
        System.runAs(createTestUser()) {
            uId = UserInfo.getUserId();
            update new User(Id = uId,
                            LastName = 'newLastName',
                            FirstName = 'newFirstName',
                            Phone = '+12345',
                            Email = newEmail,
                            REIDP_Verified_Email__c = newEmail);
        }
        Test.stopTest();
        Contact con = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id in (SELECT ContactId FROM User WHERE Id = :uId)];
        System.assertEquals('NewLastName', con.LastName);
        System.assertEquals('NewFirstName', con.FirstName);
        System.assertEquals('+12345', con.Phone);
        System.assertEquals(newEmail.toLowerCase(), con.Email);
    }
    
    @isTest
    static void testEmailChange() {
        Id uId;
        String newEmail = 'newREIDP_UserServicesTest' + System.now().getTime() +'@test' + UserInfo.getOrganizationId() + '.org';
        Test.startTest();
        System.runAs(createTestUser()) {
            uId = UserInfo.getUserId();
            update new User(Id = uId,
                            Email = newEmail);
        }
        Test.stopTest();
        User u = [SELECT Id, Email, REIDP_New_Email__c FROM User WHERE Id = :uId];
        System.assertEquals(u.Email, ('UserPermissionSetTest@email' + UserInfo.getOrganizationId() + '.com').toLowerCase());
        System.assertEquals(u.REIDP_New_Email__c, newEmail.toLowerCase());
    }
    
    @isTest
    static void testGenerateCommunityNickName() {
        String nickname = REIDP_UserServices.generateCommunityNickName('Test', 'Test');
        System.assert(nickname.startsWith('Test.Test'));
        System.assertEquals(nickname.length(), 'Test.Test'.length() + 13);
    }
    
    @isTest
    static void testFormatMobileUsernameNull() {
        Test.startTest();
        String resultNull = REIDP_UserServices.formatMobileUsername(null, null);
        Test.stopTest();
        
        System.assertEquals(null, resultNull);
    }
    
    @isTest
    static void testFormatMobileUsernameSuccess() {
        Test.startTest();
        String resultSuccess = REIDP_UserServices.formatMobileUsername('000', '000 000 00 00');
        Test.stopTest();
        
        System.assertEquals('000.0000000000@idp.bp.com', resultSuccess);
    }
    
    @isTest
    static void testFormatMobileUsernameIncorrect() {
        Test.startTest();
        String resultIncorrect = REIDP_UserServices.formatMobileUsername('abc', 'incorrect');
        Test.stopTest();
        
        System.assertEquals(null, resultIncorrect);
    }
        
    /**
     * Tests and validates Platform Events being created on User object change
     */
    @isTest
    static void testPlatformEventsOnUserChange() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User testUser;
        REIDP_Application__c app;
        System.runAs (thisUser) {
        app = new REIDP_Application__c(Name = 'bp me uk',
                                              Permission_Set__c = 'test',
                                              Short_Name__c = 'bpmeuk',
                                              Connected_App__c = 'testApp',
                                      		  Generate_Platform_Events__c = True);
         System.runAs(REIDP_TestFactory.createUserWithRole()) {
            insert app;
        }
        Id profileId = [SELECT Id FROM Profile WHERE Profile.Name=:REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id;
        testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserServicesTest.class, 
                                                              new Map<String, Object>{'REIDP_Country_of_App__c' => 'UK',
                                                                  'REIDP_Privacy_Accepted__c' => System.now(),
                                                                  'REIDP_T_C_Accepted__c' => System.now(),
                                                                  'ProfileId' => profileId});
        
        
        
        }
        
        Test.startTest();
        testUser.FirstName = 'Changed';
        update testUser;
        Test.stopTest();
        List<REIDP_Platform_Event__e> userEvents = new List<REIDP_Platform_Event__e>();
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            if(e.Event_Type__c == 'User')
                userEvents.add(e);
        }
        System.assertEquals(1, userEvents.size());
        System.assertEquals(testUser.Id, userEvents[0].User__c);
        System.assertEquals('User', userEvents[0].Event_Type__c);
        System.assertEquals(app.Short_Name__c, userEvents[0].Audience__c);
        
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(userEvents[0].JSON__c);
        System.assertEquals(testUser.FirstName, m.get('FirstName'));
        System.assertEquals(testUser.Id, m.get('Id'));
    }
    
    /**
     * Tests and validates Platform Events when app doesn't have 'Generate Platform Events' checkbox enabled
     */
    @isTest
    static void testPlatformEventsOnUserChangeDisabled() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User testUser;
        REIDP_Application__c app;
        System.runAs (thisUser) {
        app = new REIDP_Application__c(Name = 'bp me uk',
                                              Permission_Set__c = 'test',
                                              Short_Name__c = 'bpmeuk',
                                              Connected_App__c = 'testApp',
                                      		  Generate_Platform_Events__c = False);
         System.runAs(REIDP_TestFactory.createUserWithRole()) {
            insert app;
        }
        Id profileId = [SELECT Id FROM Profile WHERE Profile.Name=:REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id;
        testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserServicesTest.class, 
                                                              new Map<String, Object>{'REIDP_Country_of_App__c' => 'UK',
                                                                  'REIDP_Privacy_Accepted__c' => System.now(),
                                                                  'REIDP_T_C_Accepted__c' => System.now(),
                                                                  'ProfileId' => profileId});
        
        
        
        }
        
        Test.startTest();
        testUser.FirstName = 'Changed';
        update testUser;
        Test.stopTest();
        List<REIDP_Platform_Event__e> userEvents = new List<REIDP_Platform_Event__e>();
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            if(e.Event_Type__c == 'User')
                userEvents.add(e);
        }
        System.assertEquals(0, userEvents.size());
    }
    
    private static User createTestUser()
    {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String email = 'UserPermissionSetTest@email' + UserInfo.getOrganizationId() + '.com';
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole@testclass_bp'+System.currentTimeMillis()+'.com');
        Account a;
        System.runAs(userWithRole){
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