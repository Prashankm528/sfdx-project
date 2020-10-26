/************************************************************************************************************
* Description : Test class for CALCF_BatchUpdateSurveyExpired
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-09   1.0                 Frantisek Kolacny   Initial version
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added
*
*************************************************************************************************************/

@isTest
private class CALCF_BatchUpdateSurveyExpiredTest {
	
    /***********************************************************************************
    * Data Preparation Method
    * ----------------------------  
    * Method to create custom settings prior to running tests. 
    ***********************************************************************************/
   		@testSetup static void createBatchCustomSettings(){

    	lcf_settings__c settings = new 	lcf_settings__c();
    	settings.Expiry_Period_In_Days__c = 10;
    	insert settings;
    	}
    
    /***********************************************************************************
    * Data Preparation Method 
    * ---------------------------- 
    * Method to create survey data to be used in testing.
    * It will create 16 surveys. 
    * 6 of them will be 10 days old and will be moved into expired state
    * 5 of them will be 9 days old and will not be moved into expired state
    * 5 of them will have Survey_Fire_Time__c = null and will not be moved to expired
    ***********************************************************************************/
    
     @testSetup static void createTestSurveys(){
     		
     	// List of surveys which will be used for testing.
        list<SurveyTaker__c> testSurveys = new list<SurveyTaker__c>();
        
        Date currentDate = date.today();
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;
     		
     	// Create 6 surveys which needs to be moved to Expired state.
        for(integer i = 0; i < 6; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Fire_Time__c = Date.today().addDays(-10);
            survey.Survey_Status__c = 'Sent';
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Create 5 surveys which needs to stay in Sent state.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Status__c = 'Sent';
            survey.Survey_Fire_Time__c = Date.today().addDays(-9);
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Create 5 surveys which needs to stay in Sent state.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Status__c = 'Sent';
            survey.Survey_Fire_Time__c = null;
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        	
        // Commit to bd.
        insert testSurveys;        
     }
    /***********************************************************************************
	* Test Method
	*--------------
	* This test method will "expire" 6 sureys and 10 will stay in "sent" state
    ***********************************************************************************/
    static testmethod void test_expired_surveys(){
    // Test start.  
    Test.startTest();
    
    // Confirmt that we have 11 surveys in the system before batch run.
    list<SurveyTaker__c> testSurveysPreBatch = [SELECT Id FROM SurveyTaker__c];
    System.assertEquals(16, testSurveysPreBatch.size());
    
    // Create and run Batch job. 
    CALCF_BatchUpdateSurveyExpired batchJob = new CALCF_BatchUpdateSurveyExpired();
    database.executeBatch(batchJob); 
    
    // Test end.
    Test.stopTest();
    
    list<SurveyTaker__c> testSurveysSent = [SELECT Id FROM SurveyTaker__c WHERE Survey_Status__c = 'Sent'];
    list<SurveyTaker__c> testSurveysExpired = [SELECT Id FROM SurveyTaker__c WHERE Survey_Status__c = 'Expired'];
    System.assertEquals(10, testSurveysSent.size());
    System.assertEquals(6, testSurveysExpired.size());
     	
     }    
}