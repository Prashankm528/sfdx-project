@IsTest
public with sharing class LCP_ProposeChangesControllerTest {
    
    static testmethod void LCP_ProposeChangesCont_BPManager_Test(){
       Profile profileid = [SELECT Id FROM Profile where Name='BPG_BP Base Platform'];
        user usrwocon=new user();
            usrwocon.Alias= 'Tstusr';
            usrwocon.CommunityNickname=Math.random()+'Tstusr';
            usrwocon.Email=Math.random()+'@testorg.com';
            usrwocon.EmailEncodingKey='UTF-8';
            usrwocon.LastName=Math.random()+'LastName';
            usrwocon.LanguageLocaleKey='en_US';
            usrwocon.LocaleSIdKey='en_US';
            usrwocon.ProfileId = profileid.Id;
            usrwocon.TimeZoneSIdKey='Europe/London';
            usrwocon.Username=Math.random()+'@'+Math.random()+'.test';
            usrwocon.IsActive=true;
            insert usrwocon;
        system.debug('usrwocon====>'+usrwocon);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='LCP_BP_Project_Manager'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = usrwocon.id;
            psa.PermissionSetId = ps.Id;
        
         insert psa;
        system.debug('psa====>'+psa);
        //Checking the functionality with BP Manager (Positive Scenario)
        system.runAs(usrwocon){
            //Creating the data by calling the datafactory methods
            LCP_Template_ReportingPeriodViewAll__c fieldsdata = new LCP_Template_ReportingPeriodViewAll__c();
            fieldsdata.Name = 'California';
            fieldsdata.LCP_PageLayoutName__c = 'LCP_Reporting_Period__c-California';
            fieldsdata.LCP_RecordTypeName__c = 'LCP_California';
            fieldsdata.LCP_Field_Names__c = 'Name,LCP_Final_credits__c,LCP_Project_name__c,LCP_OR_ID__c,LCP_ARB_ID__c,LCP_Grouping__c,LCP_Project_Type__c';            
            fieldsdata.LCP_RP_Proposal_Record_Type__c = 'LCP_California';
            insert fieldsdata;
            
            List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'California');
            List<LCP_Project__c> projList = LCP_TestDataFactory.createProject(1, pgmList[0].id);
            List<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_California' , projList[0].id);
            system.assertEquals('California', pgmList[0].LCP_Template_Name__c);
            
            //Testing the functionality
            Test.startTest();
            LCP_ProposeChangesController.fetchExistingRpProposalDetails(rpList[0].id);
            Test.stopTest();
        }      
    }
    
    static testmethod void LCP_ProposeChangesCont_CPDev_Test(){
        Profile profileid = [SELECT Id FROM Profile where Name='BPG_BP Base Platform'];
        user usrwocon1=new user();
            usrwocon1.Alias= 'Tstusr1';
            usrwocon1.CommunityNickname=Math.random()+'Tstusr1';
            usrwocon1.Email=Math.random()+'@testorg1.com';
            usrwocon1.EmailEncodingKey='UTF-8';
            usrwocon1.LastName=Math.random()+'LastName1';
            usrwocon1.LanguageLocaleKey='en_US';
            usrwocon1.LocaleSIdKey='en_US';
            usrwocon1.ProfileId = profileid.Id;
            usrwocon1.TimeZoneSIdKey='Europe/London';
            usrwocon1.Username=Math.random()+'@'+Math.random()+'.test1';
            usrwocon1.IsActive=true;
        	insert usrwocon1;
        system.debug('usrwocon1=====>'+usrwocon1);
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name='LCP_CP_Developers'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
            psa1.AssigneeId = usrwocon1.id;
            psa1.PermissionSetId = ps1.Id;
        
         insert psa1;
        system.debug('psa1=====>'+psa1);
        system.runAs(usrwocon1){
            //Creating the data by calling the datafactory methods
            LCP_Template_ReportingPeriodViewAll__c fieldsdata = new LCP_Template_ReportingPeriodViewAll__c();
            fieldsdata.Name = 'Standard';
            fieldsdata.LCP_PageLayoutName__c = 'LCP_Reporting_Period__c-Standard';
            fieldsdata.LCP_RecordTypeName__c = 'LCP_Standard';
            fieldsdata.LCP_Field_Names__c = 'Name,LCP_Program__c,LCP_Final_credits__c,LCP_Credit_route__c,LCP_Project_name__c,LCP_Project_ID__c,LCP_Project_Type__c,LCP_RP1_with_val__c';            
            fieldsdata.LCP_RP_Proposal_Record_Type__c = 'LCP_Standard';
            insert fieldsdata;
            
            List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'Standard');
            List<LCP_Project__c> projList = LCP_TestDataFactory.createProject(1, pgmList[0].id);
            List<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_Standard' , projList[0].id);
            system.assertEquals('Standard', pgmList[0].LCP_Template_Name__c);
            
            Test.startTest();
            //Testing the functionality
            LCP_ProposeChangesController.fetchExistingRpProposalDetails(rpList[0].id);
            Test.stopTest();
        }
    }
}