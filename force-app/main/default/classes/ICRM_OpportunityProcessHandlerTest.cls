/**
* @author     Karishma Gurjar
* @date       27/01/2020
* @description    Test class for Opportunity Process Builder   
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_OpportunityProcessHandlerTest {
    @testSetup 
    static void testdataSetup(){
    //Create Test Data for Test Methods
        Profile p = [SELECT Id FROM Profile WHERE Name='ICRM Base']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', FirstName='Test',LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,ICRM_RBU__c='EG&P', ICRM_Team__c='Downstream',ICRM_Office__c='London',
                           TimeZoneSidKey='America/Los_Angeles', UserName='OppNewUser@test.com');
        User u2 = new User(Alias = 'standr', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', FirstName='Test1',LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, ICRM_RBU__c='SPE', ICRM_Team__c='East Can',ICRM_Office__c='Houston',
                           TimeZoneSidKey='America/Los_Angeles', UserName='OppNewUser@test.com.test');
        Insert u1;
        Insert u2;
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspect Account Test';
        insert acc;
    }
    @isTest
    public static void testProcessRBU(){
    // To cover process builder ICRM Update Owner's BU Office Team on Oppty
       Test.startTest();
        User u1 = [SELECT Id, ICRM_RBU__c,ICRM_Team__c,ICRM_Office__c FROM User WHERE Username like 'OppNewUser@test.com%' LIMIT 1];
        User u2 = [SELECT Id, ICRM_RBU__c,ICRM_Team__c,ICRM_Office__c FROM User WHERE Username like 'OppNewUser@test.com.test%' LIMIT 1];
        Account acc = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        string recTypeid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = recTypeid;
        opp1.OwnerId=u1.id;
        opp1.CloseDate=system.today();
        opp1.StageName='Active Discussions';
        opp1.AccountId = acc.Id;
        opp1.ICRM_Assigned_Owner__c=null;
        opp1.Name = 'Test Opportunity';
        opp1.ICRM_RBU__c='SPEH';
        Insert opp1;
        Opportunity opp1New = [Select id,ICRM_RBU__c,ICRM_Team__c,ICRM_Office__c,ownerid from Opportunity where Id = :opp1.Id];        
        System.assertEquals(opp1New.ownerid, u1.id);
        System.assertEquals(opp1New.ICRM_RBU__c, 'SPEH', 'BU Field is updated through Opportunity owner BU field');
        System.assertEquals(opp1New.ICRM_Team__c, u1.ICRM_Team__c, 'Team Field is updated through Opportunity owner BU field');
        System.assertEquals(opp1New.ICRM_Office__c,u1.ICRM_Office__c, 'Office Field is updated through Opportunity owner BU field'); 
        Opportunity opp3 = new Opportunity();
        opp3.RecordTypeId = recTypeid;
        opp3.CloseDate=system.today();
        opp3.StageName='Active Discussions';
        opp3.AccountId = acc.Id;
        opp3.Name = 'Test Opportunity';
        opp3.ICRM_Assigned_Owner__c=u2.id;
        opp3.ICRM_RBU__c='Default';
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        Insert opp3;
        Opportunity opp3New = [Select id,ICRM_RBU__c,ICRM_Team__c,ICRM_Office__c,ownerid from Opportunity where Id = :opp3.Id];        
        System.assertEquals(opp3New.ownerid, u2.id, 'Assigned Owner is updated as Opportunity Owner');
        System.assertEquals(opp3New.ICRM_Team__c, u2.ICRM_Team__c, 'Team Field is updated through Assigned owner BU field');
        System.assertEquals(opp3New.ICRM_Office__c, u2.ICRM_Office__c, 'Office Field is updated through Assigned owner BU field');
        System.assertEquals(opp3New.ICRM_RBU__c, u2.ICRM_RBU__c, 'RBU Field is updated through Assigned owner BU field');
        Test.stopTest();
    }
    @isTest
    public static void updateTender(){
      // To cover process builder ICRM Update Tender Details on Update  
      Test.startTest();
        Account acc = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        string recTypeid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = recTypeid;
        opp1.CloseDate=system.today();
        opp1.StageName='Active Discussions';
        opp1.AccountId = acc.Id;
        opp1.ICRM_Tender__c=True;
        opp1.Name = 'Test Opportunity1';
        Insert opp1;
        opp1.ICRM_Volume_Quantity_Won__c=10;
        opp1.ICRM_Volume_Quantity_Lost__c=10;
        opp1.ICRM_Volume_Quantity__c=100;
        Update opp1;
        Opportunity opp1New = [Select id,ICRM_Volume_Quantity_Remaining__c from Opportunity where Id = :opp1.Id];        
        System.assertEquals(opp1New.ICRM_Volume_Quantity_Remaining__c, 80);
       Test.stopTest(); 
    }
    
}