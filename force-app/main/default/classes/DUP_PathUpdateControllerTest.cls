/*****************************************************************************************
*       Date:           12MAR2020
*       Author:         Babul Jha - Wipro
*       Description:    Test class for DUP_PathUpdateController.apxc
*****************************************************************************************/

@isTest
public class DUP_PathUpdateControllerTest {
    /**
    * @description 	creates data which is used in the later tests
    * @param
    * @return
    */
    @TestSetup 
    static void TestSetup(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(2);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequestConfirmStage(2, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(newUser);
        insert newCounterpartyContactList;
        
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
    * @description  positive getStatus
    * @param
    * @return
    */
    @isTest static void getStatusPositive(){
         DUP_Document_Request__c newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        DUP_Document_Store__c newDocumentStore = [SELECT Id FROM DUP_Document_Store__c LIMIT 1];
        Test.startTest();
        String documentstatus = DUP_PathUpdateController.getStatus(newRequestTest.Id);
        String documentstore = DUP_PathUpdateController.getSelectedocumentStore(newRequestTest.Id);
        List<ContentDocumentLink> contentDocument = DUP_PathUpdateController.getFile(newDocumentStore.Id);
        Test.stopTest();
        System.assertEquals(newRequestTest.DUP_Status_Upload__c, documentstatus);
    }
    @isTest static void updateDocReqStageTest(){
         DUP_Document_Request__c newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        newRequestTest.DUP_Email_Templates__c ='Additional Info Request Template';
        update newRequestTest;
        DUP_PathUpdateController.getSelectedocumentStore(newRequestTest.id);
        
        newRequestTest.DUP_Email_Templates__c ='Review Template';
        update newRequestTest;
        DUP_PathUpdateController.getSelectedocumentStore(newRequestTest.id);

        Test.startTest();
        String documentstore = DUP_PathUpdateController.updateDocReqStage(newRequestTest.Id,newRequestTest.DUP_Status_Upload__c, false);
        newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        Test.stopTest();
        System.assertEquals(newRequestTest.DUP_Status_Upload__c, 'DUP_Review_Upload');
    }
}