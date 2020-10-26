/* @author            Karishma Gurjar
*  @date              23rd Nov, 2019
*  @description       Handles trigger events on AccountTeamMember object 
*  @ -----------------------------------
*  @ ------------ Changed by ---
*  @author            
*  @date               
*  @description        
*/

@isTest(SeeAllData=False)
public without sharing class ICRM_AccountTeamMemberTriggerHandlerTest {
    
    /** @description - test setup method for creating test data */
    
    @testSetup 
    static void testdataSetup(){
        //test setup method for creating test data
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspect Account Test';
        insert acc;
        
        Profile PfId = [SELECT Id FROM Profile WHERE Name = 'ICRM Base' LIMIT 1]; 
        
        user auser = new user(); 
        auser.lastname = 'test1'; 
        auser.Username = 'test123@xyz.com'+ System.currentTimeMillis(); 
        auser.Email = 'test@xyz.com';
        auser.Alias = 't123';
        auser.EmailEncodingKey='UTF-8'; 
        auser.LanguageLocaleKey='en_US'; 
        auser.LocaleSidKey='en_US'; 
        auser.TimeZoneSidKey='America/Chicago'; 
        auser.ProfileId = PfId.id;
        auser.IsActive = true;  
        insert auser; 
        
        user buser = new user(); 
        buser.lastname = 'test2'; 
        buser.Username = 'test234@xyz.com'+ System.currentTimeMillis(); 
        buser.Email = 'test234@xyz.com';
        buser.Alias = 't234';
        buser.EmailEncodingKey='UTF-8'; 
        buser.LanguageLocaleKey='en_US'; 
        buser.LocaleSidKey='en_US'; 
        buser.TimeZoneSidKey='America/Chicago'; 
        buser.ProfileId = PfId.id;
        buser.IsActive = true;  
        insert buser; 
        System.debug('User Inserted----'+buser);
        
    }
    @istest
    public static void testTriggerUpdate(){
         /** @description - test method to trigger Before and After Update Trigger event */
        User u1 = [SELECT Id, Username FROM User WHERE Username like 'test234@xyz.co%' LIMIT 1];
        User u = [SELECT Id, Username FROM User WHERE Username like 'test123@xyz.co%' LIMIT 1];
        Account acc = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        AccountTeamMember atm = new AccountTeamMember(); 
        atm.TeamMemberRole = 'Analyst'; 
        atm.AccountId = acc.Id;
        atm.UserId = u.Id;
        Test.startTest();
        insert atm;    
        atm.TeamMemberRole = 'GSP Account Holder'; 
        Update atm;
        Test.stopTest();
        Account acc1= [SELECT Id,ICRM_GSP_Account_Holder__c FROM Account where Id=:acc.Id];
        System.assertEquals(acc1.ICRM_GSP_Account_Holder__c,atm.UserId,
                            'Only one account team member can be a GSP Account Holder');
    }
    
    @istest
    public static void testTrigger(){
        /** @description - test method to trigger Before and After Insert Trigger event */
        User u = [SELECT Id, Username FROM User WHERE Username like 'test123@xyz.co%' LIMIT 1];
        Account acc = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        AccountTeamMember atm = new AccountTeamMember(); 
        atm.TeamMemberRole = 'GSP Account Holder'; 
        atm.AccountId = acc.Id;
        atm.UserId = u.Id;
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        Test.startTest();
        insert atm; 
        Test.stopTest();
        Account acc1= [SELECT Id,ICRM_GSP_Account_Holder__c FROM Account where Id=:acc.Id];
        
        System.assertEquals(acc1.ICRM_GSP_Account_Holder__c,atm.UserId,
                            'The account GSP Account holder must be populated with team member having GSP Account Holder role.');
    }
    
    @istest
    public static void testTrigger1(){
        /** @description - test method to trigger  After Delete Trigger event */
        User u = [SELECT Id, Username FROM User WHERE Username like 'test123@xyz.co%' LIMIT 1];
        
        Account acc = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        
        AccountTeamMember atm = new AccountTeamMember(); 
        atm.TeamMemberRole = 'GSP Account Holder'; 
        atm.AccountId = acc.Id;
        atm.UserId = u.Id;
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        insert atm; 
        Test.startTest();    
        delete atm;  
        Test.stopTest();   
        Account acc1= [SELECT Id,ICRM_GSP_Account_Holder__c FROM Account where Id=:acc.Id];
        System.assertEquals(null,acc1.ICRM_GSP_Account_Holder__c,
                            'The account GSP Account holder must be cleared out when team member with GSP Account Holder role is deleted.');
        
    }
    
}