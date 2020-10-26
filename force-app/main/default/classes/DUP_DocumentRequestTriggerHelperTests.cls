/*****************************************************************************************
*       Date:        30SEP2019
*       Author:      Naglis Jonas Kazlauskas
*       Description: helper class for DUP_DocumentRequestTriggerHandler.apxc
*       Updated:     14OCT2019
*****************************************************************************************/

@isTest
public with sharing class DUP_DocumentRequestTriggerHelperTests {
    /**
    * @description 	insert relevant data used by other methods
    * @param
    * @return
    */
    @TestSetup 
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        List<User> positiveUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert positiveUser;
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(100);
        insert entityList;
        List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(positiveUser);
        insert newCounterpartyContactList;
    }
    /**
    * @description 	checkOnStatus test when everything in the path is correct
    * @param
    * @return
    */
    @isTest static void createDocumentStoresTestPositivePath(){                       
        List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               ccList, 5);
        insert newDocumentStoreList;
        
        List<DUP_Document_Store__c> dSList = [SELECT DUP_Document_Status__c
                                              FROM DUP_Document_Store__c
                                              WHERE DUP_Document_Request__c =: newDocumentRequestList[0].Id];
        
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        update newDocumentRequestList;
                
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Review_Upload';
        }
        
        update newDocumentRequestList;
        
        for(DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c = 'Reviewed';
        }
        update newDocumentStoreList;
        
        Test.startTest();
        update newDocumentRequestList;
        Test.stopTest();
        
        for (DUP_Document_Request__c status : newDocumentRequestList) {
            System.assertEquals('DUP_Review_Upload', status.DUP_Status_Upload__c);    
        }              
    }
    /**
    * @description 	checkOnStatus test when path changes from 3rd to 2nd when documents have been reviewed
    * @param
    * @return
    */
    @isTest static void createDocumentStoresReviewToNot(){                       
        List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               ccList, 5);
        insert newDocumentStoreList;
        
        Set<Id> myTestingSet = new Set<Id>();
        for (DUP_Document_Request__c drl : newDocumentRequestList) {
            myTestingSet.add(drl.id);
        }
                
        List<DUP_Document_Store__c> dSList = [SELECT DUP_Document_Status__c
                                              FROM DUP_Document_Store__c
                                              WHERE DUP_Document_Request__c =: newDocumentRequestList[0].Id];
        
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        update newDocumentRequestList;
                
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Review_Upload';
        }
        update newDocumentRequestList;
        
        for(DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c = 'Reviewed';
        }
        update newDocumentStoreList;
        
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        Test.startTest();
        try {
            update newDocumentRequestList;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }      
        Test.stopTest();             
    }     
    /**
    * @description 	checkOnStatus test when the path is incorrect: changing path one step forward
    * @param
    * @return
    */
    @isTest static void checkOnStatusChangesConfirmDetailsNoCounterparty(){
        List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        newDocumentRequestList[0].DUP_Additional_Information__c = true;
        newDocumentRequestList[0].DUP_Email_Templates__c = 'Additional Info Request Template';
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               ccList, 5);
        insert newDocumentStoreList;
        
        // 	Update request status 
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        update newDocumentRequestList;
        
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Review_Upload';
        }
        
        Test.startTest();
        try {
            update newDocumentRequestList;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();              
    }
    /**
    * @description 	checkOnStatus test when the path is incorrect: changing path one step backwards
    * @param
    * @return
    */
    @isTest static void checkOnStatusChangesDUPNewRequestTest() {
        List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               ccList, 5);
        insert newDocumentStoreList;
        // 	Update request status
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        update newDocumentRequestList;
        
        // 	Rollback request status  
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_New_Request';
        }
        try {
            update newDocumentRequestList;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }  
    }
    /**
    * @description 	checkOnStatus test when there is no counterParty name assigned to Store
    * @param
    * @return
    */
    @isTest static void checkOnStatusChangesNoCounterpartyName() {
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        newDocumentRequestList[0].DUP_Email_Templates__c = 'Review Template';
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> stores = new List<DUP_Document_Store__c>();
        for(integer i = 0; i<10; i++) {
            DUP_Document_Store__c newStore = new DUP_Document_Store__c();
            newStore.DUP_Options__c = 'Optional';
            newStore.DUP_Document_Request__c = newDocumentRequestList[0].Id;
            newStore.DUP_Document_Status__c = 'Created';
            newStore.DUP_Requested__c = true;
            stores.add(newStore);
        }
        insert stores;
                
        for (DUP_Document_Request__c request : newDocumentRequestList) {
            request.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }  
        update newDocumentRequestList;
        
        for (DUP_Document_Request__c request : newDocumentRequestList) {
            request.DUP_Status_Upload__c = 'DUP_Review_Upload';
        }
         Test.startTest();
        try {
            update newDocumentRequestList;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        	//System.Assert(e.getMessage().contains('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY'));
        } 
        Test.stopTest();
    }
    
    /**
    * @description 	checkOnStatus test when the path is incorrect: changing path one step backward when the request is already approved
    * @param
    * @return
    */
    @isTest static void checkOnStatusChangesLastStageTest() {
         List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        newDocumentRequestList[0].DUP_Email_Templates__c = 'Review Template';
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               ccList, 5);
        insert newDocumentStoreList;
        // 	Update request status
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        update newDocumentRequestList;
                
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Review_Upload ';
        }
        update newDocumentRequestList;
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Approved';
        }
        try {
            update newDocumentRequestList;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }  
    }
    
    /**
    * @description testing error "You must select and save at least one document" scenario"
    * @param
    * @return
    */
    @isTest static void populateAtLeastOne() {
        List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(newDocumentRequestList,
                                                                                               ccList, 5);
        insert newDocumentStoreList;
        // 	Update request status
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = 'DUP_Confirm_Details';
        }
        update newDocumentRequestList;
                        
        for(DUP_Document_Store__c dS : newDocumentStoreList) {
            dS.DUP_Document_Status__c = 'Reviewed';
        }
           
        try {
            update newDocumentStoreList;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }  
    }
    @isTest static void cancelDocRequest() {
        List<DUP_Counterparty_Contact__c> ccList = [SELECT Id
                                                    FROM DUP_Counterparty_Contact__c
                                                    WHERE DUP_Email__c = 'positive@controllertest.com'];
        
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
       
        for (DUP_Document_Request__c docReq : newDocumentRequestList) {
            docReq.DUP_Status_Upload__c = System.Label.DUP_DocumentReqStatus_Cancelled;
        }
        Test.startTest();
        try {
            update newDocumentRequestList;
            for (DUP_Document_Request__c status : newDocumentRequestList) {
                System.assertEquals('DUP_Cancelled', status.DUP_Status_Upload__c);   
            }   
        } catch (Exception e) {
            System.debug('--'+e.getMessage());
        }  
        Test.stopTest();
    }
     /**
    * @description testing "DUP_Requestor_Emails__c" with Positive case(emails ending with @bp.com or .bp.com) email string 
    * @param
    * @return
    */
    @isTest static void validateRequestorEmailTestPositive() {
       List<DUP_BP_Entity_Details__c> entityList = [SELECT id,name
                                                   FROM DUP_BP_Entity_Details__c
                                                   LIMIT 100];
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(100,entityList);
        test.startTest();
        try{
            insert newDocumentRequestList;
        }
        catch(exception error){
            system.assert(error.getMessage().contains('Please enter valid BP email addresses and if there are multiple email addresses kindly separate them with a ","!'));
        }
		test.stopTest();
        List<DUP_Document_Request__c> newDocumentRequestTestList = [SELECT id,DUP_Requestor_Emails__c
                                                                    FROM DUP_Document_Request__c 
                                                                   	LIMIT 100];
        Integer i=0;
        For(DUP_Document_Request__c dr : newDocumentRequestTestList){
            system.assertEquals('email'+i+'@bp.com,email@uk.bp.com', dr.DUP_Requestor_Emails__c);
            i++;
        }
        
    }
    
    /**
    * @description testing "DUP_Requestor_Emails__c" with Negative case(emails not ending with @bp.com or .bp.com) email string 
    * @param
    * @return
    */
    @isTest static void validateRequestorEmailTestNegative() { 
            List<DUP_BP_Entity_Details__c> entityList = [SELECT id,name
                                                   FROM DUP_BP_Entity_Details__c
                                                   LIMIT 1];
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1,entityList);
        newDocumentRequestList[0].DUP_Requestor_Emails__c = 'email@gmail.com,email@bp.com';
           
        try{
            insert newDocumentRequestList;
        }
        catch(exception error){
            system.assert(error.getMessage().contains('Please enter valid BP email addresses and if there are multiple email addresses kindly separate them with a ","!'));
        }   
    }
    
}