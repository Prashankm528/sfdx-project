/**
* @author     Karishma Gurjar
* @date       27/01/2020
* @description    Test class for ICRM_ProjectTeamTriggerHandler
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_ProjectTeamTriggerHandlerTest {
    /** @description - test setup method for creating test data */
    @testSetup 
    static void testdataSetup(){
        //Create Test Data for Test Methods
        Profile p = [SELECT Id FROM Profile WHERE Name='ICRM Base']; 
        String sTime= String.valueOf(System.currentTimeMillis());
        String [] uSname = new String[]{'ICRM_ProjectTeamTriggerHandlerabc@test.com.customer.','ICRM_ProjectTeamTriggerHandlerdef@test.com.customer.','ICRM_ProjectTeamTriggerHandlerghi@test.com.customer.'};
            List<User> userList= new List<User>();
        for(integer i=0; i<=2; i++){
            User auser = new User();
            auser.lastname = 'Testing'+i;
            auser.Email = 'standarduser'+i+'@testorg.com'; 
            auser.Alias = 'standt'+i;
            auser.EmailEncodingKey='UTF-8'; 
            auser.LanguageLocaleKey='en_US'; 
            auser.LocaleSidKey='en_US'; 
            auser.TimeZoneSidKey='America/Chicago'; 
            auser.IsActive = true;  
            auser.ProfileId=p.id;
            auser.Username = uSname[i]+sTime;   
            userList.add(auser);
        }
        insert userList; 
    }
    /** @description - test method to trigger After Insert Trigger event */   
    @isTest
    public static void testUserCreate(){
        User u1 = [SELECT Id, UserName FROM User WHERE Username like 'ICRM_ProjectTeamTriggerHandlerabc@test%' LIMIT 1];
        User u2 = [SELECT Id, UserName FROM User WHERE Username like 'ICRM_ProjectTeamTriggerHandlerdef@test%' LIMIT 1];
        Test.startTest(); 
        ICRM_Project__c p1 = new ICRM_Project__c(Name='TestProject');
        Insert p1;
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        ICRM_Project_Team__c pt= new ICRM_Project_Team__c(ICRM_User__c=u2.id, ICRM_Project__c=p1.id);
        insert pt;
        Test.stopTest();			
        ICRM_Project_Team__c projectTeam = [Select id,ICRM_User__c from ICRM_Project_Team__c where 	ICRM_Project__c =: p1.id limit 1]; 
        ICRM_Project__c pro = [Select id,ICRM_Team_Member_Ids__c from ICRM_Project__c where 	id =: p1.id limit 1];     
        System.assertEquals(projectTeam.ICRM_User__c,u2.id, 'User has been inserted in project team');		
        System.assertEquals(pro.ICRM_Team_Member_Ids__c,u2.id, 'User has been inserted in project team');		
    }
    /** @description - test method to trigger After update Trigger event */   
    @isTest
    public static void testUserUpdate(){
        User u1 = [SELECT Id, UserName FROM User WHERE Username like 'ICRM_ProjectTeamTriggerHandlerabc@test%' LIMIT 1];
        User u2 = [SELECT Id, UserName FROM User WHERE Username like 'ICRM_ProjectTeamTriggerHandlerdef@test%' LIMIT 1];
        Test.startTest(); 
        ICRM_Project__c p1 = new ICRM_Project__c(Name='TestProject');
        Insert p1;
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        ICRM_Project_Team__c pt= new ICRM_Project_Team__c(ICRM_User__c=u2.id, ICRM_Project__c=p1.id);
        insert pt;
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        pt.ICRM_User__c=u1.id;
        update pt;
        Test.stopTest();			
        ICRM_Project_Team__c projectTeam = [Select id,ICRM_User__c from ICRM_Project_Team__c where 	ICRM_Project__c =: p1.id limit 1]; 
        ICRM_Project__c pro = [Select id,ICRM_Team_Member_Ids__c from ICRM_Project__c where 	id =: p1.id limit 1];     
        System.assertEquals(projectTeam.ICRM_User__c,u1.id, 'User has been updated in project team');		
        System.assertEquals(pro.ICRM_Team_Member_Ids__c,u1.id, 'User has been updated in project team');		
    }
    /** @description - test method to trigger After Delete Trigger event */   
    @isTest
    public static void testUserDelete(){ 
        User u1 = [SELECT Id, UserName FROM User WHERE Username like 'ICRM_ProjectTeamTriggerHandlerabc@test%' LIMIT 1];
        User u2 = [SELECT Id, UserName FROM User WHERE Username like 'ICRM_ProjectTeamTriggerHandlerdef@test%' LIMIT 1];
        Test.startTest(); 
        ICRM_Project__c p1 = new ICRM_Project__c(Name='TestProject');
        Insert p1;
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        ICRM_Project_Team__c pt= new ICRM_Project_Team__c(ICRM_User__c=u2.id, ICRM_Project__c=p1.id);
        insert pt;
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        delete pt;
        Test.stopTest();			
        ICRM_Project__c pro = [Select id,ICRM_Team_Member_Ids__c from ICRM_Project__c where 	id =: p1.id limit 1];     
        System.assertEquals(pro.ICRM_Team_Member_Ids__c,null, 'User has been deleted in project team');		
    }
    
}