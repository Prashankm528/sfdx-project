/*****************************************************************************************
*       Date:        1OCT2019
*       Author:      Naglis Jonas Kazlauskas - IBM
*       Description: test class for DUP_MessagingServices
*****************************************************************************************/
@isTest
public class DUP_MessagingServicesTests {
    /**
    * @description 	createEmail test - creating an email message
    * @param
    * @return
    */
    @isTest static void createEmailMessageTest(){
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<EmailTemplate> emailTemplate = [SELECT DeveloperName
                                             FROM EmailTemplate
                                             WHERE DeveloperName = 'DUP_Request_VF_Template'];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<String> s = new List<String>();
        s.add('test@test.com');

        List<String> cc = new List<String>();
        cc.add('test1@test.com');
        
        Test.startTest();
        Messaging.SingleEmailMessage message = DUP_MessagingServices.createEmailMessage(newDocumentRequestList[0].Id,
                                                                                        emailTemplate[0].Id,
                                                                                        newUser[0].Id,
                                                                                        newUser[0].Id,
                                                                                        s,
                                                                                        cc
                                                                                       );
        Test.stopTest();
        System.debug('Message contains ' + message);
        System.assertEquals(emailTemplate[0].Id, message.getTemplateId());
    }
    /**
    * @description 	sendEmail positive test - sending a single email
    * @param
    * @return
    */   
    @isTest static void sendEmailTestPositive(){
        //Create neccsary objects for message
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<EmailTemplate> emailTemplate = [SELECT DeveloperName
                                             FROM EmailTemplate
                                             WHERE DeveloperName = 'DUP_Request_VF_Template'];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<String> s = new List<String>();
        
        //Create message
        List<Messaging.SingleEmailMessage> message = DUP_DataFactory.createSingleEmails(1, emailTemplate[0].Id, newUser[0].Id,
                                                                                        newDocumentRequestList[0].Id);
        
        Test.startTest();
        DUP_MessagingServices.sendEmail(message[0]);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        // System.assertEquals(1, invocations);     
    }
    /**
    * @description 	sendEmail negative test
    * @param
    * @return
    */   
    @isTest static void sendEmailTestNegative(){
        //Create neccsary objects for message
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<EmailTemplate> emailTemplate = [SELECT DeveloperName
                                             FROM EmailTemplate
                                             WHERE DeveloperName = 'DUP_Request_VF_Template'];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<String> s = new List<String>();
        
        List<Messaging.SingleEmailMessage> messageError = DUP_DataFactory.createSingleEmailsError(1, newUser[0].Id,
                                                                                                  newDocumentRequestList[0].Id);   
        
        Test.startTest();
        DUP_MessagingServices.sendEmail(messageError[0]);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        // System.assertEquals(0, invocations);     
    }
    /**
    * @description 	sendEmails positive test - sending a list of emails 
    * @param
    * @return
    */   
    @isTest static void sendEmailsPositiveTest(){
        //Create neccsary objects for message
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<EmailTemplate> emailTemplate = [SELECT DeveloperName
                                             FROM EmailTemplate
                                             WHERE DeveloperName = 'DUP_Request_VF_Template'];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<String> s = new List<String>();
        
        //Create message
        List<Messaging.SingleEmailMessage> message = DUP_DataFactory.createSingleEmails(10, emailTemplate[0].Id, newUser[0].Id,
                                                                                        newDocumentRequestList[0].Id);        
        Test.startTest();
        DUP_MessagingServices.sendEmails(message);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        // System.assertEquals(1, invocations);         
    }
    /**
    * @description 	sendEmails negative test
    * @param
    * @return
    */   
    @isTest static void sendEmailsTestNegative(){
        //Create neccsary objects for message
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
        insert entityList;
        List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1, entityList);
        insert newDocumentRequestList;
        
        List<EmailTemplate> emailTemplate = [SELECT DeveloperName
                                             FROM EmailTemplate
                                             WHERE DeveloperName = 'DUP_Request_VF_Template'];
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        List<String> s = new List<String>();
        
        List<Messaging.SingleEmailMessage> messageError = DUP_DataFactory.createSingleEmailsError(10, newUser[0].Id,
                                                                                                  newDocumentRequestList[0].Id);   
        
        Test.startTest();
        DUP_MessagingServices.sendEmails(messageError);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        // System.assertEquals(0, invocations);     
    }
}