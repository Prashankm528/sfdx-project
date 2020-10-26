/***********************************************************************************************
* @author           Naglis Kazlauskas - IBM
* @date             29OCT2019
* @description      Testing class for SingleFileController
************************************************************************************************/
@isTest
public class DUP_SingleFileControllerTests {
    /**
* @description 	creates data which is used in the later tests
* @param
* @return
*/
    @TestSetup 
    static void makeData(){
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(2);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(2, entityList);
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
                                                                                               newCounterpartyContactList, 1);
        insert newDocumentStoreList;
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList;
    }
    /**
* @description 	deleteSingleDocumentAndRefreshList test - asserting if there are any documents left in the array
* @param
* @return
*/    
    
    @isTest static void deleteSingleDocumentAndRefreshListNegativeTest(){
        Id newRequestTestId  = [SELECT Id 
                                FROM DUP_Document_Request__c 
                                WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                LIMIT 1].Id;
        
        
        Id docStoreId  = [SELECT Id 
                          FROM DUP_Document_Store__c 
                          WHERE DUP_Document_Request__c =: newRequestTestId
                          LIMIT 1].Id;
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList;
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i<1; i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docStoreId;
            cdl.ContentDocumentId   = cdList[i].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
        
        Test.startTest();
        List<ContentDocumentLink> linkListTest = DUP_SingleFileController.deleteSingleDocumentAndRefreshList(cdList[0].Id, docStoreId);	
        Test.stopTest();
        System.assertEquals(null, linkListTest);
    }
    
   /* 
	@isTest static void deleteSingleDocumentAndRefreshListPositiveTest(){
   	Id newRequestTestId = [SELECT Id 
                       FROM DUP_Document_Request__c 
                      WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                    LIMIT 1].Id;
    
    Id docStoreId  = [SELECT Id 
                     FROM DUP_Document_Store__c 
                     WHERE DUP_Document_Request__c =: newRequestTestId
                     LIMIT 1].Id;
    
   List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];       
   List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
       for (Integer i = 0; i<1; i++) {
       ContentDocumentLink cdl = New ContentDocumentLink();
       cdl.LinkedEntityId      = docStoreId;
       cdl.ContentDocumentId   = cdList[i].Id;  
       cdl.shareType           = 'V';
       cdl.Visibility          = 'AllUsers'; 
       insertCDLList.add(cdl);
		}
		insert insertCDLList;
		Test.startTest();
		List<ContentDocumentLink> linkListTest = DUP_SingleFileController.deleteSingleDocumentAndRefreshList(cdList[0].Id, docStoreId);	
		Test.stopTest();
		System.assertEquals(false, linkListTest.isEmpty());
} 
*/
/**
* @description 	rejectSingleDocumentAndRefreshList test - asserting if there are any documents left in the array
* @param
* @return
*/   
@isTest static void rejectSingleDocumentTest(){
    Id newRequestTestId = [SELECT Id 
                           FROM DUP_Document_Request__c 
                           WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                           LIMIT 1].Id;
    
    List<DUP_Document_Store__c> docStore  = [SELECT Id,DUP_RejectComments_Available__c,
                                             DUP_Document_Status__c,DUP_Document_Request__c,DUP_Reject_Comments__c
                                             FROM DUP_Document_Store__c 
                                             WHERE DUP_Document_Request__c =: newRequestTestId
                                             LIMIT 1];
    
    List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
    for (Integer i = 0; i<1; i++) {
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId      = docStore[0].Id;
        cdl.ContentDocumentId   = cdList[i].Id;
        cdl.shareType           = 'V';
        cdl.Visibility          = 'AllUsers'; 
        insertCDLList.add(cdl);
    }
    insert insertCDLList;
    
    Test.startTest();
    Map<String,List<ContentDocumentLink>> linkListTest = DUP_SingleFileController.rejectSingleDocument(cdList[0].Id, docStore[0], 'Requested');	
    DUP_SingleFileController.updateDocStore(docStore[0]);
    Test.stopTest();
    System.assertEquals('Reviewed', docStore[0].DUP_Document_Status__c);
} 

/**
* @description 	approveSingleDocumentAndRefreshList test - asserting if the status changed from updated to reviewed
* @param
* @return
*/   
@isTest static void approveSingleDocumentTest(){
    Id newRequestTestId = [SELECT Id 
                           FROM DUP_Document_Request__c 
                           WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                           LIMIT 1].Id;
    
    List<DUP_Document_Store__c> docStore  = [SELECT Id,
                                             DUP_Document_Status__c
                                             FROM DUP_Document_Store__c 
                                             WHERE DUP_Document_Request__c =: newRequestTestId
                                             LIMIT 1];
    for (DUP_Document_Store__c dS : docStore){
        dS.DUP_Document_Status__c = 'Uploaded';
    }
    upsert docStore;
    
    List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
    for (Integer i = 0; i<1; i++) {
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId      = docStore[0].Id;
        cdl.ContentDocumentId   = cdList[i].Id;
        cdl.shareType           = 'V';
        cdl.Visibility          = 'AllUsers'; 
        insertCDLList.add(cdl);
    }
    insert insertCDLList;
    Test.startTest();
    DUP_SingleFileController.approveSingleDocument(cdList[0].Id, docStore[0], true);
    DUP_SingleFileController.updateDocStore(docStore[0]);
    Test.stopTest();
    System.assertEquals('Reviewed', docStore[0].DUP_Document_Status__c);             
}
    
    
 @isTest static void rejectandreq_SingleDocumentTest(){
    Id newRequestTestId = [SELECT Id 
                           FROM DUP_Document_Request__c 
                           WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                           LIMIT 1].Id;
    
    List<DUP_Document_Store__c> docStore  = [SELECT Id,DUP_RejectComments_Available__c,
                                             DUP_Document_Status__c,DUP_Document_Request__c,DUP_Reject_Comments__c
                                             FROM DUP_Document_Store__c 
                                             WHERE DUP_Document_Request__c =: newRequestTestId
                                             LIMIT 1];
    
    List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
    for (Integer i = 0; i<1; i++) {
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId      = docStore[0].Id;
        cdl.ContentDocumentId   = cdList[i].Id;
        cdl.shareType           = 'V';
        cdl.Visibility          = 'AllUsers'; 
        insertCDLList.add(cdl);
    }
    insert insertCDLList;
    for(DUP_Document_Store__c d :docStore)
     {
         d.DUP_Reject_Comments__c = 'Rejected and reuested again';
         d.DUP_RejectComments_Available__c=   true;
     }
    update docStore;    
    Test.startTest();
    DUP_Document_Store__c testDS =  DUP_SingleFileController.updateDocStore(docStore[0]);
     Map<String,List<ContentDocumentLink>> linkListTest = DUP_SingleFileController.rejectSingleDocument(cdList[0].Id, docStore[0], 'Requested');	
    Test.stopTest();
    System.assertEquals('Requested', testDS.DUP_Document_Status__c);
}   
}