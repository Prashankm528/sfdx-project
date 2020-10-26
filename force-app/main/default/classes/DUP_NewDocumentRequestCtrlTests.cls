/*****************************************************************************************
*       Date:        28OCT2019
*       Author:      Naglis Jonas Kazlauskas - IBM
*       Description: test class for DUP_DocumentRequestUtil
*****************************************************************************************/
@isTest
public class DUP_NewDocumentRequestCtrlTests {
    /**
    * @description 	creates data which is used in the later tests
    * @param
    * @return
    */
    @testSetup static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
    }
    /**
    * @description:	test for creating a data wrap
    * @param: 
    * @return: 
    */ 
    @isTest static void DUP_NewDocumentRequestControllerTest(){
        List<DUP_List_Of_Values__c> lovList = DUP_DataFactory.createListOfValues(10);
        insert lovList;
        List<DUP_Document_Template__c> docTemplateList = DUP_DataFactory.createDocumentTemplate(1);
        insert docTemplateList;
        
        Test.startTest();        
        DUP_NewDocumentRequestController.LoadDataWrapper dataWrap = DUP_NewDocumentRequestController.loadSelectsValues();
        Test.stopTest();
        System.assertEquals(10, dataWrap.listOfValuesList.size());
        System.assertEquals(1, dataWrap.docTemplateList.size());   
    }
    /**
    * @description:	positive test for creating a DocStore
    * @param: 
    * @return: 
    */ 
    @isTest static void createDocStoreTestPositive(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        
        Test.startTest();
        DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
        Test.stopTest();
        List<DUP_Document_Store__c> wasIInserted = [SELECT Id FROM DUP_Document_Store__c WHERE DUP_Document_Request__c =: docReqList[0].Id];
        System.assertEquals(false, wasIInserted.isEmpty());
    }
        /**
    * @description:	negative test for creating a DocStore
    * @param: 
    * @return: 
    */ 
    @isTest static void createDocStoreTestNegative(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        for (DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c   = 'error';
        }
        
        Test.startTest();
        Id testMe = DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
        Test.stopTest();
        System.assertEquals(null, testMe);
    }
    /**
    * @description: test for deleteing a DocStore
    * @param: 
    * @return: 
    */ 
    @isTest static void deleteDocStoreTest(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        
        Test.startTest();
        DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
		DUP_NewDocumentRequestController.deleteDocStore(newDocumentStoreList[0]);
        Test.stopTest();
        List<DUP_Document_Store__c> wasIdeleted = [SELECT Id FROM DUP_Document_Store__c WHERE DUP_Document_Request__c =: docReqList[0].Id];
        System.assertEquals(true, wasIdeleted.isEmpty());
    }
    
    /**
    * @description:	Negative test for deleteing a DocStore
    * @param: 
    * @return: 
    */ 
    @isTest static void deleteDocStoreTestNegative(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        
        DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
		DUP_NewDocumentRequestController.deleteDocStore(newDocumentStoreList[0]);
		DmlException expectedException;
		Test.startTest();
        try { 
		DUP_NewDocumentRequestController.deleteDocStore(newDocumentStoreList[0]);
		}
        catch (DmlException dmx) {
		expectedException = dmx; 
		}
		Test.stopTest();
		System.assertEquals(null, expectedException);
        List<DUP_Document_Store__c> wasIDeleted = [SELECT Id FROM DUP_Document_Store__c WHERE DUP_Document_Request__c =: docReqList[0].Id];
        System.assertEquals(true, wasIDeleted.isEmpty());
    }
    /**
    * @description:	Test for UpdateStatusAndReturnFiles
    * @param: With DUP Status Template.
    * @return: 
    */ 
	 @isTest static void UpdateStatusAndReturnFilesPositive(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
        List<ContentVersion> CList = DUP_DataFactory.createContentVersion(1);
        CList[0].DUP_Status__c = 'Template';
        insert CList;
        Id contentDocId = [SELECT contentdocumentid FROM ContentVersion WHERE id=:CList[0].Id limit 1].contentdocumentid;
        List<ContentDocumentLink> ContentDocumentLinkList = DUP_DataFactory.createContentDocumentLink(contentDocId,newDocumentStoreList[0].Id, 1);
        insert ContentDocumentLinkList;
        
        Test.startTest();  
        DUP_NewDocumentRequestController.UpdateStatusAndReturnFiles(newDocumentStoreList[0].Id);
        Test.stopTest();
        List<ContentDocumentLink> wasIUpdated = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: ContentDocumentLinkList[0].LinkedEntityId AND ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Template'];
        System.assertEquals(false, wasIUpdated.isEmpty());
    }
    /**
    * @description:	Test for UpdateStatusAndReturnFiles
    * @param: With DUP Status 'Uploaded'.
    * @return: 
    */ 
	 @isTest static void UpdateStatusAndReturnFilesNegative(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
        List<ContentVersion> CList = DUP_DataFactory.createContentVersion(1);
        CList[0].DUP_Status__c = 'Uploaded';
        insert CList;
        Id contentDocId = [select contentdocumentid from ContentVersion where id=:CList[0].Id limit 1].contentdocumentid;
        List<ContentDocumentLink> ContentDocumentLinkList = DUP_DataFactory.createContentDocumentLink(contentDocId,newDocumentStoreList[0].Id, 1);
        insert ContentDocumentLinkList;
        Test.startTest(); 
        DUP_NewDocumentRequestController.UpdateStatusAndReturnFiles(newDocumentStoreList[0].Id);
        Test.stopTest();
        List<ContentDocumentLink> wasIInserted = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: ContentDocumentLinkList[0].LinkedEntityId];
        System.assertEquals(false, wasIInserted.isEmpty());
        System.assertEquals('Uploaded', CList[0].DUP_Status__c);
         
    }
    /**
    * @description:	Test for UpdateStatusAndReturnFiles
    * @param: With DUP Status Template.
    * @return: 
    */ 
 
	 @isTest static void shareFileWithCounterPartyTest(){
        List<DUP_Document_Request__c> docReqList = [SELECT Id FROM DUP_Document_Request__c WHERE DUP_CounterParty_Name__c = 'ControlerTest0'];
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = 'positive@controllertest.com' LIMIT 1];
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(userList);
        insert newCounterpartyContactList;
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(docReqList,
                                                                                               newCounterpartyContactList, 1);
        DUP_NewDocumentRequestController.createDocStore(newDocumentStoreList[0]);
       	List<ContentVersion> ContentList = DUP_DataFactory.createContentVersion(1);
        insert ContentList;
		Id contentDocId = [select contentdocumentid from ContentVersion where id=:ContentList[0].Id limit 1].contentdocumentid;
        newDocumentStoreList[0].DUP_Document_Name__c = 'TestName';
        update newDocumentStoreList;
        System.debug('DS Title DUP' +newDocumentStoreList[0].DUP_Document_Name__c); 
        System.debug('DS re DUP' +newDocumentStoreList[0].DUP_Document_Request__c); 
         
        String files='[{'; 
        for(ContentVersion cv : ContentList ){
        files = files +'"name" :"'+cv.Title+'",' +'"documentId" : "'+contentDocId+'"},{';
        }
		files = files.removeEnd(',{');
        files= files +']';
        System.debug('filesss'+files);
        Test.startTest(); 
         System.debug('newDocumentStoreListId'+newDocumentStoreList[0].Id);
        DUP_NewDocumentRequestController.shareFileWithCounterParty(newDocumentStoreList[0].Id,files);
        Test.stopTest();
        List<DUP_Document_Store__c> wasIInserted = [SELECT Id FROM DUP_Document_Store__c WHERE DUP_Document_Name__c =: newDocumentStoreList[0].DUP_Document_Name__c];
        System.assertEquals(false, wasIInserted.isEmpty()); 
    }
}