@isTest
private class CAIDP_UserTriggerHandlerTest {
    
    @isTest 
    static void handleBeforeInsertTest() {

        String userEmail = REIDP_TestFactory.generateUniqueUserEmail(CAIDP_UserTriggerHandlerTest.class);
        Account a;
        
        System.runAs(REIDP_TestFactory.createUserWithRole()){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccount', PersonEmail = userEmail);
            insert a;
        }
        
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = userEmail,
            Username = userEmail,
            Alias = 'TestCA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id, 
            LanguageLocaleKey = 'de',
            ContactId = acc.PersonContactId
        );
        Test.startTest();
        insert u;
        Test.stopTest();

        
        u = [
            SELECT CAIDP_Language__c
            FROM User
            WHERE Email = :u.Email
            LIMIT 1
        ];
        
        System.assertEquals('de', u.CAIDP_Language__c);
    }

    @isTest 
    static void handleBeforeUpdateTest() {

        User u = REIDP_TestFactory.createCommunityUser(CAIDP_UserTriggerHandlerTest.class);
        
        u.LanguageLocaleKey = 'nl_NL';

        Test.startTest();
        update u;
        Test.stopTest();

        
        u = [
            SELECT CAIDP_Language__c
            FROM User
            WHERE Email = :u.Email
            LIMIT 1
        ];
        
        System.assertEquals('nl_NL', u.CAIDP_Language__c);
    }
    
    @isTest 
    static void handleAfterUpdateTest() {

        User u = REIDP_TestFactory.createCommunityUser(CAIDP_UserTriggerHandlerTest.class);
        
        u.IsActive = false;

        Test.startTest();
        update u;
        Test.stopTest();

        
        u = [
            SELECT IsActive
            FROM User
            WHERE Email = :u.Email
            LIMIT 1
        ];
        
        System.assertEquals(false, u.IsActive);
    }
    
}