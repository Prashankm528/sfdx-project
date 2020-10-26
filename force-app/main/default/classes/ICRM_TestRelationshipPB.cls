/**
* @author      : Santosh Verma
* @date        : 12/02/2020
* @description : Test class for Relationship process builder 
*  @ -----------------------------------
*  @ ------------ Changed by -----------
*  @author             
*  @date               
*  @description        
*  
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_TestRelationshipPB {
    
    /** @description - test setup method for creating test data */
    
    @testSetup 
    static void testdataSetup(){
              
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspectAccountTest';
        insert acc;
     
        Account acct = [SELECT Id, Name from Account where Name = 'ISTProspectAccountTest' limit 1];
        
        Contact cont = new contact();        
        string contRecTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        cont.RecordTypeId = contRecTypeId;
        cont.AccountId = acct.id; 
        cont.lastname = 'Contact123';
        insert cont;
        
        //===================================================================
        Profile PfId = [SELECT Id FROM Profile WHERE Name = 'ICRM Base' LIMIT 1]; 
        system.debug('profile@@ = '+PfId); 
 
        user auser = new user(); 
        auser.lastname = 'test2399'; 
        auser.Username = 'test123@xyz.com'+ System.currentTimeMillis(); 
        auser.Email = 'test2399@xyz.com';
        auser.Alias = 't12399';
        auser.EmailEncodingKey='UTF-8'; 
        auser.LanguageLocaleKey='en_US'; 
        auser.LocaleSidKey='en_US'; 
        auser.TimeZoneSidKey='America/Chicago'; 
        auser.ProfileId = PfId.id;
        auser.IsActive = true;  
        auser.ICRM_Team__c = 'GOFO';
      
       insert auser; 
        
        //====================================================================
        // ICRM_TESTInsertFutureUser.insertUser();  
        // Insert relationship record
        contact contt = [SELECT Id, Name from contact where Name = 'Contact123' limit 1];
        user ruser = [SELECT Id, email,ICRM_Team__c from user where Email = 'test2399@xyz.com' limit 1];

        ICRM_Contact_Relationship__c   relation = new ICRM_Contact_Relationship__c(); 
        relation.ICRM_Contact__c = contt.id;
        relation.ICRM_User_Name__c = ruser.id;
        relation.ICRM_Relationship_Notes__c = 'santoshtestrelationnote';
        insert relation; 
    }

    @istest
    public static void testTrigger(){
/*  Test for After Insert  */        
        ICRM_Contact_Relationship__c rrelation = [SELECT Id, ICRM_R_Team__c,ICRM_Relationship_Notes__c from ICRM_Contact_Relationship__c where ICRM_Relationship_Notes__c = 'santoshtestrelationnote'  limit 1];
        system.debug('rrelation.ICRM_R_Team__c = '+rrelation.ICRM_R_Team__c);

        System.assertEquals('GOFO', rrelation.ICRM_R_Team__c, 'Test Class Failed');
    }
   
}