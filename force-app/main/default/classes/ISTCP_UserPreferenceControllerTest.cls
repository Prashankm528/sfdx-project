/**
* @description Test class for ISTCP_UserPreferenceController.
* @author Ravi Potla | 6/20/2020 
**/
@isTest
public with sharing class ISTCP_UserPreferenceControllerTest {

    @testSetup 
    static void testdataSetup(){

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'IST' Limit 1];

        User thisUser = [ select Id, UserRoleId from User where Id = :UserInfo.getUserId() ];
        thisUser.UserRoleId = userrole.Id;
        update thisUser;

        System.runAs ( thisUser ) {
            Account acc = new Account (
            Name = 'newAcc1');  
            insert acc;

            Contact con = new Contact (
            AccountId = acc.id,
            LastName = 'portalTestUser'
            );
            insert con;

            Profile p = [select Id,name from Profile where Name =: 'ISTCP Portal User' limit 1];
            
            User newUser = new User(
            profileId = p.id,
            username = 'newUser@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = con.id
            );
            insert newUser;  
        }

    }

    @isTest
	public static void notificationPreferenceTest(){
        Test.startTest();
        User u = [Select id, ContactId from User where email = 'pb@ff.com'];
        System.runAs ( u ) {
            ISTCP_UserPreferenceController.fetchAccPrefrenceValue();
            ISTCP_UserPreferenceController.saveAccNotificationInfo('Portal only', 'AccNotification');
            ISTCP_UserPreferenceController.saveAccNotificationInfo('Portal only', 'SysNotification');
            ISTCP_UserPreferenceController.saveAccNotificationInfo('Portal only', 'BPNotification');
            Contact con = [Select id, ISTCP_Account_Notification_Preferences__c, ISTCP_System_Notification_Preferences__c, ISTCP_BP_Announcements_Notifications__c from Contact where LastName = 'portalTestUser' limit 1];
            System.assertEquals(con.ISTCP_Account_Notification_Preferences__c, 'Portal only');
            System.assertEquals(con.ISTCP_System_Notification_Preferences__c, 'Portal only');
            System.assertEquals(con.ISTCP_BP_Announcements_Notifications__c, 'Portal only');
        }
        Test.stopTest();
        
    }
}