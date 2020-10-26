/******************************************************************************************************************
* Description : Unit Tests for the CALCF_SurveyQuestionResponseController Apex Class		
*
* This class has SeeAllData annointed as some of the fields in SurveyQuestionResponse__c are not editable
*******************************************************************************************************************/


@isTest
public class CALCF_SurveyQuestionResponseControllerT {
    
     static testmethod void getSurveyQuestionsTest(){
         
         createSurveyAndReturnFullTextQuestion();
         //Get a survey
         SurveyTaker__c survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
         
         if(survey != null) {
             List<SurveyQuestionResponse__c> responsesBefore = [SELECT lcf_CES_Level__c,lcf_NPS_Level__c,lcf_Survey_Question__c,lcf_Hideable_Response__c 
                                                                 FROM SurveyQuestionResponse__c 
                                                                 WHERE SurveyTaker__c =: survey.Id]; 
             //Call the API
             List<SurveyQuestionResponse__c> responsesAfter = CALCF_SurveyQuestionResponseController.getSurveyQuestions(survey.Id);
             
             //Assert
             System.assertEquals(1, responsesAfter.size());
         }   
     } 

    static SurveyQuestionResponse__c createSurveyAndReturnFullTextQuestion(){

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
    newQuestion.Question__c = 'How likely is it that you would recommend Castrol to a friend or colleague?';
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