@IsTest
public with sharing class LCP_RecordSharingRpProposalInsertTest {
    
    static testmethod void LCP_RecordSharingRpProposalInsert_BPManager_Test(){
        Profile profileid = [SELECT Id FROM Profile where Name='BPG_BP Base Platform'];
        user usrwoco=new user();
            usrwoco.Alias= 'Tstusr';
            usrwoco.CommunityNickname=Math.random()+'Tstusr';
            usrwoco.Email=Math.random()+'@testorg.com';
            usrwoco.EmailEncodingKey='UTF-8';
            usrwoco.LastName=Math.random()+'LastName';
            usrwoco.LanguageLocaleKey='en_US';
            usrwoco.LocaleSIdKey='en_US';
            usrwoco.ProfileId = profileid.Id;
            usrwoco.TimeZoneSIdKey='Europe/London';
            usrwoco.Username=Math.random()+'@'+Math.random()+'.test';
            usrwoco.IsActive=true;
            insert usrwoco;
        system.debug('usrwocon====>'+usrwoco);
        
        PermissionSet pss = [SELECT Id FROM PermissionSet WHERE Name='LCP_BP_Project_Manager'];
        PermissionSetAssignment psa2= new PermissionSetAssignment();
            psa2.AssigneeId = usrwoco.id;
            psa2.PermissionSetId = pss.Id;
        
         insert psa2;
        system.debug('psa====>'+psa2);
        //Testing the functionality with BP Manager
        system.runAs(usrwoco){
            Test.startTest();
            List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'Standard');
            system.assertEquals('Standard', pgmList[0].LCP_Template_Name__c);
            List<LCP_Project__c> projList = LCP_TestDataFactory.createProject(1, pgmList[0].id);
            LIst<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_Standard', projList[0].id);
            List<LCP_Reporting_Period_Proposal__c> rpProposalList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            Test.stopTest();
        }
    }
    static testmethod void LCP_RecordSharingRpProposalInsert_CPDev_Test(){
        Profile profileid = [SELECT Id FROM Profile where Name='BPG_BP Base Platform'];
        user usrwocon1s=new user();
            usrwocon1s.Alias= 'Tstusr1';
            usrwocon1s.CommunityNickname=Math.random()+'Tstusr1';
            usrwocon1s.Email=Math.random()+'@testorg1.com';
            usrwocon1s.EmailEncodingKey='UTF-8';
            usrwocon1s.LastName=Math.random()+'LastName1';
            usrwocon1s.LanguageLocaleKey='en_US';
            usrwocon1s.LocaleSIdKey='en_US';
            usrwocon1s.ProfileId = profileid.Id;
            usrwocon1s.TimeZoneSIdKey='Europe/London';
            usrwocon1s.Username=Math.random()+'@'+Math.random()+'.test1';
            usrwocon1s.IsActive=true;
        	insert usrwocon1s;
        system.debug('usrwocon1=====>'+usrwocon1s);
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name='LCP_CP_Developers'];
        PermissionSetAssignment psa1s = new PermissionSetAssignment();
            psa1s.AssigneeId = usrwocon1s.id;
            psa1s.PermissionSetId = ps1.Id;
        
         insert psa1s;
        system.debug('psa1s=====>'+psa1s);
        //Testing the functionality with CP Developer
        system.runAs(usrwocon1s){
            Test.startTest();
            List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'Standard');
            system.assertEquals('Standard', pgmList[0].LCP_Template_Name__c);
            List<LCP_Project__c> projList = LCP_TestDataFactory.createProject(1, pgmList[0].id);
            LIst<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_Standard', projList[0].id);
            List<LCP_Reporting_Period_Proposal__c> rpProposalList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            Test.stopTest();
        }
    }
}