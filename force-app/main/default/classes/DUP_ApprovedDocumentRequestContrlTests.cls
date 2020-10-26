/*****************************************************************************************
*       Date:        22OCT2019
*       Author:      Naglis Kazlauskas - IBM
*       Description: test class for DUP_ApprovedDocumentRequestController
*****************************************************************************************/
@isTest
public class DUP_ApprovedDocumentRequestContrlTests {
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
    * @description 	getDocumentStore test - passes document request list and retrieves assigned stores
    * @param
    * @return
    */
    @isTest static void getDocumentStoreTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                                            LIMIT 1];
        Test.startTest();
        List<DUP_Document_Store__c> testList = DUP_ApprovedDocumentRequestController.getDocumentStore(newRequestTestList[0].Id);
        Test.stopTest();
        System.assertEquals(1, testList.size());
    }
    /**
    * @description 	sendFileToSharePoint test
    * @param
    * @return
    */    
    @isTest static void sendFileToSharePointTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newRequestStoresList = [SELECT DUP_Document_Request__c
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id];    
        
        List<ContentDocument> cdList = [SELECT Id FROM ContentDocument LIMIT 1];
        Test.startTest();
        DUP_ApprovedDocumentRequestController.LoadDataWrapper myWrap = DUP_ApprovedDocumentRequestController.sendFileToSharepoint(newRequestStoresList[0], 
                                                                                                                                  cdList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, myWrap);
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
    /**
    * @description 	processResponse positive test - receives status 200 and updates sharepoint link on store
    * @param
    * @return
    */
    @isTest static void processResponseTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newDocumentStoreList = [SELECT Id,
                                                            DUP_SharepointUrl__c
                                                            FROM DUP_Document_Store__c
                                                            WHERE DUP_Document_Request__c = :newRequestTestList[0].Id
                                                            ];

        Set<Id> linkedEntityIds = new Set<Id>();
        for(DUP_Document_Store__c dS : newDocumentStoreList){
            linkedEntityIds.add(dS.Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BPI_SharePointAPIServiceHttpCalloutMock()); 
        BPI_SharepointAPIService newCall = BPI_SharepointAPIService.init('baseFolderListValue', 'subFolderValue');
        Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse = newCall.pushFilesToSharepoint(linkedEntityIds);
        Set<Id> testSet= mapResponse.keyset();
        Map<Id,DUP_Document_Store__c> idDocStoreMap = new Map<Id,DUP_Document_Store__c>();
        Integer i = 0;
        for (Id myId: testSet) {
            idDocStoreMap.put(myId, newDocumentStoreList[i]);
            i = i+1;
        }
      	 DUP_ApprovedDocumentRequestController.processResponse(idDocStoreMap, mapResponse);
        Test.stopTest(); 
        List<DUP_Document_Store__c> newDocumentStoreList2 = [SELECT Id,
                                                            DUP_SharepointUrl__c
                                                            FROM DUP_Document_Store__c
                                                            WHERE DUP_Document_Request__c = :newRequestTestList[0].Id
                                                           ];
        System.assertNotEquals(null, newDocumentStoreList2[0].DUP_SharepointUrl__c);
        
        
    }
    /**
    * @description 	processResponse negative test - receives status error and updates sharepoint error field
    * @param
    * @return
    */
    @isTest static void processResponseTestNegative(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newDocumentStoreList = [SELECT Id,
                                                            DUP_SharepointUrl__c
                                                            FROM DUP_Document_Store__c
                                                            WHERE DUP_Document_Request__c = :newRequestTestList[0].Id
                                                            ];              
        Set<Id> linkedEntityIds = new Set<Id>();
        for(DUP_Document_Store__c dS : newDocumentStoreList){
            linkedEntityIds.add(dS.Id);
        }
        List<ContentVersion> cdListBeforeTest = [SELECT DUP_SharepointError__c  
                                                FROM ContentVersion
                                                WHERE DUP_Status__c = 'Approved'
                                               ];   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BPI_SharepointAPIServcHttpCalloutMockNeg()); 
        BPI_SharepointAPIService newCall = BPI_SharepointAPIService.init('baseFolderListValue', 'subFolderValue');
        Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse = newCall.pushFilesToSharepoint(linkedEntityIds);
        Set<Id> testSet= mapResponse.keyset();
        Map<Id,DUP_Document_Store__c> idDocStoreMap = new Map<Id,DUP_Document_Store__c>();
        Integer i = 0;
        for (Id myId: testSet) {
            idDocStoreMap.put(myId, newDocumentStoreList[i]);
            i = i+1;
        }
        DUP_ApprovedDocumentRequestController.processResponse(idDocStoreMap, mapResponse); 
        Test.stopTest(); 
		List<ContentVersion> cdListAfterTest = [SELECT DUP_SharepointError__c  
                                                 FROM ContentVersion
                                                WHERE DUP_Status__c = 'Approved'
                                                ];   
        System.assertNotEquals(null, cdListAfterTest[0].DUP_SharepointError__c);
        System.assertEquals(null, cdListBeforeTest[0].DUP_SharepointError__c);
    }
    /**
    * @description 	getFile positive test - passes a store and retrieves a file attached to it
    * @param
    * @return
    */    
    @isTest static void getFilePositiveTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newRequestStoresList = [SELECT Id
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id
                                                           ];
        
        Test.startTest();
        DUP_ApprovedDocumentRequestController.LoadDataWrapper myWrapper = new DUP_ApprovedDocumentRequestController.LoadDataWrapper();
        DUP_ApprovedDocumentRequestController.LoadDataWrapper myWrapperTest = DUP_ApprovedDocumentRequestController.getFile(newRequestStoresList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, myWrapperTest);
    }
    /**
    * @description 	getFile negative test
    * @param
    * @return
    */    
    @isTest static void getFileNegativeTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest1'
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newRequestStoresList = [SELECT Id
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id];    
        Test.startTest();
        DUP_ApprovedDocumentRequestController.LoadDataWrapper myWrapper = new DUP_ApprovedDocumentRequestController.LoadDataWrapper();
        DUP_ApprovedDocumentRequestController.LoadDataWrapper myWrapperTest = DUP_ApprovedDocumentRequestController.getFile(newRequestStoresList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, myWrapperTest);
    }  
    /**
    * @description 	updateSharepointFieldTest positive test
    * @param
    * @return
    */  
    @isTest static void updateSharepointFieldTest(){
        Id newRequestTestId = [SELECT Id 
                               FROM DUP_Document_Request__c 
                               WHERE DUP_CounterParty_Name__c ='ControlerTest1'
                               LIMIT 1].Id;
        
        DUP_Document_Request__c currentRecord = [SELECT DUP_Sharepoint_Success__c 
                                                 FROM DUP_Document_Request__c
                                                 WHERE Id = :newRequestTestId];
                
        Test.startTest();
        DUP_ApprovedDocumentRequestController.updateSharepointField(newRequestTestId);
        Test.stopTest();
        
        DUP_Document_Request__c currentRecord2 = [SELECT DUP_Sharepoint_Success__c 
                                                 FROM DUP_Document_Request__c
                                                 WHERE Id = :newRequestTestId];

        System.assertEquals(false, currentRecord.DUP_Sharepoint_Success__c);
        System.assertEquals(true, currentRecord2.DUP_Sharepoint_Success__c);
    }
}