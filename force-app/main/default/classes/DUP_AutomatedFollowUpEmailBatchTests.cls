/*****************************************************************************************
*       Date:        22OCT2019
*       Author:      Naglis Kazlauskas - IBM
*       Description: test class for DUP_AutomatedFollowUpEmailBatch.cls
*       Updated:     7JAN20 Arron Kukadia
*****************************************************************************************/
@isTest
public class DUP_AutomatedFollowUpEmailBatchTests {
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
        insert newDocumentRequestList;
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                               newCounterpartyContactList, 5);
        for(DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c = 'Requested';
        }
        
        insert newDocumentStoreList;
        Datetime sometime = Datetime.now().addDays(-25);
        Test.setCreatedDate(newUser[0].Id, sometime);
    }
    /**
    * @description 	test for batch execution
    * @param
    * @return
    */
    @isTest static void executionTest(){        
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        DUP_AutomatedFollowUpEmailBatch testBatch = new DUP_AutomatedFollowUpEmailBatch();
        Id batchId = Database.executeBatch(testBatch);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        Integer testInvocations = DUP_AutomatedFollowUpEmailBatch.emailLimits;
        //System.assertNotEquals(invocationsPreTest, testInvocations);
    }
}