/***************************************************************************************************
* Description : Unit Tests for the CA_SendTaskAsEmailController Apex Class
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2016-NOV-15   1.0                 Grant Whitfield     Initial version
* 2018-SEP-27   1.1                 Maros Zilka         Sonar Qube Fixes
***************************************************************************************************/

@isTest
private class CA_SendTaskAsEmailControllerTest
{
    /********************************************************************
    * Data Preparation Method
    * ------------------------
    * Method to create custom settings prior to running tests.
    ********************************************************************/
    @testSetup
    static void createSendTaskSettings() {
        Send_Task_Settings__c sendTaskSetting1 = new Send_Task_Settings__c();
        sendTaskSetting1.Name = 'UK01-LA-GBS';
        sendTaskSetting1.Display_Name__c = 'GBS Support';
        sendTaskSetting1.Business_Unit__c = 'Lubricants - Automotive';
        sendTaskSetting1.Sales_Organisation__c =  'UK01';
        sendTaskSetting1.Primary_Email__c = 'createSendTaskSettings@UK01-LA-GBS.primary.castrol.null';
        sendTaskSetting1.Secondary_Email__c = 'createSendTaskSettings@UK01-LA-GBS.secondary.castrol.null';
        sendTaskSetting1.LCF_Available__c = true;
        sendTaskSetting1.SFO_Available__c = true;
        insert sendTaskSetting1;

        Send_Task_Settings__c sendTaskSetting2 = new Send_Task_Settings__c();
        sendTaskSetting2.Name = 'UK01-LA-Technical';
        sendTaskSetting2.Display_Name__c = 'Technical';
        sendTaskSetting2.Business_Unit__c = 'Lubricants - Automotive';
        sendTaskSetting2.Sales_Organisation__c =  'UK01';
        sendTaskSetting2.Primary_Email__c = 'createSendTaskSettings@UK01-LA-Technical.primary.castrol.null';
        sendTaskSetting2.Secondary_Email__c = 'createSendTaskSettings@UK01-LA-Technical.secondary.castrol.null';
        sendTaskSetting2.LCF_Available__c = true;
        sendTaskSetting2.SFO_Available__c = true;
        insert sendTaskSetting2;

        Send_Task_Settings__c sendTaskSetting3 = new Send_Task_Settings__c();
        sendTaskSetting3.Name = 'AT01-LA-GBS';
        sendTaskSetting3.Display_Name__c = 'GBS Support';
        sendTaskSetting3.Business_Unit__c = 'Lubricants - Automotive';
        sendTaskSetting3.Sales_Organisation__c =  'AT01';
        sendTaskSetting3.Primary_Email__c = 'createSendTaskSettings@AT01-LA-GBS.primary.castrol.null';
        sendTaskSetting3.Secondary_Email__c = 'createSendTaskSettings@AT01-LA-GBS.secondary.castrol.null';
        sendTaskSetting3.LCF_Available__c = true;
        sendTaskSetting3.SFO_Available__c = true;
        insert sendTaskSetting3;
    }

    /********************************************************************
    * Data Preparation Method
    * ------------------------
    * Method to create custom settings prior to running tests.
    ********************************************************************/
    @testSetup
    static void createTestAccountandTask() {

        Account testAccount1 = new Account();
        testAccount1.Name = 'TestAccount1';
        testAccount1.Business_Unit__c = 'Lubricants - Automotive';
        testAccount1.Sales_Organisation__c =  'UK01';
        insert(testAccount1);

        Task testTask1 = new Task();
        testTask1.Subject = 'testTask1';
        testTask1.Priority = 'High';
        testTask1.WhatId = testAccount1.id;
        insert(testTask1);

        Contact testContact = new Contact();
        testContact.FirstName = 'David';
        testContact.LastName = 'Gilmour';
        testContact.AccountId = testAccount1.Id;
        testContact.Email = 'david@ibm.com';
        testContact.Home_Location__c = 'United Kingdom';
        testContact.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        testContact.Preferred_Language__c = 'English-British';
        testContact.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        insert testContact;

        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;

        SurveyTaker__c testSurvey = new SurveyTaker__c();
        testSurvey.Survey__c = testTemplate.id;
        testSurvey.Account__c = testAccount1.id;
        testSurvey.Contact__c = testContact.id;
        testSurvey.Survey_Status__c = 'Sent';
        testSurvey.Sales_Organisation__c = 'UK01';
        testSurvey.Survey_Fire_Time__c = Date.today();
        insert testSurvey;

        Task testTask2 = new Task();
        testTask2.Subject = 'testTask2';
        testTask2.Priority = 'High';
        testTask2.WhatId = testSurvey.id;
        insert testTask2;
    }

    /********************************************************************
    * Test Method
    * ------------------------
    * Method will test correct Parent Specific Details for Survey related task
    ********************************************************************/
    @isTest
    static void getParentSpecificDetailsForSurvey() {
        Test.startTest();

        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask2'].Id;

        String[] result;
        result = CA_SendTaskAsEmailController.getParentSpecificDetails(string.valueOf(testTaskId));

        system.assertEquals('Lubricants - Automotive', result[2] );
        system.assertEquals('UK01', result[1] );

        Test.stopTest();
    }

    /********************************************************************
    * Test Method
    * ------------------------
    * Method will test correct assiginig of sending options for Survey related task
    ********************************************************************/
    @isTest
    static void getAssignmentOptionsForSurvey() {
        Test.startTest();

        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask2'].Id;

        // create a list of the options
        list<Send_Task_Settings__c> sendTaskSettings;
        sendTaskSettings = CA_SendTaskAsEmailController.getAssignmentOptions(
            string.valueOf(testTaskId),'Lubricants - Automotive', 'AT01'
        );

        // ensure that data is returned as expected - 1 record for GBS support / AT01-LA-GBS
        system.assertEquals(1, sendTaskSettings.size() );
        system.assertEquals('AT01-LA-GBS', sendTaskSettings[0].Name);
        system.assertEquals('GBS Support', sendTaskSettings[0].Display_Name__c);

        Test.stopTest();
    }

    /********************************************************************
    * Test Method
    * ------------------------
    * Tests the return of the Send To options from custom settings - Send_Task_Settings__c
    ********************************************************************/
    @isTest
    static void getAssignmentOptionsForAccount() {
        Test.startTest();

        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask1'].Id;

        list<Send_Task_Settings__c> sendTaskSettings;
		sendTaskSettings = CA_SendTaskAsEmailController.getAssignmentOptions(
            string.valueOf(testTaskId),'Lubricants - Automotive', 'AT01'
        );

        // ensure that data is returned as expected - 1 record for GBS support / AT01-LA-GBS
        system.assertEquals(1, sendTaskSettings.size() );
        system.assertEquals('AT01-LA-GBS', sendTaskSettings[0].Name);
        system.assertEquals('GBS Support', sendTaskSettings[0].Display_Name__c);

        Test.stopTest();
    }

    /********************************************************************
    * Test Method
    * ------------------------
    * Tests the correct return of task & account data
    ********************************************************************/
    @isTest
    static void testGetTaskDetails() {
        Test.startTest();

        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask1'].Id;

        Task testTaskDetail = CA_SendTaskAsEmailController.getTaskDetails(testTaskId);

        // ensure that data is returned as expected
        system.assertEquals(testTaskDetail.Task_Sent_as_Email__c, false);
        system.assertEquals(testTaskDetail.Account.Sales_Organisation__c , 'UK01');
        system.assertEquals(testTaskDetail.Account.Business_Unit__c , 'Lubricants - Automotive');

        Test.stopTest();
    }

    /********************************************************************
    * Test Method
    * ------------------------
    * Test description of meta-data is returned from system
    * This method is used only for bug in Salesforce rendering picklist in component
    * no tests asserts are required for this as values could change - test is for coverage only
    ********************************************************************/
    @isTest
    static void testGetTaskPriorityValues() {
        Test.startTest();

        List<string> taskPriorityList = CA_SendTaskAsEmailController.getTaskPriorityValues();

        Test.stopTest();

        system.assert(!taskPriorityList.isEmpty(), 'taskPriorityList should not be empty.');
    }
    
    /********************************************************************
    * Test Method
    * ------------------------
    * Tests if the type is successfully returned
    ********************************************************************/
    @isTest
    static void getTaskType() {
        Test.startTest();
        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask2'].Id;
        String result;
        result = CA_SendTaskAsEmailController.getTaskType(string.valueOf(testTaskId));
        system.assertEquals('SurveyTaker__c', result );
        Test.stopTest();
    }

    /********************************************************************
    * Test Method
    * ------------------------
    * Tests the saveTask method is successful
    ********************************************************************/
    @isTest
    static void testSaveTaskSuccess() {
        Test.startTest();

        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask1'].Id;

        Task testTaskDetail = CA_SendTaskAsEmailController.getTaskDetails(testTaskId);

        boolean saveResult = CA_SendTaskAsEmailController.saveTask(testTaskDetail, 'UK01-LA-GBS');

        system.assertEquals(saveResult, true);

        Test.stopTest();
    }


    /********************************************************************
    * Test Method
    * ------------------------
    * Tests the saveTask method returned failure
    ********************************************************************/
    @isTest
    static void testSaveTaskFail() {
        Test.startTest();

        Id testTaskId = [SELECT Id FROM Task WHERE Subject = 'testTask1'].Id;

        // call the getTaskDetails method passing the Id
        Task testTaskDetail = CA_SendTaskAsEmailController.getTaskDetails(testTaskId);

        // attempt to save the record but expect a DML error due to name too long (exceed 255)
         string toolongString = 'abcde1234567890';

         // build toolongString greater than 255 chars
         integer i = 0;
         for (i=0; i<50; i++){
             toolongString = toolongString + 'abcde1234567890';
         }

         // attempt to save with a long string
        boolean saveResult = CA_SendTaskAsEmailController.saveTask(testTaskDetail, toolongString);

        system.assertEquals(saveResult, false);

        Test.stopTest();
    }
}