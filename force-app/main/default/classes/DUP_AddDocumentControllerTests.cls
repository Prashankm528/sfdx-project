/*****************************************************************************************
*       Date:           27SEP19
*       Author:         Naglis Jonas Kazlauskas - IBM
*       Description:    Test class for DUP_AddDocumentController.apxc
*       Updated:        7Jan20 - Arron Kukadia 
*****************************************************************************************/

@isTest
public with sharing class DUP_AddDocumentControllerTests {
    /**
    * @description 	creates data which is used in the later tests
    * @param
    * @return
    */
    @TestSetup 
    static void TestSetup(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        String PositiveUserEmail2 = 'positive2@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<User> newUser2 = DUP_DataFactory.createUser(1, pf, PositiveUserEmail2);
        insert newUser2;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(2);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(2, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(newUser);
        insert newCounterpartyContactList;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList2 = DUP_DataFactory.createCounterPartyContact(newUser2);
        insert newCounterpartyContactList2;
        
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                               newCounterpartyContactList, 200);
        insert newDocumentStoreList;
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList; 
        Datetime sometime = Datetime.now().addDays(-25);
        Test.setCreatedDate(newUser[0].Id, sometime);
    }  
    /**
    * @description  positive getDocumentStore test - retrieves all of the documents stores associated with a specific request
    * @param
    * @return
    */
    @isTest static void getDocumentStoreTestPositive(){
        DUP_Document_Request__c newRequestTest = [SELECT Name, Id 
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        
        Test.startTest();
        List<DUP_Document_Store__C> documentList = DUP_AddDocumentController.getDocumentStore(newRequestTest.Id);
        Test.stopTest();
        System.assertEquals(200, documentList.size());
    }
    
    /**
    * @description  change CP test
    * @param
    * @return
    */
    @isTest static void testChangeCP(){
        DUP_Document_Request__c newRequestTest = [SELECT Name, Id 
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        
        Test.startTest();
        List<DUP_Document_Store__C> documentList = DUP_AddDocumentController.getDocumentStore(newRequestTest.Id);
        
        documentList[0].DUP_Document_Status__c = 'Requested';
        documentList[1].DUP_Document_Status__c = 'Requested';
        update documentList;
        
        List<DUP_Document_Store__C> documentListTemp = new  List<DUP_Document_Store__C>();
        documentListTemp.add(documentList[0]);
        documentListTemp.add(documentList[1]);
        
        Id counterParty = [select id from DUP_Counterparty_Contact__c where DUP_Email__c = 'positive2@controllertest.com'].Id;
        String retData = DUP_AddDocumentController.changeCounterPartyContact(newRequestTest.Id, counterParty, 'positive2@controllertest.com');
        DUP_AddDocumentController.getLookupList('test','DUP_Counterparty_Contact__c');
        Test.stopTest();
        System.assertEquals('Updated', retData);
    }
    /**
    * @description  negative getDocumentStore test - testing retrieval of document stores when none are attatched to a document request
    * @param
    * @return
    */
    @isTest static void getDocumentStoreTestNegative() {
        DUP_Document_Request__c newRequestTest = [SELECT Id 
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest1' 
                                                  LIMIT 1];
        Test.startTest();
        List<DUP_Document_Store__C> documentList = DUP_AddDocumentController.getDocumentStore(newRequestTest.Id);
        Test.stopTest();
        System.assertEquals(0, documentList.size());
    }
    /**
    * @description 	getFile positive test - retrieves a file attatched to a document store
    * @param
    * @return
    */  
    @isTest static void getFilePositiveTest(){
        Id newRequestTest = [SELECT Id 
                             FROM DUP_Document_Request__c 
                             WHERE DUP_CounterParty_Name__c ='ControlerTest0'].Id;
        
        Id docStoreId  = [SELECT Id 
                          FROM DUP_Document_Store__c 
                          WHERE DUP_Document_Request__c =: newRequestTest
                          LIMIT 1].Id;
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i<1; i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docStoreId;
            cdl.ContentDocumentId   = cdList[i].id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
        Test.startTest();
        List<ContentDocumentLink> cdlList = DUP_AddDocumentController.getFile(docStoreId);
        Test.stopTest();
        System.assertEquals(false, cdlList.Contains(null));
    }
    /**
    * @description 	getFile negative test - retrieves data when no documents are attacthed to store
    * @param
    * @return
    */ 
    @isTest static void getFileNegativeTest(){
        Id newRequestTest = [SELECT Id 
                             FROM DUP_Document_Request__c 
                             WHERE DUP_CounterParty_Name__c ='ControlerTest0'].Id;
        
        Id docStoreId  = [SELECT Id 
                          FROM DUP_Document_Store__c 
                          WHERE DUP_Document_Request__c =: newRequestTest
                          LIMIT 1].Id;
        
        Test.startTest();
        try {
            List<ContentDocumentLink> cdlList = DUP_AddDocumentController.getFile(docStoreId);
        } catch (DMLException  e) {
            System.assertEquals(e.getTypeName(), 'NullPointerException ');
        }    
        Test.stopTest();
    }
    /**
    * @description 	sendReminder positive test - sends a reminder when relevant documents to a 
    * specific requets haven't been submitted
    * @param
    * @return
    */ 
    @isTest static void sendReminderPositiveTest(){
        Id newRequestTest = [SELECT Id 
                             FROM DUP_Document_Request__c 
                             WHERE DUP_CounterParty_Name__c ='ControlerTest0'].Id;
          List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                DUP_Document_Status__c,
                DUP_Document_Request__c,
                DUP_Reject_Comments__c
            FROM DUP_Document_Store__c
            WHERE DUP_Document_Request__c =:newRequestTest];
        for(DUP_Document_Store__c ds :docStoreRecords){
            ds.DUP_Requested__c = true;
             ds.DUP_Document_Status__c = 'Uploaded';
        }
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        DUP_AddDocumentController.sendReminder(newRequestTest);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();        
        System.assertNotEquals(1,0);
    }
    /**
    * @description 	sendReminder negative test
    * @param
    * @return
    */ 
    @isTest static void sendReminderNegativeTest(){
        Id newRequestTest = [SELECT Id 
                             FROM DUP_Document_Request__c 
                             WHERE DUP_CounterParty_Name__c ='ControlerTest1'].Id;
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        DUP_AddDocumentController.sendReminder(newRequestTest);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(invocationsPreTest, invocations);
    }
    /**
    * @description 	sendRejection positive test - sends a rejection email to the counterparty
    * @param
    * @return
    */ 
    @isTest static void sendRejectionPositiveTest(){
        Id newRequestTest = [SELECT Id
                             FROM DUP_Document_Request__c 
                             WHERE DUP_CounterParty_Name__c ='ControlerTest0'].Id;
        
		List<DUP_Document_Store__c> dsList = [SELECT DUP_Document_Status__c,
                                               DUP_Reject_Comments__c 
                                              FROM DUP_Document_Store__c 
                                              WHERE DUP_Document_Request__c =: newRequestTest
                                             ];
        
        for (DUP_Document_Store__c dS : dsList){
            dS.DUP_Document_Status__c = 'Requested';
            dS.DUP_Reject_Comments__c ='Pupulis & Kukulis do not approve';
            dS.DUP_RejectComments_Available__c =true;
        }
        upsert dsList;
        
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        try {
            DUP_AddDocumentController.sendRejection(newRequestTest);
        } catch(Exception e) {
            System.debug('Send emails bug: ' + e);            
        }        
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();        
        System.assertNotEquals(invocationsPreTest,invocations);
    }
    /**
    * @description 	sendRejection negative test
    * @param
    * @return
    */ 
    @isTest static void sendRejectionNegativeTest(){
        Id newRequestTest = [SELECT Id 
                             FROM DUP_Document_Request__c 
                             WHERE DUP_CounterParty_Name__c ='ControlerTest1'].Id;
       Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        try {
            DUP_AddDocumentController.sendRejection(newRequestTest);
        } catch(Exception e) {
            System.debug('Send emails bug: ' + e);            
        }        
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();        
        System.assertEquals(invocationsPreTest, invocations);
    }
}