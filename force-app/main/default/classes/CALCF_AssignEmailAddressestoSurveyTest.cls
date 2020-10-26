/**************************************************************************************************************************************
* Description : test the different scenarios to CALCF Assign Email Addresses to Survey Response and Send Low Scoring Email.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 30-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class CALCF_AssignEmailAddressestoSurveyTest 
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;

    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;

    }
    
    @isTest
    static void SurveyResponseOperationsManagerTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);

        LCF_Operations_Manager_Settings__c setting = new LCF_Operations_Manager_Settings__c();
        setting.Operations_Manager_Email__c = 'David@ibm.com';
        setting.Operations_Manager_First_Name__c = 'David';
        setting.Sales_Organization__c = 'UK01';
        setting.Survey_Type__c = 'Complaints';
        setting.name = '1';
        insert setting;
        
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
        
        Test.startTest();
        system.runAs(testUser) 
        {
            Map<String, object> params = new Map<String, Object>();
            params.put('SalesOrg', setting.Sales_Organization__c);
            params.put('TypeOfTouchpoint', setting.Survey_Type__c);
            params.put('Id', response.Id);
            Flow.Interview.CALCF_Assign_Email_Addresses_to_Survey_Response_and_Send_Low_Scoring_Email emailFlow = 
                new Flow.Interview.CALCF_Assign_Email_Addresses_to_Survey_Response_and_Send_Low_Scoring_Email(params);
			emailFlow.Start();
        }
        Test.stopTest();
        
        SurveyQuestionResponse__c surveyResponse = [Select Id,Operations_Manager_Name__c From SurveyQuestionResponse__c 
                                                    Where Operations_Manager_Email__c =: setting.Operations_Manager_Email__c limit 1];
        System.assertEquals(setting.Operations_Manager_First_Name__c, surveyResponse.Operations_Manager_Name__c, 'Survery reponse Operations Manager Name should be equal to Operations Manager settings First Name');
    }
}