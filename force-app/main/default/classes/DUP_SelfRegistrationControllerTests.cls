/***********************************************************************************************
* @author           Naglis Kazlauskas - IBM
* @date             16OCT2019
* @description      Testing class for DUP_SelfRegistrationController
************************************************************************************************/
@isTest
public class DUP_SelfRegistrationControllerTests {
    @testSetup static void makeData(){
        Id permissionSet = [SELECT Id FROM PermissionSet WHERE NAME = 'DUP_Counterparty_Access'].Id;       
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        /*
        //Commenting this call to insert REIDP APP record as discussed with IDP Team
        REIDP_Application__c app = new REIDP_Application__c(Name = 'Test App ',  
                                                            Connected_App__c = 'DUP DEV',
                                                            Can_User_Request_Access__c = false,
                                                            Is_Active__c = true,
                                                            Is_Restricted__c = false,
                                                            Is_Multi_Region__c = false,
                                                            Community__c = 'BP',
                                                            Permission_Set__c = permissionSet,
                                                            Approver__c = newUser[0].Id,
                                                            Short_Name__c = 'Doc Upload');
        insert app;        
        */        
    }
    
    /**
    * @description 	isValidPassword Positive test
    * @param
    * @return
    */
    @isTest static void isValidPasswordTestPositive() {
        Test.startTest();
        System.assertEquals(true, DUP_SelfRegistrationController.isValidPassword('test', 'test'));
        System.assertEquals(false, DUP_SelfRegistrationController.isValidPassword('tes2t', 'test'));
        System.assertEquals(false, DUP_SelfRegistrationController.isValidPassword('tes2t', null));
        System.assertEquals(false, DUP_SelfRegistrationController.isValidPassword(null, 'test'));
        Test.stopTest();
        
    }
    /**
    * @description 	siteAsContainerEnabled negative test
    * @param
    * @return
    */
    @isTest static void siteAsContainerEnabledTestNegative() {
        String s = 'https://www.google.com';
        Test.startTest();
        Boolean falseReceive = DUP_SelfRegistrationController.siteAsContainerEnabled(s);
        Test.stopTest();
        system.assertEquals(false, falseReceive);
    }
    /**
    * @description 	selfRegister positive test
    * @param
    * @return
    */
    @isTest static void selfRegisterPositive(){
        String PositiveUserEmail = 'selfRegisterPositive@controllertest.com';
        DUP_Counterparty_Contact__c newCounterpartyContact = new DUP_Counterparty_Contact__c();
        newCounterpartyContact.Name = 'CounterParty Contact1';
        newCounterpartyContact.DUP_Email__c = 'counterparty@contact.com';
        insert newCounterpartyContact;
        
        Map < String, String > testMap = DUP_DataFactory.createSelfTestUser();   
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new DUP_SelfRegHttpCalloutMock()); 
        
        
        String test1 = DUP_SelfRegistrationController.selfRegister(testMap.get('firstName'), testMap.get('lastName'), 'counterparty@contact.com',
                                                                   testMap.get('language'), testMap.get('password'),testMap.get('confirmPasswordCorrect'),
                                                                   testMap.get('accountId'), testMap.get('regConfirmUrl'),testMap.get('extraFields'),
                                                                   testMap.get('startUrl'), true);
        Test.stopTest();
        System.assertEquals(null, test1);
        
    }
    /**
    * @description 	selfRegister negative test when passwords are different
    * @param
    * @return
    //This functionality has been removed from the DUP_SelfRegistrationController class
    */
    // @isTest static void selfRegisterNegative(){
    //     Map < String, String > testMap = DUP_DataFactory.createSelfTestUser();        
    //     
    //     Test.startTest();      
    //     Test.setMock(HttpCalloutMock.class, new DUP_SelfRegHttpCalloutMock()); 
    //     System.assertEquals(true, DUP_SelfRegistrationController.selfRegister(testMap.get('firstName'), testMap.get('lastName'), testMap.get('email'),
    //                                                                           testMap.get('language'), testMap.get('password'),testMap.get('confirmPasswordWrong'),
    //                                                                           testMap.get('accountId'), testMap.get('regConfirmUrl'),testMap.get('extraFields'),
    //                                                                           testMap.get('startUrl'), true).contains(Label.IDPPasswordNotMatch));
    //     Test.stopTest();        
    // }
    /**
    * @description 	selfRegister negative test when last name is null
    * @param
    * @return
    */
    @isTest static void selfRegisterNegativeNullName(){
        Map < String, String > testMap = DUP_DataFactory.createSelfTestUser();        
        Test.startTest();      
        Test.setMock(HttpCalloutMock.class, new DUP_SelfRegHttpCalloutMock());
        System.assertEquals(true, DUP_SelfRegistrationController.selfRegister(testMap.get('firstName'), null, testMap.get('email'),
                                                                              testMap.get('language'), testMap.get('password'),testMap.get('confirmPasswordCorrect'),
                                                                              testMap.get('accountId'), testMap.get('regConfirmUrl'),testMap.get('extraFields'),
                                                                              testMap.get('startUrl'), true).contains(Label.IDPLastNameRequired));
        Test.stopTest();
    }
    /**
    * @description 	selfRegister negative test when there are duplicate emails
    * @param
    * @return
    */
    @isTest static void selfRegisterNegativeDuplicateEmails(){
        DUP_Counterparty_Contact__c newCounterpartyContact = new DUP_Counterparty_Contact__c();
        newCounterpartyContact.Name = 'CounterParty Contact2';
        newCounterpartyContact.DUP_Email__c = 'positive@controllertest.com';
        insert newCounterpartyContact;
        
        Map < String, String > testMap = DUP_DataFactory.createSelfTestUser();        
        Test.startTest();      
        Test.setMock(HttpCalloutMock.class, new DUP_SelfRegHttpCalloutMock());
        System.assertEquals(true, DUP_SelfRegistrationController.selfRegister(testMap.get('firstName'), testMap.get('lastName'), 'positive@controllertest.com',
                                                                              testMap.get('language'), testMap.get('password'),testMap.get('confirmPasswordCorrect'),
                                                                              testMap.get('accountId'), testMap.get('regConfirmUrl'),testMap.get('extraFields'),
                                                                              testMap.get('startUrl'), true).contains(Label.BPDuplicateEmail));
        
        Test.stopTest();
    }
    /**
    * @description 	selfRegister negative test when email is null
    * @param
    * @return
    */
    @isTest static void selfRegisterNegativeNullEmail(){        
        Map < String, String > testMap = DUP_DataFactory.createSelfTestUser();        
        Test.startTest();      
        Test.setMock(HttpCalloutMock.class, new DUP_SelfRegHttpCalloutMock());
        System.assertEquals(true, DUP_SelfRegistrationController.selfRegister(testMap.get('firstName'), testMap.get('lastName'), null,
                                                                              testMap.get('language'), testMap.get('password'),testMap.get('confirmPasswordCorrect'),
                                                                              testMap.get('accountId'), testMap.get('regConfirmUrl'),testMap.get('extraFields'),
                                                                              testMap.get('startUrl'), true).contains(Label.IDPEmailRequired));
        Test.stopTest();
    }
    /**
    * @description 	selfRegister positive test for extra fields
    * @param
    * @return
    */
    @isTest static void selfRegisterPositiveExtraFields()  {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > testMap = DUP_DataFactory.createSelfTestUser();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        DUP_Counterparty_Contact__c newCounterpartyContact = new DUP_Counterparty_Contact__c();
        newCounterpartyContact.Name = 'CounterParty Contact3';
        newCounterpartyContact.DUP_Email__c = 'kukulis@pupulis.com';
        insert newCounterpartyContact;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DUP_SelfRegHttpCalloutMock());
        System.assertEquals(null, DUP_SelfRegistrationController.selfRegister(testMap.get('firstName'), testMap.get('lastName'), testMap.get('email'),
                                                                                 testMap.get('language'), testMap.get('password'),testMap.get('confirmPasswordCorrect'),
                                                                                 testMap.get('accountId'), testMap.get('regConfirmUrl'),extraFields,
                                                                                 testMap.get('startUrl'), true));
        Test.stopTest();
    }
     /**
    * @description 	Non empty extra fields negative test 
    * @param
    * @return
    */        
    @IsTest static void testGetNullExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), DUP_SelfRegistrationController.getExtraFields(null));
    }
     /**
    * @description 	Non empty extra fields positive test 
    * @param
    * @return
    */    
    @IsTest static void testGetNonEmptyExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), DUP_SelfRegistrationController.getExtraFields('field1'));
    }
}