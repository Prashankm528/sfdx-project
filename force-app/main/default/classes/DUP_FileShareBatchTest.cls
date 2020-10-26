/*****************************************************************************************
*       Date:        14/09/2020
*       Author:      Babul Jha
*       Description: test class for DUP_FileShareBatch
*****************************************************************************************/
@isTest
public class DUP_FileShareBatchTest {
    /**
    * @description 	creates data which is used it the other tests
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
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(2);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(2, entityList);
        for(DUP_Document_Request__c dr : newDocumentRequestList){
            dr.DUP_ICOSLEId__c = '2019';
        }
        insert newDocumentRequestList;
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                               newCounterpartyContactList, 1);
        for(DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c = 'Reviewed';
        }
        
        insert newDocumentStoreList;
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores2 = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores2.add(newDocumentRequestList[1]);
        List<DUP_Document_Store__c> newDocumentStoreList2 = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores2,
                                                                                                newCounterpartyContactList, 2);
        for(DUP_Document_Store__c dS : newDocumentStoreList2) {
            dS.DUP_Document_Status__c = 'Reviewed';
            ds.DUP_SharepointUrl__c = 'www.testurl.com';
        }
        
        insert newDocumentStoreList2;
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        newContentVersionList[0].DUP_Status__c = 'Approved';
        insert newContentVersionList;
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        for (Integer i = 0; i < newDocumentStoreList.size(); i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = newDocumentStoreList[i].Id;
            cdl.ContentDocumentId   = cdList[0].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
    }   
     /**
    * @description 	sendAllFileToSharePoint test
    * @param
    * @return
    */    
    @isTest static void sendAllFileToSharePointTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                                            LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BPI_SharePointAPIServiceHttpCalloutMock()); 
        DUP_ApprovedDocumentRequestController.sendAllFileToSharepoint(newRequestTestList[0].Id);
        Test.stopTest();
         List<DUP_Document_Store__c> newDocumentStoreList2 = [SELECT Id,
                                                            DUP_SharepointUrl__c
                                                            FROM DUP_Document_Store__c
                                                            WHERE DUP_Document_Request__c = :newRequestTestList[0].Id
                                                           ];
        System.assertEquals(null, newDocumentStoreList2[0].DUP_SharepointUrl__c);
        
    }
    
}