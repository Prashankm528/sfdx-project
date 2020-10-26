/**
* @author     Karishma Gurjar
* @date       23/03/2020
* @description    Test class for Case Process Builder   
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_CaseProcessHandlerTest {
    //Create Test Data for Test Methods
    @testSetup 
    static void testdataSetup(){
        
        Map<String,Id > profileMap = new Map<String, Id>();
        for(Profile p1: [SELECT Id,name FROM Profile WHERE Name in ('ICRM Base','System Administrator')]){
            profileMap.put(p1.name,p1.id);
        }
        String sTime= String.valueOf(System.currentTimeMillis());
        String [] uSname = new String[]{'ICRMTestUserabc@test.com.customer.','ICRMTestUserdef@test.com.customer.','ICRMTestUserghi@test.com.customer.'};
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
            if(i < 2){
                auser.Username = uSname[i]+sTime; 
                auser.ProfileId = profileMap.get('ICRM Base');  
            }
            if(i == 2){
                auser.Username = uSname[i]+sTime;
                auser.ProfileId = profileMap.get('System Administrator');    
            }
            userList.add(auser);
        }
        system.debug('userList value---'+userList);
        insert userList; 
        Account acc = new Account();
        string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = recTypeid;
        acc.Name = 'Test Account for Contact';
        Insert acc;
        string recId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        Contact con = new Contact(LastName = 'Sreelatha', FirstName = 'SK', Email = 'sreelatha.sk@bp.com', RecordTypeId = recId, AccountId = acc.Id);
        insert con; 
    }
    /** Test Method to cover process TKT New Case Assigned**/
    @isTest
    public static void NewCaseAssigned(){
        Contact c1 = [SELECT Id, FirstName,LastName from Contact where LastName = 'Sreelatha'];
        User user1 = [SELECT Id  FROM User WHERE Username like 'ICRMTestUserabc%' LIMIT 1];
        User user2 = [SELECT Id, ICRM_RBU__c,ICRM_Team__c,ICRM_Office__c FROM User WHERE Username like 'ICRMTestUserdef%' LIMIT 1];
        Case cc =new Case();string recTypeCaseid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        cc.ContactId = c1.Id;
        cc.RecordTypeId = recTypeCaseid;
        cc.ownerid=user1.id;
        cc.SuppliedEmail = 'test@testcase.com';
        cc.Origin = 'Internal Form';
        cc.TKT_How_can_we_help_you__c= 'New User Access';
        cc.Status='New'; 
        Test.startTest();
        Insert cc; 
        cc.ownerid=user2.id;
        update cc;
        List<FlowInterview> flowInterviews = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews.size());
        Test.stopTest();   
    }
    /** Test Method to cover process TKT Case Closed**/
    @isTest
    public static void CaseClosed(){
        
        Contact con1 = [SELECT Id, FirstName,LastName from Contact where LastName = 'Sreelatha'];
        Case cc1 =new Case();
        string recTypeCaseid1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        cc1.ContactId = con1.Id;
        cc1.RecordTypeId = recTypeCaseid1;
        cc1.Origin = 'CRM';
        cc1.TKT_How_can_we_help_you__c= 'New User Access';
        cc1.Status='New'; 
        cc1.SuppliedEmail = 'test@testcase.com';
        cc1.TKT_Request_Channel__c = 'Email';
        Test.startTest();
        Insert cc1;  
        cc1.TKT_Send_Closed_Case_Email_New__c = 'Yes';
        cc1.Status='Closed';
        cc1.TKT_Sub_Status__c='Request completed';
        cc1.TKT_Request_Type__c='Commercial';
        cc1.TKT_Root_Cause__c='Customer awareness';
        update cc1;
        List<FlowInterview> flowInterviews1 = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews1.size());
        Test.stopTest();
    }
    /** Test Method to cover process TKT Case Update and Attention**/
    @isTest
    public static void CaseUpdateAttention(){
        Test.startTest();
        User useri1= [SELECT Id  FROM User WHERE Username like 'ICRMTestUserabc%' LIMIT 1];
       	Account ac1 = [SELECT ID FROM Account WHERE Name = 'Test Account for Contact'];
		Contact cn1 = [SELECT ID FROM Contact WHERE Email = 'sreelatha.sk@bp.com'];
        
        Case cc2 =new Case();
        string recTypeCaseid2 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        cc2.RecordTypeId = recTypeCaseid2;
        cc2.Origin = 'New Customer Form';
        cc2.ownerid=useri1.id;
        cc2.TKT_How_can_we_help_you__c= 'Changes to a Portal User Account';
        cc2.Status='New'; 
        cc2.Createddate=system.now().addHours(-30);
        cc2.SuppliedEmail = 'test@testcase.com';
        
        Insert cc2; 
        List<FlowInterview> flowInterviews2 = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews2.size());
        Test.stopTest();
    }
    /** Test Method to cover process TKT Notify Owner When a Case is Reopened**/ 
    @isTest
    public static void CaseReopened(){
        Test.startTest();
        User useri2 = [SELECT Id  FROM User WHERE Username like 'ICRMTestUserabc%' LIMIT 1];
        Account ac1 = [SELECT ID FROM Account WHERE Name = 'Test Account for Contact'];
		Contact cn1 = [SELECT ID FROM Contact WHERE Email = 'sreelatha.sk@bp.com'];
        
        string recTypeCaseid3 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        Case cc3 =new Case();
        cc3.RecordTypeId = recTypeCaseid3;
        cc3.Origin = 'New Customer Form';
        cc3.TKT_How_can_we_help_you__c= 'Changes to a Portal User Account';
        cc3.ownerid=useri2.id;
        cc3.Status='New'; 
        cc3.SuppliedEmail = 'test@testcase.com';
        Insert cc3;
        cc3.Status='Closed';
        cc3.TKT_Sub_Status__c='Request completed';
        cc3.TKT_Request_Type__c='Commercial';
        cc3.TKT_Root_Cause__c='Customer awareness';
        cc3.TKT_Send_Closed_Case_Email_New__c = 'Yes';

        update cc3;
        
        cc3.Status='New';
        cc3.TKT_Sub_Status__c='';
        cc3.TKT_Send_Closed_Case_Email_New__c = '';
        cc3.TKT_Request_Type__c='';
        cc3.TKT_Root_Cause__c='';
        update cc3;
        List<FlowInterview> flowInterviews3 = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews3.size());
        Test.stopTest(); 
    }
    /** Test Method to cover process TKT Update How Can I Help You**/
    @isTest
    public static void UpdateHowCanWeHelp(){
        
        Contact con2 = [SELECT Id, FirstName,LastName from Contact where LastName = 'Sreelatha'];
        string recTypeCaseid4 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        Case cc4 =new Case();
        cc4.ContactId = con2.Id;
        cc4.RecordTypeId = recTypeCaseid4;
        cc4.Origin = 'External Form';
        cc4.TKT_How_can_we_help_you_EXTERNAL_FORM__c='New User Access';
        cc4.Status='New'; 
        cc4.SuppliedEmail = 'test@testcase.com';
        Test.startTest();
        Insert cc4;
        Case Cs= [SELECT Id,TKT_How_can_we_help_you__c FROM case where Id=:cc4.Id];
        System.assertEquals(Cs.TKT_How_can_we_help_you__c,cc4.TKT_How_can_we_help_you_EXTERNAL_FORM__c,
                            'How can we help you updated on Case');
        Case cc5 =new Case();
        cc5.ContactId = con2.Id;
        cc5.RecordTypeId = recTypeCaseid4;
        cc5.Origin = 'External Form';
        cc5.TKT_How_can_we_help_you_INTERNAL_FORM__c='New User Access';
        cc5.Status='New'; 
        cc5.SuppliedEmail = 'test@testcase.com';
        Insert cc5;
        Case Cs1= [SELECT Id,TKT_How_can_we_help_you__c FROM case where Id=:cc5.Id];
        System.assertEquals(Cs1.TKT_How_can_we_help_you__c,cc5.TKT_How_can_we_help_you_INTERNAL_FORM__c,
                            'How can we help you updated on Case');
        Case cc6 =new Case();
        cc6.ContactId = con2.Id;
        cc6.RecordTypeId = recTypeCaseid4;
        cc6.Origin = 'External Form';
        cc6.TKT_How_can_we_help_you_NEW_FORM__c='New User Access';
        cc6.Status='New'; 
        cc6.SuppliedEmail = 'test@testcase.com';
        Insert cc6;
        Case Cs2= [SELECT Id,TKT_How_can_we_help_you__c FROM case where Id=:cc6.Id];
        System.assertEquals(Cs2.TKT_How_can_we_help_you__c,cc6.TKT_How_can_we_help_you_NEW_FORM__c,
                            'How can we help you updated on Case');
        Test.stopTest();
    }
    /** Test Method to cover process TKT Reopen Closed Case On Email Received**/
    @isTest
    public static void ReopenClosedCase(){
        Contact con3 = [SELECT Id, FirstName,LastName from Contact where LastName = 'Sreelatha'];
        Case cc7 =new Case();
        string recTypeCaseid5 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        cc7.ContactId = con3.Id;
        cc7.RecordTypeId = recTypeCaseid5;
        cc7.Origin = 'CRM';
        cc7.TKT_How_can_we_help_you__c= 'New User Access';
        cc7.Status='Closed';
        cc7.TKT_Sub_Status__c='Request completed';
        cc7.TKT_Request_Type__c='Commercial';
        cc7.TKT_Root_Cause__c='Customer awareness';
        cc7.TKT_Send_Closed_Case_Email_New__c = 'No';
        cc7.Createddate=system.now().addHours(-35);
        cc7.SuppliedEmail = 'test@testcase.com';
        cc7.TKT_Request_Channel__c = 'Email';
        Insert cc7; 
        EmailMessage em=new EmailMessage();
        em.Incoming=True;
        em.ParentId=cc7.id;
        em.ToAddress='bpsupport2@bp.com';
        Test.startTest();
        Insert em;
        Case c1 = [Select id,Status from Case where Id = :cc7.Id];        
        System.assertEquals(c1.Status, 'Response Received');
        Test.stopTest();
    }
    /** Test Method to cover process TKT IT Approval Notification**/
    @isTest
    public static void ITApprovalNotification(){
        Test.startTest();
        User useri1= [SELECT Id  FROM User WHERE Username like 'ICRMTestUserghi%' LIMIT 1];
        User user2 = [SELECT Id FROM User WHERE Username like 'ICRMTestUserdef%' LIMIT 1 ];
        System.runAs (useri1){
            Group g1 = [SELECT Id FROM Group where name='Ticketing IT Team Group'];
            GroupMember grpMem2 = new GroupMember();
            grpMem2.UserOrGroupId = useri1.Id;
            grpMem2.GroupId = g1.Id;
            Insert grpMem2;  
        }
      
        Account ac1 = [SELECT ID FROM Account WHERE Name = 'Test Account for Contact'];
		
		Contact cn1 = [SELECT ID FROM Contact WHERE Email = 'sreelatha.sk@bp.com'];
        
        string recTypeCaseid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        Case c1 =new Case();
        c1.RecordTypeId = recTypeCaseid;
        c1.Origin = 'New Customer Form';
        c1.TKT_How_can_we_help_you__c= 'Changes to a Portal User Account';
        c1.Status='New'; 
        c1.ownerid=user2.id;
        c1.SuppliedEmail = 'test@testcase.com';
        Insert c1;
        c1.TKT_Approved__c=True;
        Update c1;
        List<FlowInterview> flowInterviews = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews.size());
        Test.stopTest();   
    }
    /** Test Method to cover process TKT Open Case**/
    @isTest
    public static void OpenCase(){
        
        Test.startTest();
        User user1 = [SELECT Id  FROM User WHERE Username like 'ICRMTestUserabc%' LIMIT 1];
      	Account ac1 = [SELECT ID FROM Account WHERE Name = 'Test Account for Contact'];
		Contact cn1 = [SELECT ID FROM Contact WHERE Email = 'sreelatha.sk@bp.com'];
        
        Case cc =new Case();
        string recTypeCaseid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        cc.RecordTypeId = recTypeCaseid;
        cc.ownerid=user1.id;
        cc.SuppliedEmail = 'test@testcase.com';
        cc.Origin = 'New Customer Form';
        cc.TKT_How_can_we_help_you__c= 'New User Access';
        cc.Status='New'; 
        Insert cc; 
        List<FlowInterview> flowInterviews = [SELECT Id FROM FlowInterview];
        System.assertEquals(1, flowInterviews.size());
        
        Case cc1 =new Case();
        cc1.RecordTypeId = recTypeCaseid;
        cc1.ownerid=user1.id;
        cc1.SuppliedEmail = 'test@testcase.com';
        cc1.Origin = 'Email';
        cc1.TKT_How_can_we_help_you__c= 'New User Acc1ess';
        cc1.Status='New';
        Insert cc1; 
        List<FlowInterview> flowInterviews1 = [SELECT Id FROM FlowInterview];
        System.assertEquals(2, flowInterviews1.size());
        
             
        Case cc2 =new Case();
        cc2.RecordTypeId = recTypeCaseid;
        cc2.ownerid=user1.id;
        cc2.ContactId = cn1.Id;
        cc2.SuppliedEmail = 'test@testcase.com';
        cc2.Origin = 'CRM';
        cc2.TKT_Send_Create_Case_Email__c = True;
        cc2.TKT_How_can_we_help_you__c= 'New User Acc2ess';
        cc2.Status='New';
        cc2.TKT_Request_Channel__c = 'Email';
        Insert cc2;
        List<FlowInterview> flowInterviews2 = [SELECT Id FROM FlowInterview];
        System.assertEquals(3, flowInterviews2.size());
        
        Test.stopTest();   
    }
}