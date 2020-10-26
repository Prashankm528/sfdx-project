@IsTest
public with sharing class LCP_RpProposalControllerTest {
   
    static testMethod void LCP_RpProposal_BPManager_Test(){
        Profile profileid = [SELECT Id FROM Profile where Name='BPG_BP Base Platform'];
        user usrwocos=new user();
            usrwocos.Alias= 'Tstusr';
            usrwocos.CommunityNickname=Math.random()+'Tstusr';
            usrwocos.Email=Math.random()+'@testorg.com';
            usrwocos.EmailEncodingKey='UTF-8';
            usrwocos.LastName=Math.random()+'LastName';
            usrwocos.LanguageLocaleKey='en_US';
            usrwocos.LocaleSIdKey='en_US';
            usrwocos.ProfileId = profileid.Id;
            usrwocos.TimeZoneSIdKey='Europe/London';
            usrwocos.Username=Math.random()+'@'+Math.random()+'.test';
            usrwocos.IsActive=true;
            insert usrwocos;
        system.debug('usrwocos====>'+usrwocos);
        
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name='LCP_BP_Project_Manager'];
        PermissionSetAssignment psa4= new PermissionSetAssignment();
            psa4.AssigneeId = usrwocos.id;
            psa4.PermissionSetId = ps3.Id;
        
         insert psa4;
        system.debug('psa4====>'+psa4);
        //Checking the functionality with BP Manager (Positive Scenario)
        system.runAs(usrwocos){
            //Creating the data by calling the datafactory methods
            LCP_Template_RPProposalMapping__c customsettingvalues = new LCP_Template_RPProposalMapping__c();
            customsettingvalues.LCP_RecordTypeName__c = 'LCP_Standard';
            customsettingvalues.LCP_PageLayoutName__c = 'LCP_Reporting_Period_Proposal__c-Standard';
            customsettingvalues.Name = 'Standard';
            customsettingvalues.LCP_Field_Names__c = 'CreatedDate';
            insert customsettingvalues;
            List<LCP_Program__c> pgmList = LCP_TestDataFactory.createProgram(1,'Standard');
            pgmList[0].LCP_Template_Name__c = 'Standard';
            Update pgmList;
            List<LCP_Project__c> projList = LCP_TestDataFactory.createProject(1, pgmList[0].id);
            List<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_Standard',projList[0].id);
            List<LCP_Reporting_Period_Proposal__c> rpPropList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            List<LCP_Reporting_Period_Proposal__c> rpReviwedPropList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            rpReviwedPropList[0].LCP_Status__c = 'To be reviewed';
            Update rpReviwedPropList;
            
            List<LCP_Reporting_Period_Proposal__c> rpApprovedPropList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            rpApprovedPropList[0].LCP_Status__c = 'Approved';
            Update rpApprovedPropList;
            
            Test.startTest();
            LCP_RpProposalApprovalsController.fetchRPProposalRecord(rpPropList[0].id);
            Boolean bpManager = LCP_RpProposalApprovalsController.fetchLoggedInInfo();
            system.assertEquals(true, bpManager);
            
            LCP_ViewRPProposalController.getPicklistTemplatevalues();
            LCP_ViewRPProposalController.fetchRPProposalRecord('Standard', rpList[0].id);
            LCP_ViewRPProposalController.getRPPicklistvalues('Standard');
            
            Boolean loggedInBpManager = LCP_RpProposalApprovalsController.fetchLoggedInInfo();
            system.assertEquals(true, loggedInBpManager);
            Test.stopTest();
        }
    }
    static testMethod void LCP_RpProposal_CPDeveloper_Test(){
         Profile profileid = [SELECT Id FROM Profile where Name='BPG_BP Base Platform'];
        user usrwocon3s=new user();
            usrwocon3s.Alias= 'Tstusr1';
            usrwocon3s.CommunityNickname=Math.random()+'Tstusr1';
            usrwocon3s.Email=Math.random()+'@testorg1.com';
            usrwocon3s.EmailEncodingKey='UTF-8';
            usrwocon3s.LastName=Math.random()+'LastName1';
            usrwocon3s.LanguageLocaleKey='en_US';
            usrwocon3s.LocaleSIdKey='en_US';
            usrwocon3s.ProfileId = profileid.Id;
            usrwocon3s.TimeZoneSIdKey='Europe/London';
            usrwocon3s.Username=Math.random()+'@'+Math.random()+'.test1';
            usrwocon3s.IsActive=true;
        	insert usrwocon3s;
        system.debug('usrwocon3s=====>'+usrwocon3s);
        
        PermissionSet ps1s = [SELECT Id FROM PermissionSet WHERE Name='LCP_CP_Developers'];
        PermissionSetAssignment psa3s = new PermissionSetAssignment();
            psa3s.AssigneeId = usrwocon3s.id;
            psa3s.PermissionSetId = ps1s.Id;
        
         insert psa3s;
        system.debug('psa3s=====>'+psa3s);
        system.runAs(usrwocon3s){
            //Creating the data by calling the datafactory methods
            LCP_Template_RPProposalMapping__c customsettingvalues1 = new LCP_Template_RPProposalMapping__c();
            customsettingvalues1.LCP_RecordTypeName__c = 'LCP_Standard';
            customsettingvalues1.LCP_PageLayoutName__c = 'LCP_Reporting_Period_Proposal__c-Standard';
            customsettingvalues1.Name = 'Standard';
            customsettingvalues1.LCP_Field_Names__c = 'CreatedDate';
            insert customsettingvalues1;
            List<LCP_Program__c> pgmList1 = LCP_TestDataFactory.createProgram(1,'Standard');
            pgmList1[0].LCP_Template_Name__c = 'Standard';
            Update pgmList1;
            List<LCP_Project__c> projList = LCP_TestDataFactory.createProject(1, pgmList1[0].id);
            List<LCP_Reporting_Period__c> rpList = LCP_TestDataFactory.createRP(1, 'LCP_Standard',projList[0].id);
            List<LCP_Reporting_Period_Proposal__c> rpPropList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            rpPropList[0].LCP_Status__c = 'To be reviewed';
            update rpPropList;
            
            List<LCP_Reporting_Period_Proposal__c> rpApprovedPropList = LCP_TestDataFactory.createRPProposals(1, rpList[0].id);
            rpApprovedPropList[0].LCP_Status__c = 'Approved';
            Update rpApprovedPropList;
            
            Test.startTest();
            LCP_RpProposalApprovalsController.fetchRPProposalRecord(rpPropList[0].id);
            Boolean cpdeveloper = LCP_RpProposalApprovalsController.fetchLoggedInInfo();
            system.assertEquals(false, cpdeveloper);
            
            LCP_ViewRPProposalController.getPicklistTemplatevalues();
            LCP_ViewRPProposalController.fetchRPProposalRecord('Standard', rpList[0].id);
            LCP_ViewRPProposalController.getRPPicklistvalues('Standard');
            
            Boolean loggedInCpDev = LCP_RpProposalApprovalsController.fetchLoggedInInfo();
            system.assertEquals(false, loggedInCpDev);
            Test.stopTest();
        }
    }
}