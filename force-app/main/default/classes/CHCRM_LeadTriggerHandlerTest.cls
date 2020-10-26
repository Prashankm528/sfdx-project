/* @author            WuTong
*  @date              07/06/2020
*  @description       Test CHCRM_LeadTriggerHandler   
*/

@IsTest
private with sharing class CHCRM_LeadTriggerHandlerTest {
    
    
    @testSetup
    static void initData(){
        Profile prof = [select id from profile where Name = 'System Administrator' LIMIT 1];
        User Contextuser = new User(alias = 'TestUser', email= 'test@test.com',
                                    emailencodingkey= 'UTF-8', lastname = 'Test User',
                                    timezonesidkey='America/Los_Angeles',
                                    languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = prof.Id,
                                    UserRoleId= NULL,
                                    username= 'TestUser' + System.currentTimeMillis() + '@testorg.com');
        insert Contextuser;
        User Contextuser2 = new User(alias = 'Test2', email= 'test2@test.com',
                                    emailencodingkey= 'UTF-8', lastname = 'Test User2',
                                    timezonesidkey='America/Los_Angeles',
                                    languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = prof.Id,
                                    UserRoleId= NULL,
                                    username= 'TestUser2' + System.currentTimeMillis() + '@testorg.com');
        insert Contextuser2;        
        CHCRM_Geography__c province = new CHCRM_Geography__c();
        province.RecordTypeId = Schema.SObjectType.CHCRM_Geography__c.getRecordTypeInfosByDeveloperName().get('CHCRM_Province').getRecordTypeId();
        province.CHCRM_Active__c = true;
        province.Name = 'Test Pprovince';
        province.CHCRM_ILS_Lead_Owner__c = Contextuser.Id;
        insert province;
        CHCRM_Geography__c geo = new CHCRM_Geography__c();
        geo.RecordTypeId = Schema.SObjectType.CHCRM_Geography__c.getRecordTypeInfosByDeveloperName().get('CHCRM_City').getRecordTypeId();
        geo.CHCRM_Active__c = true;
        geo.CHCRM_Province__c = province.Id;
        geo.Name = 'Test';
        geo.CHCRM_ILS_Lead_Owner__c = Contextuser.Id;
        insert geo;
        
    }
    
    private static testMethod void testInsert1(){
        CHCRM_Geography__c geo = [SELECT ID ,CHCRM_Province__c , CHCRM_ILS_Lead_Owner__c FROM CHCRM_Geography__c WHERE Name = 'Test'];
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('CHCRM_ILS_Lead').getRecordTypeId();
        l.CHCRM_City__c = geo.Id;
        l.CHCRM_Province__c = geo.CHCRM_Province__c;
        l.FirstName = 'Acc';
        l.LastName = 'Test';
        insert l;
        Lead result = [SELECT ID , OwnerId FROM Lead WHERE ID =:l.Id];
        System.assertEquals(geo.CHCRM_ILS_Lead_Owner__c, result.OwnerId);
    }
    
	
    private static testMethod void testInsert2(){
        CHCRM_Geography__c geo = [SELECT ID ,CHCRM_Province__c , CHCRM_ILS_Lead_Owner__c FROM CHCRM_Geography__c WHERE Name = 'Test Pprovince'];
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('CHCRM_ILS_Lead').getRecordTypeId();
        l.CHCRM_Province__c = geo.Id;
        l.FirstName = 'Acc';
        l.LastName = 'Test';
        insert l;
        Lead result = [SELECT ID , OwnerId FROM Lead WHERE ID =:l.Id];
        System.assertEquals(geo.CHCRM_ILS_Lead_Owner__c, result.OwnerId);
    }
    
    /*
    private static testMethod void testafterUpdate1(){
        CHCRM_Geography__c geo = [SELECT ID ,CHCRM_Province__c , CHCRM_ILS_Lead_Owner__c FROM CHCRM_Geography__c WHERE Name = 'Test Pprovince'];
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('CHCRM_ILS_Lead').getRecordTypeId();
        l.CHCRM_Province__c = geo.Id;
        l.FirstName = 'Acc';
        l.LastName = 'Test';
        insert l;
        Account acc = CHCRM_TestSetup.createWorkshopAccount('Test CHCRMworkAccount');
        acc.Name = 'Test Account';
        insert acc;
        Lead editLead = new Lead();
        User user = [SELECT ID FROM USER WHERE alias = 'Test2' AND email= 'test2@test.com'];
        editLead.Id = l.Id;
        editLead.OwnerId = user.Id;
        update editLead;
        LeadShare result = [SELECT ID , LeadId FROM LeadShare WHERE LeadAccessLevel = 'Read'];
        System.assertEquals(result.LeadId, l.Id);
    }*/
    
    private static testMethod void testafterUpdate2(){
        CHCRM_Geography__c geo = [SELECT ID ,CHCRM_Province__c , CHCRM_ILS_Lead_Owner__c FROM CHCRM_Geography__c WHERE Name = 'Test Pprovince'];
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('CHCRM_ILS_Lead').getRecordTypeId();
        l.CHCRM_Province__c = geo.Id;
        l.FirstName = 'Acc';
        l.LastName = 'Test';
		l.PCRM_Division_Code__c = '';
        insert l;
        Account acc = CHCRM_TestSetup.createWorkshopAccount('Test CHCRMworkAccount');
		acc.Sales_Division_Code__c = '02';
        acc.Name = 'Test Account';
        insert acc;
        //lead convert to account
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setAccountId(acc.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        CHCRM_Address_Information__c result = [SELECT ID , CHCRM_Account__c FROM CHCRM_Address_Information__c limit 1];
        System.assertEquals(acc.Id, result.CHCRM_Account__c);
    }
    
    
    
}