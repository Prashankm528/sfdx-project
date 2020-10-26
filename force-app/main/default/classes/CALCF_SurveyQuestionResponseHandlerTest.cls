/***************************************************************************************************
* Description : Test class for CALCF_SurveyQuestionResponseHandler
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2017-Nov-28   1.0                 Frantisek Kolacny   Initial version
* 2018-SEP-27   1.1                 Maros Zilka         SonarCube Fixes
*
***************************************************************************************************/

@isTest
private class CALCF_SurveyQuestionResponseHandlerTest {

    static testmethod void hideCommentInResponse() {

        // Arrange.
        List<SurveyQuestionResponse__c> listToUpdate = createResponseToUpdate(true, 'Hide me !');

        Test.startTest();

        CALCF_SurveyQuestionResponseHandler.updateHideableResponse(listToUpdate);

        Test.stopTest();

        System.assertEquals('', listToUpdate[0].lcf_Hideable_Response__c);
   }

    /***********************************************************************************
	* Test Method
	*--------------
	* Unhide response if lcf_Hide_Response__c = false;
    ***********************************************************************************/
    static testmethod void unhideCommentInResponse(){

        // Arrange.
        List<SurveyQuestionResponse__c> listToUpdate = createResponseToUpdate(false, '');

        Test.startTest();

        CALCF_SurveyQuestionResponseHandler.updateHideableResponse(listToUpdate);

        Test.stopTest();

        System.assertEquals('Hide me !', listToUpdate[0].lcf_Hideable_Response__c);
   }

    /***********************************************************************************
    * Test Method
    * Hide response if lcf_Hide_Response__c = true call Trigger for this action.
    ***********************************************************************************/
    static testmethod void hideCommentInResponseCallTrigger(){

        // Arrange.
        SurveyQuestionResponse__c response =  createSurveyAndReturnFullTextQuestion();
        response.lcf_Hide_Response__c = true;

        Test.startTest();

        update response;

        Test.stopTest();

        List<SurveyQuestionResponse__c> updatedResponse = [
            SELECT lcf_Hideable_Response__c
            FROM SurveyQuestionResponse__c
            LIMIT 10
            ];
        System.assertEquals(1, updatedResponse.size());
        System.assertEquals(null, updatedResponse[0].lcf_Hideable_Response__c);
   }

    static List<SurveyQuestionResponse__c> createResponseToUpdate(
        boolean hideResponse,
        string hideableResponse) {

        List<SurveyQuestionResponse__c> listToUpdate = new List<SurveyQuestionResponse__c>();
        SurveyQuestionResponse__c response = new SurveyQuestionResponse__c();
        response.Response__c = 'Hide me !';
        response.lcf_Hideable_Response__c = hideableResponse;
        response.lcf_Hide_Response__c = hideResponse;
        listToUpdate.add(response);

        return listToUpdate;
   }

    static SurveyQuestionResponse__c createSurveyAndReturnFullTextQuestion() {

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

        Survey_Question__c newQuestion = new Survey_Question__c();
        newQuestion.Survey__c = testTemplate.id;
        newQuestion.OrderNumber__c = 5;
        newQuestion.Question__c = 'How likely is it that you would recommend Castrol to a friend?';
        newQuestion.CALCF_Question_Short_Name__c = 'NPS';
        insert newQuestion;

        SurveyTaker__c survey = new SurveyTaker__c();
        survey.Survey__c = testTemplate.id;
        survey.Survey_Time__c = datetime.now();
        survey.Contact__c = NewContact.Id;
        survey.Fire_Survey__c = false;
        survey.Survey_Status__c = 'Taken';
        survey.Mode__c = 'Batch';
        survey.Sales_Organisation__c = 'UK01';
        insert survey;

        SurveyQuestionResponse__c response = new SurveyQuestionResponse__c();
        response.Response__c = 'Hide me !';
        response.lcf_Hideable_Response__c = 'Hide me !';
        response.lcf_Hide_Response__c = false;
        response.SurveyTaker__c = survey.Id;
        response.Survey_Question__c = newQuestion.id;
        insert response;

        return response;
    }
}