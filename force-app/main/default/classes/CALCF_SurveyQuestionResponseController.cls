public class CALCF_SurveyQuestionResponseController {
    @auraEnabled
    public static List<SurveyQuestionResponse__c> getSurveyQuestions (String surveyId) {
        return [SELECT lcf_CES_Level__c,lcf_NPS_Level__c,lcf_Survey_Question__c, lcf_Hideable_Response__c, Survey_Question__r.OrderNumber__c
                                     FROM SurveyQuestionResponse__c 
                                     WHERE SurveyTaker__c =: surveyId
                                     ORDER BY Survey_Question__r.OrderNumber__c ASC];
    }
}