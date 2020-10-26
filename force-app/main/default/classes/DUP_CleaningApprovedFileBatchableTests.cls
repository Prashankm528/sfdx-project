/*****************************************************************************************
*       Date:        22OCT2019
*       Author:      Naglis Kazlauskas - IBM
*       Description: test class for DUP_CleaningApprovedFileBatchable.apxc 
*****************************************************************************************/
@isTest
public class DUP_CleaningApprovedFileBatchableTests {
    /**
    * @description 	creates data which is used in the later tests
    * @param
    * @return
    */
    @testSetup
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;	
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(newUser);
        insert newCounterpartyContactList;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        newDocumentRequestList[0].DUP_ApprovedDate__c = Date.today();
        insert newDocumentRequestList;
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                               newCounterpartyContactList, 20);
        for(DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c = 'Reviewed';
        }
        
        insert newDocumentStoreList;
    }
    /**
    * @description 	positive test for batch execution
    * @param
    * @return
    */
    @isTest static void executionTestPositive(){
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(20);
        for (ContentVersion cv : newContentVersionList) {
            cv.DUP_Status__c = 'Rejected';
        }
        insert newContentVersionList;
        
        Id docReqId = [SELECT Id
                       FROM DUP_Document_Request__c
                       WHERE DUP_CounterParty_Name__c =: 'ControlerTest0'].Id;
        
        List<DUP_Document_Store__c> docStoreList  = [SELECT Id
                                                     FROM DUP_Document_Store__c 
                                                     WHERE DUP_Document_Request__c =: docReqId
                                                     LIMIT 20];
        Set<Id> docStoreIds = new Set<Id>();
        for(DUP_Document_Store__c dS : docStoreList){
            docStoreIds.add(dS.Id);
        }
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 20];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i < docStoreList.size(); i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docStoreList[i].Id;
            cdl.ContentDocumentId   = cdList[i].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers';
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
                
        List<ContentDocumentLink > contentDocumentListBefore = [SELECT ContentDocumentId,
                                                                ContentDocument.LatestPublishedVersion.DUP_Status__c
                                                                FROM ContentDocumentLink 
                                                                WHERE LinkedEntityId IN :docStoreIds
                                                               ];
        upsert contentDocumentListBefore;
               
        Test.startTest();
        DUP_CleaningApprovedFileBatchable testBatch = new DUP_CleaningApprovedFileBatchable();
        Id batchId = Database.executeBatch(testBatch);
        Test.stopTest();
        List<ContentDocumentLink > contentDocumentListAfter = [SELECT Id
                                                               FROM ContentDocumentLink 
                                                               WHERE LinkedEntityId IN :docStoreIds
                                                              ];
		System.assertEquals(20, contentDocumentListBefore.size());
		System.assertEquals(0, contentDocumentListAfter.size());        
    }
}