/***********************************************************************************************
* @author           Naglis Kazlauskas
* @date             1OCT2019
* @group            Digital@BP
* @description      testing class for DUP_CommunityMainViewController.apxc
* @updated			29OCT2019
************************************************************************************************/
@isTest
public class DUP_CommunityMainViewContrlTests {
    /**
    * @description 	creates data which is used in the later tests
    * @param
    * @return
    */
    @TestSetup
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> positiveUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert positiveUser;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(positiveUser);
        insert newCounterpartyContactList;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1,entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                               newCounterpartyContactList, 5);
        insert newDocumentStoreList;
    }
    /**
    * @description 	getDocumentStore positive test - gets document store where status is requested & correct user id
    * @param
    * @return
    */
    @isTest static void getDocumentStoreTestPositive(){
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        User positiveUser = [SELECT Id, 
                             Email
                             FROM User 
                             WHERE Email ='positive@controllertest.com' 
                            ];
        List<DUP_Document_Store__c> docReqStoreList = [SELECT DUP_Requested__c,
                                                       DUP_Document_Status__c,
                                                       DUP_Counterparty_Contact_Name__r.DUP_Email__c
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Document_Request__c  =: newDocumentRequest.Id];
        
        for (DUP_Document_Store__c dS : docReqStoreList){
            dS.DUP_Requested__c = true;
            dS.DUP_Document_Status__c = 'Requested';
            //dS.DUP_Document_Request__r.DUP_Status_Upload__c = 'DUP_Review_Upload';
            dS.DUP_Counterparty_Contact_Name__r.DUP_Email__c = positiveUser.Email;
        }
        update docReqStoreList;
        Test.startTest();
        List<DUP_Document_Store__c> documentList = DUP_CommunityMainViewController.getDocumentStore(newDocumentRequest.Name, positiveUser.id);  
        Test.stopTest();
        System.assertEquals(5, documentList.size());
    }
    /**
    * @description 	getDocumentStore negative test
    * @param
    * @return
    */
    @isTest static void getDocumentStoreTestNegative() {
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        User user = [SELECT Id, 
                     Email
                     FROM User 
                     WHERE Email ='positive@controllertest.com' 
                    ];
        
        Test.startTest();
        List<DUP_Document_Store__c> documentList = DUP_CommunityMainViewController.getDocumentStore(newDocumentRequest.Name, user.id);  
        Test.stopTest();
        System.assertEquals(0, documentList.size());
    }
    /**
    * @description 	deleteFiles positive test - deletes duplicate files
    * @param
    * @return
    */
    @isTest static void deleteFilesPositive(){
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        List<DUP_Document_Store__c> docReqStoreList = [SELECT Id
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Document_Request__c  =: newDocumentRequest.Id
                                                       LIMIT 1];
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(2);
        insert newContentVersionList; 
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        
        for (Integer i = 0; i < 2; i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docReqStoreList[0].Id;
            cdl.ContentDocumentId   = cdList[i].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
        Test.startTest();
        Boolean testPositive = DUP_CommunityMainViewController.deleteFiles(docReqStoreList[0].Id, insertCDLList[0].ContentDocumentId);
        Test.stopTest();
        List<ContentDocumentLink> contentDocumentListTEST = [SELECT ContentDocumentId
                                                             FROM ContentDocumentLink 
                                                             WHERE LinkedEntityId =: docReqStoreList[0].Id];
        System.assertEquals(1, contentDocumentListTEST.size());
        System.assertEquals(true, testPositive);
    }
    /**
    * @description 	deleteFiles negative test
    * @param
    * @return
    */
    @isTest static void deleteFilesNegative(){
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        List<DUP_Document_Store__c> docReqStoreList = [SELECT Id
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Document_Request__c  =: newDocumentRequest.Id
                                                       LIMIT 1];
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList; 
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        
        for (Integer i = 0; i < 1; i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docReqStoreList[0].Id;
            cdl.ContentDocumentId   = cdList[i].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
        Test.startTest();
        Boolean testNegative = DUP_CommunityMainViewController.deleteFiles(docReqStoreList[0].Id, insertCDLList[0].ContentDocumentId);
        Test.stopTest();
        List<ContentDocumentLink> contentDocumentListTEST = [SELECT ContentDocumentId
                                                             FROM ContentDocumentLink 
                                                             WHERE LinkedEntityId =: docReqStoreList[0].Id];
        System.assertEquals(1, contentDocumentListTEST.size());
        System.assertEquals(false, testNegative); 
    }
    /**
    * @description 	getFile positive test
    * @param
    * @return
    */
    @isTest static void getFilePositive(){
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        List<DUP_Document_Store__c> docReqStoreList = [SELECT Id
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Document_Request__c  =: newDocumentRequest.Id
                                                       LIMIT 1];
        
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList; 
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> insertCDLList = new List<ContentDocumentLink>();
        
        for (Integer i = 0; i < 1; i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId      = docReqStoreList[0].Id;
            cdl.ContentDocumentId   = cdList[i].Id;
            cdl.shareType           = 'V';
            cdl.Visibility          = 'AllUsers'; 
            insertCDLList.add(cdl);
        }
        insert insertCDLList;
        Test.startTest();
        List<ContentDocumentLink> contentDocumentList = DUP_CommunityMainViewController.getFile(docReqStoreList[0].Id);
        Test.stopTest();
        System.assertEquals(insertCDLList[0].ContentDocumentId, contentDocumentList[0].ContentDocumentId);  
    }
    /**
    * @description 	getFile Negative test
    * @param
    * @return
    */ 
    @isTest static void getFileNegative(){
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        List<DUP_Document_Store__c> docReqStoreList = [SELECT Id
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Document_Request__c  =: newDocumentRequest.Id
                                                       LIMIT 1];
        
        Test.startTest();
        try {
            List<ContentDocumentLink> contentDocumentList = DUP_CommunityMainViewController.getFile(docReqStoreList[0].Id);
        } catch (DMLException  e) {
            System.assertEquals(e.getTypeName(), 'NullPointerException ');
        }        
        Test.stopTest();
        
    }
    /**
    * @description 	deleteSingleDocumentTest - deletes a single document
    * @param
    * @return
    */
    @isTest static void deleteSingleDocumentTest(){
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList; 
        List<ContentDocument> cDListBefore = [SELECT Id
                                              FROM ContentDocument
                                              WHERE Title =: newContentVersionList[0].Title];
        Test.startTest();
        DUP_CommunityMainViewController.deleteSingleDocument(cDListBefore[0].Id);
        Test.stopTest();
        List<ContentDocument> cDListAfter = [SELECT Id
                                             FROM ContentDocument
                                             WHERE Title =: newContentVersionList[0].Title];
        System.assertEquals(0, cDListAfter.size());
    }
    
    /**
    * @description 	deleteSingleDocumentTest - deletes multiple documents
    * @param
    * @return
    */
    @isTest static void deleteInvalidDocumentTest(){
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList; 
        List<ContentDocument> cDListBefore = [SELECT Id
                                              FROM ContentDocument
                                              WHERE Title =: newContentVersionList[0].Title];
        List<Id> temp = new List<Id>();
        temp.add(cDListBefore[0].id);
        Test.startTest();
        DUP_CommunityMainViewController.deleteInvalidDocument(JSON.serialize(temp));
        Test.stopTest();
        List<ContentDocument> cDListAfter = [SELECT Id
                                             FROM ContentDocument
                                             WHERE Title =: newContentVersionList[0].Title];
        System.assertEquals(0, cDListAfter.size());
    }
    /**
    * @description 	uploadDocStoreStatus test - uploads document stores & asserts if the status is Uploaded
    * @param
    * @return
    */ 
    @isTest static void uploadDocStoreStatusTest() {
        DUP_Document_Request__c newDocumentRequest = [SELECT Name, Id, DUP_Requestor_emails__c,DUP_Email_Templates__c
                                                      FROM DUP_Document_Request__c 
                                                      WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                      LIMIT 1];
        List<DUP_Document_Store__c> docReqStoreList = [SELECT Id,
                                                       DUP_Document_Request__c, DUP_Document_Request__r.DUP_doc_submitted_status__c,DUP_RejectComments_Available__c
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Document_Request__c  =: newDocumentRequest.Id
                                                       LIMIT 5];   
        Test.startTest();
        newDocumentRequest.DUP_Requestor_emails__c = 'test.test@bp.com;test.test1@wipro.com';
        try{
        update newDocumentRequest;
        }
        catch(Exception e){
            newDocumentRequest.DUP_Email_Templates__c = 'Additional Info Review Request Template';
            newDocumentRequest.DUP_Requestor_emails__c = 'test.test@bp.com,test.test1@bp.com';
            update newDocumentRequest;
        }
        DUP_CommunityMainViewController.uploadDocStoreStatus(docReqStoreList);
        Test.stopTest();
        List<DUP_Document_Store__c> docReqStoreListTest = [SELECT DUP_Document_Status__c
                                                           FROM DUP_Document_Store__c
                                                           WHERE DUP_Document_Request__c  =: newDocumentRequest.Id
                                                           LIMIT 5];  
        
        for (DUP_Document_Store__c store : docReqStoreListTest){
            System.assertEquals('Uploaded', store.DUP_Document_Status__c); 
        } 
    }
    /**
    * @description 	shareFileWithAgent test
    * @param
    * @return
    */ 
    @isTest static void shareFileWithAgentPositive(){
        List<ContentVersion> newContentVersionList = DUP_DataFactory.createContentVersion(1);
        insert newContentVersionList;
        Id newRequestTestId = [SELECT Id 
                               FROM DUP_Document_Request__c 
                               WHERE DUP_CounterParty_Name__c ='ControlerTest0'
                               LIMIT 1].Id;
        
        List<DUP_Document_Store__c> docStore  = [SELECT Id,
                                                 DUP_Document_Status__c
                                                 FROM DUP_Document_Store__c 
                                                 WHERE DUP_Document_Request__c =: newRequestTestId
                                                 LIMIT 1];
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
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
        
        DUP_FileList fListinstance = new DUP_FileList();
        fListinstance.name = cdList[0].Title;
        fListinstance.documentId = cdList[0].Id;
        List<DUP_FileList> fileList = new List<DUP_FileList>();
        fileList.add(fListinstance);
        String fileListJSON = JSON.serialize(fileList);

        DUP_CommunityMainViewController.shareFileWithAgent(docStore[0].Id, fileListJSON);
        DUP_CommunityMainViewController.getUploadedFile(docStore[0].Id);
        DUP_CommunityMainViewController.saveComments(docStore[0].Id,'test comments');
        DUP_CommunityMainViewController.getLoggedInUser();
        Test.stopTest();
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :docStore[0].Id AND ContentDocumentId =: cdList[0].Id];
        System.assertEquals('I', contentDocumentLinkList[0].ShareType);
    }
}