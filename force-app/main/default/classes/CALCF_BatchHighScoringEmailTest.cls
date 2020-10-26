/***************************************************************************************************
* Description : test class for CALCF_BatchHighScoringEmail
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2018-JAN-29   1.0                 Frantisek Kolacny   Initial version
* 2018-SEP-27   1.1                 Maros Zilka         SonarCube Fixes
*
***************************************************************************************************/

@isTest
private class CALCF_BatchHighScoringEmailTest {

    @testSetup
    static void setUp() {

        LCF_Operations_Manager_Settings__c settings = new LCF_Operations_Manager_Settings__c();
        settings.Operations_Manager_Email__c = 'Frantisek@IBM.com';
        settings.Operations_Manager_First_Name__c = 'Frantisek';
        settings.Sales_Organization__c = 'UK01';
        settings.Survey_Type__c = 'Orders';
        settings.Name = '001';
        insert settings;

        // List of surveys which will be used for testing.
        List<SurveyTaker__c> testSurveys = new list<SurveyTaker__c>();

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

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;

        SurveyTaker__c survey = new SurveyTaker__c();
        survey.Survey__c = testTemplate.id;
        survey.Contact__c = NewContact.Id;
        survey.Fire_Survey__c = false;
        survey.Survey_Status__c = 'Pending';
        survey.Mode__c = 'Batch';
        survey.Sales_Organisation__c = 'UK01';
        insert survey;

        SurveyQuestionResponse__c response = new SurveyQuestionResponse__c();
        response.Response__c = '10';
        response.SurveyTaker__c = survey.Id;
        response.Survey_Question__c = question.Id;
        insert response;
    }

    static testmethod void test_create_digest() {

        Test.startTest();

        CALCF_BatchHighScoringEmail batchJob = new CALCF_BatchHighScoringEmail();
        database.executeBatch(batchJob);

        Test.stopTest();

        List<CALCF_High_Scoring_Digest__c> result = [
                                                        SELECT Id
                                                        FROM CALCF_High_Scoring_Digest__c
                                                        LIMIT 10
                                                    ];

        System.assertEquals(1, result.size());
    }
}