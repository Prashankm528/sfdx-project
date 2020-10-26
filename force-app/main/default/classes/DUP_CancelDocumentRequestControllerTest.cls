/*****************************************************************************************
*       Date:           19MAR2020
*       Author:         Wipro
*       Description:    Test class for DUP_CancelDocumentRequestControllerTest.apxc
*****************************************************************************************/

@isTest
public class DUP_CancelDocumentRequestControllerTest {
    /**
    * @description  creates data which is used in the later tests
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
    * @description  test method for getStatus method
    **/
    @isTest static void getStatusTest(){
         DUP_Document_Request__c newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        DUP_Document_Store__c newDocumentStore = [SELECT Id FROM DUP_Document_Store__c LIMIT 1];
        Test.startTest();
        String documentstatus = DUP_CancelDocumentRequestController.getStatus(newRequestTest.Id);
        Test.stopTest();
        System.assertEquals(newRequestTest.DUP_Status_Upload__c, documentstatus);
    }
    
    /**
    * @description  test method for cancelRequest method
    **/
    @isTest static void cancelRequestTest(){
         DUP_Document_Request__c newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        Test.startTest();
        if(newRequestTest != null){
            try{
                DUP_CancelDocumentRequestController.cancelRequest(newRequestTest.Id);

                newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
                System.assertEquals(newRequestTest.DUP_Status_Upload__c, 'DUP_Cancelled');
            }catch(Exception ex){
                System.debug('Script-thrown exception - '+ex.getMessage());
            }
        }
        Test.stopTest();
        
    }
    /**
    * @description  test method for cancelRequest method exception scenario
    **/
    @isTest static void cancelRequestExceptionTest(){
         Id docReqId = [Select Id from DUP_BP_Entity_Details__c limit 1].Id;
        
        Test.startTest();
            try{
                DUP_CancelDocumentRequestController.cancelRequest(docReqId);
            }catch(Exception ex){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
        Test.stopTest();
        
    }
}