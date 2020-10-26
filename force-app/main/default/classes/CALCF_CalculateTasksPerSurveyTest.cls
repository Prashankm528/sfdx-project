/***************************************************************************************************
* Description : test class for CALCF_CalculateTasksPerSurvey
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2018-JAN-30   1.0                 Frantisek Kolacny   Initial version
* 2018-SEP-27   1.1                 Maros Zilka         SonarCube Fixes
*
****************************************************************************************************/

@isTest
private class CALCF_CalculateTasksPerSurveyTest {

    static testmethod void test_calculate_task_count() {

        Test.startTest();

        Task task = prepareTask();
        insert task;

        Test.stopTest();

        list<SurveyTaker__c> result = [
            SELECT Id, LCF_Count_Of_Tasks__c
            FROM SurveyTaker__c
            LIMIT 10
            ];
        System.assertEquals(1, result.size());
        System.assertEquals('1', result[0].LCF_Count_Of_Tasks__c);
    }

    private static Task prepareTask() {

        Account newAccount = new Account (name = 'testname',
        BillingCity ='TestCity', BillingCountry ='TestCountry',
        BillingStreet ='TestStreet', BillingPostalCode ='t3stcd3');
        insert newAccount;

        Contact NewContact = new Contact (FirstName = 'xyzFirst',
        LastName = 'XyZLast',AccountId = newAccount.Id,Email = 'xyzmail@mail.com',
        Survey_Opt_Out__c = false);
        insert NewContact;

        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;

        SurveyTaker__c survey = new SurveyTaker__c();
        survey.Survey__c = testTemplate.id;
        survey.Contact__c = NewContact.Id;
        survey.Fire_Survey__c = false;
        survey.Survey_Status__c = 'Pending';
        survey.Mode__c = 'Batch';
        survey.Sales_Organisation__c = 'UK01';
        insert survey;

        Task task1 = new Task();
        task1.WhatId = survey.Id;
        task1.Subject = 'Subject 1';

        return task1;
    }
}