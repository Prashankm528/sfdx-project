/*****************************************************************************************
*       Date:        14OCT2019
*       Author:      Naglis Jonas Kazlauskas - IBM
*       Description: test class for DUP_RequestDocumentController
*****************************************************************************************/
@isTest
public class DUP_RequestDocumentControllerTests {  
    /**
    * @description 	DUP_RequestDocumentController test with existing user
    * @param
    * @return
    */
    @isTest static void testVisualForceEmailComponent(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> positiveUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert positiveUser;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(positiveUser);
        insert newCounterpartyContactList;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               newCounterpartyContactList, 5);
        newDocumentStoreList[0].DUP_Certified_True_Copy__c = true;
        newDocumentStoreList[0].DUP_Document_Name__c ='Pupulis & Kukulis';
        insert newDocumentStoreList;
        
        Test.startTest();
        DUP_RequestDocumentController obj = new DUP_RequestDocumentController();
        obj.RecordId = positiveUser[0].Id;
        obj.RequestId = newDocumentRequestList[0].Id;
        List<DUP_Document_Store__c> docStoreList = obj.getDocumentStoresList();
        Test.stopTest();
        System.assertEquals(5, docStoreList.size());
        
    }
    /**
    * @description 	DUP_RequestDocumentController test with contact 
    * @param
    * @return
    */
    @isTest static void testVisualForceEmailComponentContact(){
        
        Contact c = new Contact(LastName ='Pupulis');
        insert c;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        Test.startTest();
        DUP_RequestDocumentController obj = new DUP_RequestDocumentController();
        obj.RecordId = c.Id;
        obj.RequestId = newDocumentRequestList[0].Id;
        obj.getDocumentStoresList();
        obj.getBooleanValue();
        Test.stopTest();
        System.assertEquals(c.Id,obj.RecordId);
    }
}