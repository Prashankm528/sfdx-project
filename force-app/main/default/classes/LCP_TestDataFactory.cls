@IsTest
public with Sharing class LCP_TestDataFactory {
    
    //Create Account
    Public static List<Account> createAccount(Integer noOfAccounts){
        List<Account> accList = new List<Account>();
        for(integer i=0; i < noOfAccounts; i++){
            Account acc=new Account();
            acc.Name='AccountName'+i;
            accList.add(acc);
        }
        if(!accList.IsEmpty())
            insert accList;
        
        return accList;
    }
    
    //Create Contact
    Public static List<Contact> createContact(Integer noOfContacts, Id accountId){
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('LCP_Contact').getRecordTypeId();        
        
        List<Contact> conList=new List<Contact>();
        for(integer i=0; i < noOfContacts; i++){
            Contact con = new Contact();
            con.AccountId = accountId;
            con.FirstName = 'ConFirst'+i;
            con.LastName = 'ConLast'+i;
            con.Email = 'bpcustomer@org.com'+i;
            con.RecordTypeId = contactRecordTypeId;
            con.LCP_Grouping__c = 'LCP Group';
            conList.add(con);
        }
        if(!conList.IsEmpty())
            insert conList;
        
        return conList;
    }
    
    //Create Program
    Public static List<LCP_Program__c> createProgram(Integer noOfPrograms, String TemplateName){
        List<LCP_Program__c> PgmList = new List<LCP_Program__c>();
        for(Integer i=0; i< noOfPrograms; i++){
            LCP_Program__c pgm = new LCP_Program__c();
            pgm.Name = 'TestProgram'+i;
            pgm.LCP_Template_Name__c = TemplateName;
            PgmList.add(pgm);
        }
        if(!PgmList.IsEmpty()){
            Insert PgmList;
        } 
        return PgmList;
    }
    
    //Create Project
    Public static List<LCP_Project__c> createProject(Integer noOfProjects, Id programId){
        List<LCP_Project__c> ProjectList = new List<LCP_Project__c>();
        for(Integer i=0; i< noOfProjects; i++){
            LCP_Project__c project = new LCP_Project__c();
            project.Name = 'TestProject'+i;
            project.LCP_Program__c = programId;
            project.LCP_Grouping__c = 'LCP Group';
            ProjectList.add(project);
        }
        if(!ProjectList.IsEmpty()){
            Insert ProjectList;
        } 
        return ProjectList;
    }
    
    //Create Reporting Period
    Public static List<LCP_Reporting_Period__c> createRP(Integer noOfRps, String recordTypeName, Id projectId){
        Id rpRecordTypeId = Schema.SObjectType.LCP_Reporting_Period__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();        
        List<LCP_Reporting_Period__c> rpList = new List<LCP_Reporting_Period__c>();
        for(Integer i=0; i< noOfRps; i++){
            LCP_Reporting_Period__c rp = new LCP_Reporting_Period__c();
            rp.RecordTypeId = rpRecordTypeId;
            rp.Name = 'TestRP'+i;
            rp.LCP_Project__c = projectId;
            rpList.add(rp);
        }
        if(!rpList.IsEmpty()){
            Insert rpList;
        } 
        return rpList;
    }
    
    //Create Reporting Period Proposal
    Public static List<LCP_Reporting_Period_Proposal__c> createRPProposals(Integer noOfRpProposals, Id reportingPeriodId){
        List<LCP_Reporting_Period_Proposal__c> rpProposalList = new List<LCP_Reporting_Period_Proposal__c>();
        for(Integer i=0; i< noOfRpProposals; i++){
            LCP_Reporting_Period_Proposal__c rpps = new LCP_Reporting_Period_Proposal__c();
            rpps.Name = 'TestRPProposal'+i;
            rpps.LCP_Reporting_Period__c = reportingPeriodId;
            rpProposalList.add(rpps);
        }
        if(!rpProposalList.IsEmpty()){
            Insert rpProposalList;
        } 
        return rpProposalList;
    }
    
    //Create Risk
    Public static List<LCP_Risk__c> createRisk(Integer noOfRisks){
        List<LCP_Risk__c> riskList = new List<LCP_Risk__c>();
        for(Integer i=0; i< noOfRisks; i++){
            LCP_Risk__c risk = new LCP_Risk__c();
            risk.Name = 'TestRisk'+i;
            riskList.add(risk);
        }
        if(!riskList.IsEmpty()){
            Insert riskList;
        } 
        return riskList;
    }
    //Create User
    Public static List<User> createUserWithContact(Integer noOfUsers, Id ContactId, String profileName){
        Profile profileid = [SELECT Id FROM Profile where Name=: profileName limit 1];
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = dateString + randomInt;
        
        List<User> userList=new List<User>();
        for(Integer i=0; i < noOfUsers; i++){    
            user usr=new user();
            usr.ContactId = ContactId;
            usr.Alias= uniqueName.substring(0, 7);
            usr.CommunityNickname=Math.random()+'Tstusr'+i;
            usr.Email=Math.random()+'@testorg.com'+i;
            usr.EmailEncodingKey='UTF-8';
            usr.LastName=Math.random()+'LastName'+i;
            usr.LanguageLocaleKey='en_US';
            usr.LocaleSIdKey='en_US';
            usr.ProfileId = profileid.Id;
            usr.TimeZoneSIdKey='Europe/London';
            usr.Username=Math.random()+'@'+Math.random()+'.test';
            usr.IsActive=true;
            userList.add(usr);
        }
        if(!userList.IsEmpty())
            insert userList;
        
        return userList;
    }
    
    //Create User
    Public static List<User> createUserWithOutContact(Integer noOfUsers, String profileName){
        Profile profileid = [SELECT Id FROM Profile where Name=: profileName limit 1];       
        List<User> userLists=new List<User>();
        for(Integer i=0; i < noOfUsers; i++){    
            user usrwocon=new user();
            usrwocon.Alias= 'Tstusr'+i;
            usrwocon.CommunityNickname=Math.random()+'Tstusr'+i;
            usrwocon.Email=Math.random()+'@testorg.com'+i;
            usrwocon.EmailEncodingKey='UTF-8';
            usrwocon.LastName=Math.random()+'LastName'+i;
            usrwocon.LanguageLocaleKey='en_US';
            usrwocon.LocaleSIdKey='en_US';
            usrwocon.ProfileId = profileid.Id;
            usrwocon.TimeZoneSIdKey='Europe/London';
            usrwocon.Username=Math.random()+'@'+Math.random()+'.test';
            usrwocon.IsActive=true;
            userLists.add(usrwocon);
        }
        if(!userLists.IsEmpty())
            insert userLists;
        
        return userLists;
    }
    
    //Create PermissionSetAssignment
    Public static List<PermissionSetAssignment> createPermissionSetAssignment(Integer noOfPermissionSetAssignments, Id UserId, String PermissionSetName){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: PermissionSetName];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(Integer i = 0; i< noOfPermissionSetAssignments; i++){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserId;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }
        if(!psaList.isEmpty())
            insert psaList;
        
        return psaList;
    }
}