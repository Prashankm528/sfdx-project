/***********************************************************************************************
* @author           Naglis Kazlauskas
* @date             30SEP2019
* @group            Digital@BP
* @description      Testing class for Dup_AddDocumentListController.apxc
* @updated          7JAN20  Arron Kukadia
************************************************************************************************/
@isTest
public class DUP_AddDocumentListControllerTests{
    /**
    * @description 	creates data which is used in the later tests
    * @param
    * @return
    */
    @TestSetup
    static void makeData(){
        List<DUP_List_Of_Values__c> newlovList =  DUP_DataFactory.createListOfValues(1);
        insert newlovList;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(2);
        insert entityList;

        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(2,entityList);
        insert newDocumentRequestList;

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;

        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(newUser);
        insert newCounterpartyContactList;

        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                                newCounterpartyContactList, 20);
		for(DUP_Document_Store__c docStore : newDocumentStoreList){
            docStore.DUP_Group_Title__c = 'Test';
        }
        insert newDocumentStoreList;
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList; 
    }

    /**
    * @description 	loadLOVRecords positive test - testing the initialise component method - asserting if created stores no 
    * is equal the the returned stores no. 
    * @param
    * @return
    */
    @isTest static void loadLOVRecordsPositiveTest(){
        Id newRequestTest = [SELECT Id 
                            FROM DUP_Document_Request__c 
                            WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                            LIMIT 1].Id;
        Test.startTest();
        List<DUP_Document_Store__c> storesList = DUP_AddDocumentListController.loadLOVRecords(newRequestTest);
																		DUP_AddDocumentListController.loadRecords(newRequestTest);
        DUP_AddDocumentListController.getLookupList('test','DUP_Counterparty_Contact__c');
        Test.stopTest();
        System.assertEquals(20, storesList.size());
    }
    /**
    * @description 	loadLOVRecords negative test
    * @param
    * @return
    */
    @isTest static void loadLOVRecordsNegativeTest(){
        Id docReqId = [SELECT id
                       FROM DUP_Document_Request__c
                       WHERE DUP_CounterParty_Name__c =: 'ControlerTest1'].Id;

        Test.startTest();
        List<DUP_Document_Store__c> storesList = DUP_AddDocumentListController.loadLOVRecords(docReqId);
        Test.stopTest();

        System.assertEquals(0, storesList.size());
    }
   /**
    * @description 	updateDocStore positive test also tests createContentVersion
    * 				and deleteFiles methods - updating document stores and asserting if the update happened
    * 				by checking linkedEntityId 
    * @param
    * @return
    */
    @isTest static void updateDocStorePositiveTest() {
        Id docReqId = [SELECT Id
                    FROM DUP_Document_Request__c
                    WHERE DUP_CounterParty_Name__c =: 'ControlerTest0'].id;

        List<DUP_Document_Template__c> newDocTemplate = DUP_DataFactory.createDocumentTemplate(1);
        insert newDocTemplate;
        Set<Id> docTemplateIdSet = new Set<Id>();
        for (DUP_Document_Template__c dT : newDocTemplate){
            docTemplateIdSet.add(dT.Id);
        }

        List<DUP_Document_Store__c> docStoreList  = [SELECT DUP_Document_Status__c
                                                FROM DUP_Document_Store__c 
                                                WHERE DUP_Document_Request__c =: docReqId
                                                LIMIT 1];
      	
        for (DUP_Document_Store__c docStore : docStoreList){
            docStore.DUP_Document_Template__c = newDocTemplate[0].id;
        }
        upsert docStoreList;
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i < docStoreList.size(); i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = newDocTemplate[i].Id;
            cdl.ContentDocumentId   = cdList[0].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
       }
       insert insertCDLList;
        
        
		
       Test.startTest();
       DUP_AddDocumentListController.updateDocStore(docStoreList);
       Test.stopTest(); 
       List<ContentDocumentLink> cdlListAfter = [SELECT Id
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId = :newDocTemplate[0].Id];
       System.assertEquals(1, cdlListAfter.size());
            
    }
    /**
    * @description 	updateDocStore negative test also tests createContentVersion
    * 				and deleteFiles methods
    * @param
    * @return
    */
    @isTest static void updateDocStoreNegativeTest() {
        Id docReqId = [SELECT id
                    FROM DUP_Document_Request__c
                    WHERE DUP_CounterParty_Name__c =: 'ControlerTest0'].id;

        List<DUP_Document_Template__c> newDocTemplate = DUP_DataFactory.createDocumentTemplate(1);
        insert newDocTemplate;

        List<DUP_Document_Store__c> docStoreList  = [SELECT DUP_Document_Status__c
                                                FROM DUP_Document_Store__c 
                                                WHERE DUP_Document_Request__c =: docReqId];
      	
        Set<Id> docStoreSetOfIds = new Set<Id>();
        for (DUP_Document_Store__c docStore : docStoreList){
            docStore.DUP_Document_Template__c = newDocTemplate[0].id;
            docStoreSetOfIds.add(docStore.Id);
        }
        upsert docStoreList;
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i < docStoreList.size(); i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docStoreList[i].Id;
            cdl.ContentDocumentId   = cdList[0].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
       }
       insert insertCDLList;

       List<ContentDocumentLink> testStartList = [SELECT Id
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId IN: docStoreSetOfIds];

        Test.startTest();
        DUP_AddDocumentListController.updateDocStore(docStoreList);
        Test.stopTest(); 
		List<ContentDocumentLink> testEndList = [SELECT Id
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId IN: docStoreSetOfIds];
        
        System.assertEquals(20, testStartList.size());
        System.assertEquals(0, testEndList.size());
        
    }
}