/**
* @author     Karishma Gurjar
* @date       27/02/2020
* @description    Test class for ICRM_NotesTriggerHandler  
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_NotesTriggerHandlerTest {
    /** @description - test setup method for creating test data */
    @testSetup 
    static void testdataSetup(){
        //Create Test Data for Test Methods
      /*  Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspect Account Test';
        insert acc;
        Opportunity opp = new Opportunity();
        string recTypeid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST Global Opportunity').getRecordTypeId();
        opp.RecordTypeId = recTypeid;
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Closed - Won';
        opp.CloseDate = Date.today() + 1;
        opp.ICRM_Phy_Fin__c = 'Physical';
        insert opp;
        
        Contact Con = new Contact();
        string recTypeidContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('IST Contact').getRecordTypeId();
        Con.RecordTypeId = recTypeidContact;
        Con.FirstName = 'Test';
        Con.LastName = 'Contact1';
        Con.AccountId = acc.id;        
        insert Con;
        ContentNote cn = new ContentNote();
        cn.Title = 'test1';
        String body = 'notes body';
        cn.Content = Blob.valueOf(body.escapeHTML4());
        
        insert cn;
        ContentVersion contentVersion = new ContentVersion(
            Title = cn.Title,
            VersionData = cn.Content,
            IsMajorVersion = true,
            contentdocumentid=cn.id
        );
        
        */
    }
    @istest
    public static void testTriggerAccount(){
        /** @description - test method to trigger when Notes is created on Account */   
       /* Account acct = [SELECT Id, Name from Account where Name = 'ISTProspect Account Test'];
        ContentNote cn=[SELECT Id, title,Content from ContentNote where title = 'test1'];
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl; 
        ICRM_Notes__c nt1= [SELECT Id,ICRM_Note_ID__c FROM ICRM_Notes__c Where ICRM_Note_ID__c=:cn.Id];
        System.assertEquals(nt1.ICRM_Note_ID__c,cn.id,'ICRM Notes on Account got created');
        cn.title='Update one';
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        update cn;
        test.stopTest();
        ContentVersion contentVersion1 = new ContentVersion(
            Title = cn.Title,
            VersionData = cn.Content,
            IsMajorVersion = true,
            contentdocumentid=cn.id
        );
        ICRM_Notes__c nt2= [SELECT Id,ICRM_Notes_Title__c,ICRM_Note_ID__c FROM ICRM_Notes__c Where ICRM_Note_ID__c=:cn.Id];
        System.assertEquals(nt2.ICRM_Notes_Title__c,cn.Title,'ICRM Notes on Account got updated');
        delete documents;*/
    }
    @istest
    public static void testTriggerOppty(){
        /** @description - test method to trigger when Notes is created on Opportunity */   
        /*Opportunity opp = [SELECT Id, Name from Opportunity where Name = 'Test Opportunity'];
        ContentNote Listcn=[SELECT Id, title,Content from ContentNote where title = 'test1'];
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        test.startTest();
        ContentDocumentLink conDocLin = New ContentDocumentLink();
        conDocLin.LinkedEntityId = opp.id;
        List<ContentDocument> ListDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        conDocLin.ContentDocumentId = ListDocument[0].Id;
        conDocLin.shareType = 'V';
        insert conDocLin;
        ICRM_Notes__c ListNote= [SELECT Id,ICRM_Note_ID__c FROM ICRM_Notes__c Where ICRM_Note_ID__c=:Listcn.Id];
        System.assertEquals(ListNote.ICRM_Note_ID__c,Listcn.id,'ICRM Notes on opportunity got created');
        Listcn.title='Update COntent';
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        update Listcn;
        test.stopTest();
        ContentVersion cv1 = new ContentVersion(
            Title = Listcn.Title,
            VersionData = Listcn.Content,
            IsMajorVersion = true,
            contentdocumentid=Listcn.id
        );
        ICRM_Notes__c ListNote1= [SELECT Id,ICRM_Notes_Title__c,ICRM_Note_ID__c FROM ICRM_Notes__c Where ICRM_Note_ID__c=:Listcn.Id];
        System.assertEquals(ListNote1.ICRM_Notes_Title__c,Listcn.Title,'ICRM Notes on Opportunity got updated');
        */
    }
    @istest
    public static void testTriggerContact(){
        /** @description - test method to trigger when Notes is created on Contact */   
       /* Contact con = [SELECT Id, Name from Contact where Name = 'Test Contact1'];
        ContentNote NoteList=[SELECT Id, title,Content from ContentNote where title = 'test1'];
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        test.startTest();
        ContentDocumentLink DocLinkList = New ContentDocumentLink();
        DocLinkList.LinkedEntityId = con.id;
        List<ContentDocument> documentList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        DocLinkList.ContentDocumentId = documentList[0].Id;
        DocLinkList.shareType = 'V';
        insert DocLinkList; 
        ICRM_Notes__c SavedNote= [SELECT Id,ICRM_Note_ID__c FROM ICRM_Notes__c Where ICRM_Note_ID__c=:NoteList.Id];
        System.assertEquals(SavedNote.ICRM_Note_ID__c,NoteList.id,'ICRM Notes on Contact got created');
        NoteList.title='Test Note Content';
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        update NoteList;
        test.stopTest();
        ContentVersion verCon = new ContentVersion(
            Title = NoteList.Title,
            VersionData = NoteList.Content,
            IsMajorVersion = true,
            contentdocumentid=NoteList.id
        );
        ICRM_Notes__c UpdatedNote= [SELECT Id,ICRM_Notes_Title__c,ICRM_Note_ID__c FROM ICRM_Notes__c Where ICRM_Note_ID__c=:NoteList.Id];
        System.assertEquals(UpdatedNote.ICRM_Notes_Title__c,NoteList.Title,'ICRM Notes on Contact got updated');
        */
    }
    
}