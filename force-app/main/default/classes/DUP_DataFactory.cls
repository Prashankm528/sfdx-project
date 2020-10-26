/*****************************************************************************************
*       Date:           10OCT2019
*       Author:         Naglis Jonas Kazlauskas - IBM
*       Description:    Data factory for DUP test classes
*****************************************************************************************/
@isTest
public class DUP_DataFactory {
    public static List<DUP_Document_Request__c> createDocumentRequest(Integer numberOfRequests, List<DUP_BP_Entity_Details__c> entityList){
        List<DUP_Document_Request__c> newRequestList = new List<DUP_Document_Request__c>();
        for (Integer i = 0; i < numberOfRequests; i ++) {
            DUP_Document_Request__c newRequest = New DUP_Document_Request__c();
            newRequest.DUP_CounterParty_Name__c =('ControlerTest' + i);
        	newRequest.DUP_Status_Upload__c     = 'DUP_New_Request';
            newRequest.DUP_Email_Templates__c = 'New / Existing Counterparty Template';
            newRequest.DUP_BP_Entity_Details__c = entityList[i].Id;
            newRequest.DUP_Risk_Status__c = 'Low';
            newRequest.DUP_ICOSId__c = '000000' + i;
            newRequest.DUP_Status_Upload__c='DUP_Review_Upload';
            newRequest.DUP_Requestor_Emails__c = 'email'+i+'@bp.com,email@uk.bp.com';
        	newRequestList.add(newRequest);
        }
        return newRequestList;
    }
    
    public static List<DUP_Document_Request__c> createDocumentRequestConfirmStage(Integer numberOfRequests, List<DUP_BP_Entity_Details__c> entityList){
        List<DUP_Document_Request__c> newRequestList = new List<DUP_Document_Request__c>();
        for (Integer i = 0; i < numberOfRequests; i ++) {
            DUP_Document_Request__c newRequest = New DUP_Document_Request__c();
            newRequest.DUP_CounterParty_Name__c =('ControlerTest' + i);
        	newRequest.DUP_Status_Upload__c     = 'DUP_New_Request';
            newRequest.DUP_Email_Templates__c = 'New / Existing Counterparty Template';
            newRequest.DUP_BP_Entity_Details__c = entityList[i].Id;
            newRequest.DUP_Risk_Status__c = 'Low';
            newRequest.DUP_ICOSId__c = '000000' + i;
            newRequest.DUP_Status_Upload__c='DUP_Confirm_Details';
        	newRequestList.add(newRequest);
        }
        return newRequestList;
    }
    
    public static List<DUP_BP_Entity_Details__c> createBPEntity(Integer numberOfEntities){
        List<DUP_BP_Entity_Details__c> newEntityList = new List<DUP_BP_Entity_Details__c>();
            for (Integer i = 0; i < numberOfEntities; i ++) {
            DUP_BP_Entity_Details__c newEntity = New DUP_BP_Entity_Details__c();
            newEntity.Name  =('ControlerEntity' + i);
        	newEntity.DUP_Email_Footer__c = 'New Entity Test';
            newEntity.DUP_Return_Email__c = 'test@bp.com';
        	newEntityList.add(newEntity);
        }
        return newEntityList;
    }
    
    public static List<Contact> createContact(Integer numberOfContacts, String lastName) {
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < numberOfContacts; i++){
            Contact newContact = new Contact(lastName = lastName);
            contactList.add(newContact);
        }
        return contactList;
    }
    
    public static List<User> createUser(Integer numberOfUsers, Profile pf, String emailInput){ 
        
       List<User> users = new List<User>(); 
        for (Integer i = 0; i < numberOfUsers; i ++) {
            User PositiveUserTester = new User(alias = 'hasrole', email=emailInput,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = pf.Id, 
                                    timezonesidkey='America/Los_Angeles', username=emailInput,
                                    NTID__c =i+'ntidet'+emailInput);
            users.add(PositiveUserTester);
        }
        return users;
    }
    
    @future
    public static void assignPermissionSet(Id userId, Id permissionSetId){  
       	PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSetId);
		insert psa;
    }
    
    public static List<DUP_Counterparty_Contact__c> createCounterPartyContact(List<User> users){
        List<DUP_Counterparty_Contact__c> ccList = new  List<DUP_Counterparty_Contact__c>();
        if(!users.isEmpty()){
           for(User u: users) {
            DUP_Counterparty_Contact__c newCounterPartyContact = new DUP_Counterparty_Contact__c();
            newCounterPartyContact.CreatedById           = u.id;
            newCounterPartyContact.CurrencyIsoCode       = '';
            newCounterPartyContact.LastModifiedById      = u.id;
            newCounterPartyContact.OwnerId               = u.id;
            newCounterPartyContact.DUP_Email__c          = u.Email;
            newCounterPartyContact.DUP_CounterParty_Name__c ='PositiveControlerTest';
            ccList.add(newCounterPartyContact);
           }  
        }
        return ccList;
    }
    
    public static List<DUP_Document_Store__c> createDocumentStore(List<DUP_Document_Request__c> documentRequestList, List<DUP_Counterparty_Contact__c> counterPartyList,Integer DocumentStoreAmount) {
        List<DUP_Document_Store__c> documentStoreList = new List<DUP_Document_Store__c>();
        if(DocumentStoreAmount == 0) {
            for (DUP_Document_Request__c dr : documentRequestList) {
                for(DUP_Counterparty_Contact__c cc : counterPartyList) {
                   DUP_Document_Store__c newStore = new DUP_Document_Store__c();
                   newStore.DUP_Options__c = 'Optional';
                   newStore.DUP_Document_Request__c = dr.id;
                   newStore.DUP_Document_Status__c = 'Created';
                   newStore.DUP_Requested__c = true;
                   newStore.DUP_Counterparty_Contact_Name__c = cc.id;
                   documentStoreList.add(newStore);
                }
            }  
        } else if (DocumentStoreAmount > 0) {
            for (DUP_Document_Request__c dr1 : documentRequestList) {
                for (Integer i=0; i <DocumentStoreAmount; i++ ){
                   DUP_Document_Store__c newStore = new DUP_Document_Store__c();
                   newStore.DUP_Options__c = 'Optional';
                   newStore.DUP_Document_Request__c = dr1.id;
                   newStore.DUP_Document_Status__c = 'Created';
                   newStore.DUP_Requested__c = true;
                   newStore.DUP_Counterparty_Contact_Name__c = counterPartyList[0].id;
                   documentStoreList.add(newStore);  
                }
            }
        }                                                                                                           
        return documentStoreList;
    }
    public static List<ContentVersion> createContentVersion(Integer numberOfContentVersions){
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        for (Integer i = 0; i<numberOfContentVersions; i++) {
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Tester',
                PathOnClient = 'Tester.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            contentVersionList.add(contentVersion);
       }
       return contentVersionList;  
    }
    
    public static List<DUP_List_Of_Values__c> createListOfValues(Integer numberOfLOVs){
        List<DUP_List_Of_Values__c> lovList = new  List<DUP_List_Of_Values__c>();
        for (Integer i = 0; i<numberOfLOVs; i++){
            DUP_List_Of_Values__c LoVObject = new DUP_List_Of_Values__c();
            LoVObject.DUP_Options__c  = 'Mandatory';
            LoVObject.DUP_Quantity__c = 1;
            LoVObject.RecordTypeId = Schema.SObjectType.DUP_List_Of_Values__c.getRecordTypeInfosByDeveloperName().get('DUP_Low_Risk').getRecordTypeId();
            lovList.add(LoVObject);
        }
        return lovList;
    }
    public static List<DUP_Document_Template__c> createDocumentTemplate(Integer numberOfDocumentTemplates){
  		List<DUP_Document_Template__c> docTemplateList = new List<DUP_Document_Template__c>();
        for (Integer i = 0; i < numberOfDocumentTemplates; i++){
            DUP_Document_Template__c doc = new DUP_Document_Template__c();
            doc.Name = 'Testing-template';
            docTemplateList.add(doc);
        }
        return docTemplateList;
    }
    
    public static List<Messaging.SingleEmailMessage> createSingleEmails(Integer numberOfEmails, Id emailTemplateId,
                                                                       Id targetObjectId, Id WhatId) {
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        for (Integer i = 0; i < numberOfEmails; i++) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
            message.setTemplateID(emailTemplateId);
            message.setSaveAsActivity(false);
            message.setTargetObjectId(targetObjectId);
            message.setWhatId(WhatId);
            emailsList.add(message);
        }
  		return emailsList;                                                                               
    }
        public static List<Messaging.SingleEmailMessage> createSingleEmailsError(Integer numberOfEmails, 
                                                                       Id targetObjectId, Id WhatId) {
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        for (Integer i = 0; i < numberOfEmails; i++) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
            message.setSaveAsActivity(false);
            message.setTargetObjectId(targetObjectId);
            message.setWhatId(WhatId);
            emailsList.add(message);
        }
  		return emailsList;                                                                               
    }
    public static Map < String, String > createSelfTestUser() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'Pupulis';
        String lastName = 'Kukulis';
        String email = 'kukulis@pupulis.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        String language = 'English';
        paramsMap.put('language', language);
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    /**
     * Added  by Babul
     **/
    public static List<ContentDocumentLink> createContentDocumentLink(Id ContentDocumentId, Id LinkedEntityId, Integer noOfRecords) {
        List <ContentDocumentLink> cdLinkRecord = new List <ContentDocumentLink>();
        for ( integer i=0; i<noOfRecords; i++){
            ContentDocumentLink cdl = new ContentDocumentLink();
        	cdl.ContentDocumentId = ContentDocumentId;
        	cdl.LinkedEntityId = LinkedEntityId;
            cdl.ShareType= 'V';
            cdLinkRecord.add(cdl);
        }         
        return cdLinkRecord;
    }
}