/**
* @author      : Santosh Verma
* @date        : 06/08/2020
* @description : Test class for ICRM_RelationshipTriggerHandler   
*  @ -----------------------------------
*  @ ------------ Changed by -----------
*  @author             
*  @date               
*  @description        
*  
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_RelationshipTriggerHandlerTest {
    /** @description - test setup method for creating test data */
    
    @testSetup 
    static void testdataSetup(){
  
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'IST2340ProspectAccountTest';    
        
        insert acc;
         
        Account acct = [SELECT Id, Name from Account where Name = 'IST2340ProspectAccountTest' limit 1];
        
        Contact cont = new contact();        
        string contRecTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        cont.RecordTypeId = contRecTypeId;
        cont.AccountId = acct.id; 
        cont.lastname = 'Contact2340';
        insert cont;

        // Profile PfId = [SELECT Id FROM Profile WHERE Name = 'ICRM Base' LIMIT 1]; 
        Profile PfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
         
 
        user auser = new user(); 
        auser.lastname = 'test2340'; 
        auser.Username = 'test2340@xyz.com'+ System.currentTimeMillis(); 
        auser.Email = 'test2340@xyz.com';
        auser.Alias = 't2340';
        auser.EmailEncodingKey='UTF-8'; 
        auser.LanguageLocaleKey='en_US'; 
        auser.LocaleSidKey='en_US'; 
        auser.TimeZoneSidKey='America/Chicago'; 
        auser.ProfileId = PfId.id;
        auser.IsActive = true;  
        auser.ICRM_Team__c = 'GOFO';
       insert auser; 
    }

    @istest
    public static void testTrigger(){
/*  Test for After Insert  */        
        
        // Insert relationship record
        
        contact contt = [SELECT Id, Name from contact where Name = 'Contact2340' limit 1];
        user ruser = [SELECT Id, email,ICRM_Team__c from user where Email = 'test2340@xyz.com' limit 1];

        ICRM_Contact_Relationship__c   relationInsert = new ICRM_Contact_Relationship__c(); 
        relationInsert.ICRM_Contact__c = contt.id;
        relationInsert.ICRM_User_Name__c = ruser.id;
        relationInsert.ICRM_Relationship_Notes__c = 'santoshtestrelationnote2340';
        relationInsert.ICRM_Active__c = true;
        relationInsert.ICRM_Relationship_Rating__c = 'Tier 1';

        insert relationInsert; 
        

    Test.startTest(); 
        ICRM_Contact_Relationship__c rrelation = [SELECT Id,ICRM_Relationship_Rating__c, ICRM_R_Team__c,ICRM_Relationship_Notes__c from ICRM_Contact_Relationship__c where ICRM_Relationship_Notes__c = 'santoshtestrelationnote2340'  limit 1];
 
          System.assertEquals('GOFO', rrelation.ICRM_R_Team__c, 'Test Class Failed');
            try{
                    delete rrelation;
            } catch(exception exc){
            String s= exc.getMessage();
        }
	Test.stopTest();
    }
}