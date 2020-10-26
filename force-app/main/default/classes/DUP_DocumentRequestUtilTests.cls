/*****************************************************************************************
*       Date:        14OCT2019
*       Author:      Naglis Jonas Kazlauskas - IBM
*       Description: test class for DUP_DocumentRequestUtil
*       Updated: 	 7Jan20 Arron Kukadia
*****************************************************************************************/
@isTest
public class DUP_DocumentRequestUtilTests {   
     /**
    * @description 	creates data which is used it the other tests
    * @param
    * @return
    */
    @TestSetup
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(newUser);
        insert newCounterpartyContactList;
        
        List<DUP_List_Of_Values__c> newlovList =  DUP_DataFactory.createListOfValues(5);
        insert newlovList;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
        documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                               newCounterpartyContactList, 5);
        insert newDocumentStoreList;
        
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'DUP_Super_User_Access'].Id;
        List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment 
                                        WHERE PermissionSetId = :permissionSetId
                                            AND AssigneeId = :UserInfo.getUserId() ];
        if(permissionSetAssignmentList.isEmpty()){
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permissionSetId, AssigneeId = UserInfo.getUserId());
            try {
                insert psa;
            } catch (DmlException e) {
                System.debug('An Error has occurred while inserting a new PermissionSet Assignment: '+ e.getMessage());
            }
        }       
    }
    /**
    * @description 	createDocumentStores test: tests if document stores are created for the relevant request
    * @param
    * @return
    */
    @isTest static void createDocumentStoresTest(){
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        Test.startTest();
        DUP_DocumentRequestUtil.createDocumentStores(newDocumentRequestList);
        Test.stopTest();
        List<DUP_Document_Store__c> docStoreList = [SELECT DUP_Document_Name__c
                                                    FROM DUP_Document_Store__c
                                                    WHERE DUP_Document_Request__c =: newDocumentRequestList[0].Id];
        System.assertEquals(5, docStoreList.size());                         
    }
    /**
    * @description 	sendEmailToCounterParty test - test the functionality of sending a request 
    * email to counter party which already has a user registered
    * @param
    * @return
    */
    @isTest static void sendEmailToCounterPartyTestRequestTemplate(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newRequestStoresList = [SELECT Id,
                                                            DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                            DUP_Document_Request__c
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id];        
        
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        Id emailtempID = [SELECT Id FROM EmailTemplate Where DeveloperName = 'DUP_AddInfo_VF_Template'].Id;
        DUP_DocumentRequestUtil.sendEmailToCounterParty(newRequestTestList,emailtempID,newRequestStoresList, true);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertNotEquals(invocationsPreTest, invocations);
    }
    /**
    * @description 	createDocumentStores tests: email sending fucntionality of a counter party which is not registered to the portal
    * @param
    * @return
    */
    @isTest static void sendEmailToCounterPartyTestRegistrationTemplate(){
        
        Account contactsAccount = new Account();
        contactsAccount.Name = 'ContactAccount';
        contactsAccount.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DUP_Misc').getRecordTypeId();
        insert contactsAccount;
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Counterparty_Contact__c> newCCList = new List<DUP_Counterparty_Contact__c>();           
        DUP_Counterparty_Contact__c ccContact = new DUP_Counterparty_Contact__c(Name ='pupulis', DUP_Email__c  = 'SmallUniquepupulis@kukulis.com');
        newCCList.add(ccContact);
        insert newCCList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               newCCList, 5);
        System.debug('Size of newDocStoreList: ' +newDocumentStoreList.size());
        for (DUP_Document_Store__c dS : newDocumentStoreList){
            dS.DUP_Document_Status__c = 'Requested';
        }
        insert newDocumentStoreList;
        
        List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                                                       DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                       DUP_Document_Request__c
                                                       FROM DUP_Document_Store__c
                                                       WHERE DUP_Requested__c = true
                                                       AND DUP_Document_Status__c != 'Uploaded'
                                                       AND DUP_Document_Status__c != 'Reviewed'
                                                       AND DUP_Document_Request__c IN :newDocumentRequestList
                                                      ];        

        Id registrationEmailTemplateId = [SELECT Id 
                                          FROM EmailTemplate
                                          WHERE DeveloperName ='DUP_Registration_VF_Template'].Id;       
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        Integer invocations;
        try {
            
            DUP_DocumentRequestUtil.sendEmailToCounterParty(newDocumentRequestList,registrationEmailTemplateId,docStoreRecords, true);
        	invocations = Limits.getEmailInvocations();
        } catch (ListException e) {
        	System.debug('UtilTest error: ' + e);
        }      
        Test.stopTest();
        
        System.assertNotEquals(invocationsPreTest, invocations);

                                                                
    }

    /**
    * @description  sendReminderEmailToCounterParty test - sends a reminder email to a counterparty after 14 days from now
    * @param
    * @return
    */    
    @isTest static void sendReminderEmailToCounterPartyTest(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newRequestStoresList = [SELECT Id,
                                                            DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                            DUP_Document_Request__c
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id];
        
        User currentUser = [SELECT Id
                            FROM User
                            WHERE Email = 'positive@controllertest.com']; 
        
        Datetime sometime = Datetime.now().addDays(-14);
        Integer offset = UserInfo.getTimezone().getOffset(sometime);
        Datetime local = sometime.addSeconds(offset/1000);

        Test.setCreatedDate(currentUser.Id, local);
        
        Set<Id> docReqSet = new Set<Id>();
        for(DUP_Document_Request__c dR : newRequestTestList){
            docReqSet.add(dR.Id);
        }
        Id emailTemplateId1 = [SELECT Id FROM EmailTemplate Where DeveloperName = 'DUP_Request_VF_Template'].Id;
        
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        DUP_DocumentRequestUtil.sendReminderEmailToCounterParty(docReqSet, emailTemplateId1, newRequestStoresList);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest(); 
        
        System.assertEquals(invocationsPreTest, invocations);


        
    }
    /**
    * @description  sendReminderEmailToCounterParty test with a different date - sends a reminder email with 25 days left to upload documents
    * @param
    * @return
    */   
    @isTest static void sendReminderEmailToCounterPartyTestDifferentDate(){
        List<DUP_Document_Request__c> newRequestTestList = [SELECT Id 
                                                            FROM DUP_Document_Request__c 
                                                            WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                            LIMIT 1];
        
        List<DUP_Document_Store__c> newRequestStoresList = [SELECT Id,
                                                            DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                            DUP_Document_Request__c
                                                            FROM DUP_Document_Store__c 
                                                            WHERE DUP_Document_Request__c =: newRequestTestList[0].Id];
        
        Id emailTemplateId1 = [SELECT Id FROM EmailTemplate Where DeveloperName = 'DUP_Request_VF_Template'].Id;
        Id emailTemplateId2 = [SELECT Id FROM EmailTemplate Where DeveloperName = 'DUP_Request_VF_Template'].Id;
        
        User currentUser = [SELECT Id
                            FROM User
                            WHERE Email = 'positive@controllertest.com']; 
        
        Datetime sometime = Datetime.now().addDays(-25);
        Integer offset = UserInfo.getTimezone().getOffset(sometime);
        Datetime local = sometime.addSeconds(offset/1000);

        Test.setCreatedDate(currentUser.Id, local);
        
        Set<Id> docReqSet = new Set<Id>();
        for(DUP_Document_Request__c dR : newRequestTestList){
            docReqSet.add(dR.Id);
        }
        Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        DUP_DocumentRequestUtil.sendReminderEmailToCounterParty(docReqSet, emailTemplateId1, newRequestStoresList);
        DUP_DocumentRequestUtil.sendEmailOnException('Test Error');
	Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertNotEquals(invocationsPreTest, invocations);

        
    }
}