/**
* @author     Utkarsh Gupta
* @date       14/08/2019
* @description    Test class for ICRM_OpportunityTriggerHandler class  
*  @ -----------------------------------
*  @ ------------ Changed by ---
*  @author            Santosh Verma
*  @date              08th Nov, 2019
*  @description       Added User creation and changed Oppty data to incorporate OpptyTeam's code coverage 
*  
@ ------------ Changed by ---
*  @author            Karishma Gurjar
*  @date              05th Nov, 2019
*  @description       Changed Opportunity Stage to "Closed - Won" to capture "OppDealIdUpdate" method of base class

// test santosh 
*/
@isTest(SeeAllData=False)
public without sharing class ICRM_OpportunityTriggerHandlerTest {
    
    /** @description - test setup method for creating test data */
    
    @testSetup 
    static void testdataSetup(){
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspect Account Test';
        insert acc;
        
        Profile pfId = [SELECT Id FROM Profile WHERE Name = 'ICRM Base' LIMIT 1]; 
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

        ICRM_TESTInsertFutureUser.insertUser();  
    }
    
    /*  Test for After Insert  */
    @istest
    public static void testTrigger(){
        
        User bUser = [SELECT Id, Username,UserType FROM User WHERE Username like 'test123@xyz.co%' LIMIT 1];
        Account acct = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0;i<5;i++){
            
            Opportunity opp = new Opportunity();
            string recTypeid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();
            opp.RecordTypeId = recTypeid;
            opp.AccountId = acct.Id;
            opp.Name = 'Test Opportunity '+i;
            opp.ICRM_Client_Order__c = true;
            opp.ICRM_Tender__c = true;
            // OPP.OwnerId   = BUser.id; 
            Opp.ICRM_Assigned_Owner__c = BUser.id; 
            opp.StageName = 'Closed - Won';
            opp.CloseDate = Date.today() + 1;
            opp.ICRM_RBU__c = 'NAGP Gas';
            opp.ICRM_Phy_Fin__c = 'Physical';
            opp.ICRM_Start_Date__c = Date.today(); 
            opp.ICRM_Volume_Quantity__c = 100;  
            oppList.add(opp);
        }
        insert oppList;
        
        
        opportunity opptyUpdate = [Select id, name,ICRM_Order_ID_new__c, ICRM_Volume_Quantity__c, ICRM_Volume_Quantity_Lost__c, 	ICRM_Volume_Quantity_Won__c
                                   from Opportunity where name like 'Test Opportunity%' limit 1];
        
        OpptyUpdate.ICRM_Volume_Quantity__c = 50; 
        OpptyUpdate.ICRM_Volume_Quantity_Lost__c = 20; 	
        OpptyUpdate.ICRM_Volume_Quantity_Won__c = 30;
        
        update OpptyUpdate; 
        System.assert(OpptyUpdate.ICRM_Order_ID_new__c <> 0, 'Test Class Failed');
    }
    
}