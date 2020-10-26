/**
* @author     Karishma Gurjar
* @date       27/01/2020
* @description    Test class for ICRM_Trader_User_Create   
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_Staff_Trigger_Handler_Test {
    @testSetup 
    static void testdataSetup(){
        //Create Test Data for Test Methods
        Profile p1 = [SELECT Id FROM Profile WHERE Name='ICRM Base']; 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Castrol_SalesUser']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', FirstName='Test',LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id,NTID__c='ijk123',
                           TimeZoneSidKey='America/Los_Angeles', UserName='oppnewuser@test.com');
        Insert u1;
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Test User', FirstName='Castrol',LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p2.Id,NTID__c='kk356',
                           TimeZoneSidKey='America/Los_Angeles', UserName='castrolnewuser@test.com');
        Insert u2;
    }
    
    @isTest
    public static void testUserCreate(){
        /* Create user in custom Object ICRM Staff */  
        Set<Id> setOfUsers = new Set<Id>();
        User u1 = [SELECT Id, UserName FROM User WHERE Username like 'oppnewuser@test.com%' LIMIT 1];
        setOfUsers.add(u1.id);
        Test.startTest();
        ICRM_Staff_Trigger_Handler.userCreate(setOfUsers);
        Test.stopTest();		
        ICRM_Staff__c newUser = [Select id,ICRM_Username__c from ICRM_Staff__c where ICRM_Username__c =: u1.UserName limit 1];     
        System.assertEquals(newUser.ICRM_Username__c,u1.UserName, 'User has been inserted in custom Object');		
    }
    @isTest
    public static void testUserUpdate(){
        /* Update user in custom Object ICRM Staff */  
        Set<Id> setOfUsers = new Set<Id>();
        User user1 = [SELECT Id,Department,UserName FROM User WHERE Username like 'oppnewuser@test.com%' LIMIT 1];
        user1.Department='Admin';
        Update user1;
        setOfUsers.add(user1.id);
        Test.startTest();
        ICRM_Staff_Trigger_Handler.userUpdate(setOfUsers);
        Test.stopTest();		
        ICRM_Staff__c updatedUser = [Select id,ICRM_Department__c from ICRM_Staff__c where ICRM_Username__c =: user1.UserName limit 1];     
        System.assertEquals(updatedUser.ICRM_Department__c, user1.Department, 'User has been updated in custom Object');		
    }
    @isTest
    public static void testNonISTUpdate(){	
        /* Update user in custom Object ICRM Staff when other profile user changed to Non ICRM*/  
        Set<Id> setOfUsers = new Set<Id>();
        User u1 = [SELECT Id,Department,UserName,profileid FROM User WHERE Username like 'oppnewuser@test.com%' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Castrol_SalesUser']; 
        u1.profileid=p.id;
        Update u1;
        setOfUsers.add(u1.id);
        Test.startTest();
        ICRM_Staff_Trigger_Handler.NonISTUserUpdate(setOfUsers);
        Test.stopTest();		
        ICRM_Staff__c updatedNonISTUser = [Select id,ICRM_IST_User__c from ICRM_Staff__c where ICRM_Username__c =: u1.UserName limit 1];
        System.assertEquals(updatedNonISTUser.ICRM_IST_User__c, False, 'User has been updated as Non IST');	
    }
    @isTest
    public static void testISTUser(){
        /* Create user in custom Object ICRM Staff when other profile user changed to ICRM*/  
        Set<Id> setOfUsers = new Set<Id>();
        User u1 = [SELECT Id,UserName,profileid FROM User WHERE Username = 'castrolnewuser@test.com' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='ICRM Base']; 
        u1.profileid=p.id;
        Update u1;
        setOfUsers.add(u1.id);
        Test.startTest();
        ICRM_Staff_Trigger_Handler.userCreate(setOfUsers);
        Test.stopTest();	
        List<ICRM_Staff__c> UserList = new List<ICRM_Staff__c>();
        UserList = [Select id from ICRM_Staff__c where ICRM_Username__c =: u1.UserName limit 1];
        System.assertEquals(UserList.size(), 1 ,'IST User is added to the ICRM Staff');	
    }
}