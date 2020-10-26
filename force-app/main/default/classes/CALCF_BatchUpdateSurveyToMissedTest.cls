/************************************************************************************************************
* Description : Test class for CALCF_BatchUpdateSurveyToMissed 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-09   1.0                 Frantisek Kolacny   Initial version
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added 
*
*************************************************************************************************************/

@isTest
private class CALCF_BatchUpdateSurveyToMissedTest {
    
    /***********************************************************************************
    * Data Preparation Method 
    * ---------------------------- 
    * Method to create custom settings prior to running tests. 
    ***********************************************************************************/
        @testSetup static void createBatchCustomSettings(){

        lcf_settings__c settings = new 	lcf_settings__c();
        settings.Missed_Period_In_Days__c = 30;
        insert settings;
    }
    
    /***********************************************************************************
    * Data Preparation Method
    * ---------------------------- 
    * Method to create survey data to be used in testing.
    * 6 of them will be 30 days old and will be moved to 'missed' state
    * 5 of them will be only 29 days old and will stay in 'pending' state
    ***********************************************************************************/
    @testSetup static void createTestSurveys(){
        
        // List of surveys which will be used for testing.
        list<SurveyTaker__c> testSurveys = new list<SurveyTaker__c>();
        
        Date currentDate = date.today();
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;
        
        // Create 6 surveys which needs to be moved to Missed state.
        for(integer i = 0; i < 6; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Status__c = 'Pending';
            survey.Mode__c = 'Online';
            survey.Survey_Time__c = Date.today().addDays(-30);
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Create 5 surveys which needs to stay in Pending state.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Status__c = 'Pending';
            survey.Mode__c = 'Batch';
            survey.Survey_Time__c = Date.today().addDays(-29);
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Commit to bd.
        insert testSurveys;
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* This test method will move 6 sureys to "missed" state and 5 will stay in "pending" state
    ***********************************************************************************/
    static testmethod void test_missed_surveys(){
    
    // Test start.  
    Test.startTest();
    
    // Confirmt that we have 10 surveys in the system before batch run.
    list<SurveyTaker__c> testSurveysPreBatch = [SELECT Id FROM SurveyTaker__c];
    System.assertEquals(11, testSurveysPreBatch.size());
    
    // Create and run Batch job. 
    CALCF_BatchUpdateSurveyToMissed batchJob = new CALCF_BatchUpdateSurveyToMissed();
    database.executeBatch(batchJob); 
    
    // Test end.
    Test.stopTest();
    
    // Confirm how many surveys are in Missed state and how many are in Pending state. 
    list<SurveyTaker__c> testSurveysPending = [SELECT Id FROM SurveyTaker__c WHERE Survey_Status__c = 'Pending'];
    list<SurveyTaker__c> testSurveysMissed = [SELECT Id FROM SurveyTaker__c WHERE Survey_Status__c = 'Missed'];
    System.assertEquals(5, testSurveysPending.size());
    System.assertEquals(6, testSurveysMissed.size());
    }
    
}