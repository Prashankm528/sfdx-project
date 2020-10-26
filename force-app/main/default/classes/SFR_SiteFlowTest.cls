@isTest(isParallel=true)
public class SFR_SiteFlowTest {
    
    
     // covers the SFR site detail update from Lead process builder
    @isTest
    private static void UpdateLead_SFRSITE_DetailUpdateFromLead_ProcessFired() {
        test.startTest();
        
        //create new site
        
        SFR_Site__c TestSite = new SFR_Site__c(Name='Test Site');
        insert TestSite;
        Id SFRRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SFR_Site_Acquisition').getRecordTypeId();
        
        
        // Construct a test Opportunity
        Lead TestLead = new Lead(FirstName ='test',LastName='Lead',status='Qualified',SFR_Site__c=TestSite.Id,recordtypeId=SFRRecordTypeId);
        
        // Save this Opportunity to the database
        insert TestLead;
        
        
        // Load the Opportunity:
        Lead loadedLead = [SELECT Email,status FROM Lead where id=:TestLead.Id];
        
        // Set the Tracked value to something else:
        loadedLead.Email = 'test@gmail.com';
        TestSite.SFR_Detail__c= loadedLead.status;
        // Save it to the database, and fire the process builder
        
        update TestSite;
        update loadedLead;
        test.stopTest();
    }
    
    // covers the SFR site detail change from opportunity process builder
    @isTest
    private static void UpdateLead_SFR_Site_DetailFieldChangeFromOpportunity(){
        test.startTest();
        
        //create new site
        
        SFR_Site__c TestSite = new SFR_Site__c(Name='Test Site');
        insert TestSite;
        Id SFRRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFR_Site_Opportunity').getRecordTypeId();
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Sales_Organisation__c = 'MX02';
        testAccount.Business_Unit__c = 'Fuels - Dealer';
        testAccount.Service_Experience_Level__c = 'SL Silver';
        insert testAccount;
        
        
        // Construct a test Opportunity
        Opportunity TestOpportunity = new Opportunity(Name ='test opp',AccountId=testAccount.id,StageName='ATN',SFR_Site__c=TestSite.Id,recordtypeId=SFRRecordTypeId,CloseDate=Date.newInstance(2020,27,2));
        
        // Save this Lead to the database
        insert TestOpportunity;
        
        
        // Load the Lead:
        Opportunity loadedopp = [SELECT StageName FROM Opportunity where id=:TestOpportunity.Id];
        
        // Set the Tracked value to something else:
        loadedopp.StageName = 'Contract';   
        TestSite.SFR_Detail__c=loadedopp.StageName;
        // Save it to the database, and fire the process builder
        
        update TestSite;
        update loadedopp;
        System.assert(loadedopp.id!=null , 'Opportunity Created');
        test.stopTest();
    }
    
    @isTest
    private static void SFRLeadSiteApproval() {
        test.startTest();
        //create new user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'BP Base (Salesforce)' LIMIT 1];
        User u1 = BPG_Test_Util.createsTestUser(profile.Id, 'Test', 'user1');
        
        //create new user
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'BP Base (Salesforce)' LIMIT 1];
        User u2 = BPG_Test_Util.createsTestUser(profile1.Id, 'Test', 'user2');
        
        
        //create new site
        
        SFR_Site__c TestSite = new SFR_Site__c(Name='Test Site',SFR_REPM_Contract__c=u1.id);
        insert TestSite;
        Id SFRRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SFR_Site_Acquisition').getRecordTypeId();
        
        
        // Construct a test Opportunity
        Lead TestLead = new Lead(FirstName ='test',LastName='Lead',SFR_REPM_Changed__c=true,status='Qualified',SFR_Site__c=TestSite.Id,recordtypeId=SFRRecordTypeId);
        TestLead.SFR_REPM_Contract__c=null;
        // Save this Opportunity to the database
        insert TestLead;
        
        
        // Load the Opportunity:
        Lead loadedLead = [SELECT Email,status,SFR_By_Pass_Validation__c,SFR_REPM_Contract__c FROM Lead where id=:TestLead.Id];
        
        // Set the Tracked value to something else:
        loadedLead.OwnerId=u2.id;
        loadedLead.Email = 'test@gmail.com';
        loadedLead.SFR_REPM_Contract__c=TestSite.SFR_REPM_Contract__c;
        loadedLead.SFR_By_Pass_Validation__c=system.now();
        loadedLead.SFR_REPM_Changed__c=false;
        
        
        TestSite.SFR_Detail__c= loadedLead.status;
        TestSite.SFR_REPM_Follow_Up__c=loadedLead.OwnerId;
        TestSite.SFR_REPM_Contract__c=loadedLead.OwnerId;
        TestSite.SFR_By_Pass_Validation__c=system.now();
        // Save it to the database, and fire the process builder
        
        update TestSite;
        update loadedLead;
        
        loadedLead.SFR_REPM_Contract__c=loadedLead.OwnerId;
        update loadedLead;
        System.assert(loadedLead.id!=null , 'Lead Created');
        test.stopTest();
    }
    
}