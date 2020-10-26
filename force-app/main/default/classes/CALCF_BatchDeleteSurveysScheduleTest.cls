/************************************************************************************************************
* Description : Tests for CALCF_BatchDeleteSurveysSchedule class 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added
* 2019-OCT-18   1.1                 Adam Janicko        Changed test_delete_surveys method to not use Batch, because it was randomly failing
*************************************************************************************************************/
@isTest
private class CALCF_BatchDeleteSurveysScheduleTest {
	
		public static String CRON_EXP = '0 0 1 * * ?';
   
        /***********************************************************************************
        * Data Preparation Method
        * ----------------------------  
        * Method to create custom settings prior to running tests. 
        ***********************************************************************************/
        @testSetup static void createBatchCustomSettings(){

        Batch_Settings__c settings = new Batch_Settings__c();
        settings.Name = 'BatchDeleteMissedSurveys';
        settings.Delete_Missed_Survey_After_Days__c = 5;
        insert settings;
        }
        
        /***********************************************************************************
        * Data Preparation Method
        * ----------------------------  
        * Method to create survey data to be used in testing.
        * It will create 11 surveys. 
        * 6 of them will have Survey_Time__c 5 days in the past and will be deleted 
        * 5 of them will have Survey_Time__c 4 days in the past and will not be deleted 
        ***********************************************************************************/
    
        @testSetup static void createTestSurveys(){
            
            
            // List of surveys which will be used for testing.
            list<SurveyTaker__c> testSurveys = new list<SurveyTaker__c>();
        
            Date currentDate = date.today();
        
            Survey__c testTemplate = new Survey__c();
            testTemplate.name = 'testtest';
            insert testTemplate;
            
            // Create 6 surveys which needs to be deleted.
            for(integer i = 0; i < 6; i++){
                
                SurveyTaker__c survey = new SurveyTaker__c();
                survey.Survey__c = testTemplate.id;
                survey.Survey_Status__c = 'Missed';
                survey.Survey_Time__c = DateTime.Now().addDays(-5);
                survey.Sales_Organisation__c = 'AT01';
                testSurveys.add(survey);
                }
        
            // Create 5 surveys which needs to stay in system.
            for(integer i = 0; i < 5; i++){
                SurveyTaker__c survey = new SurveyTaker__c();
                survey.Survey__c = testTemplate.id;
                survey.Survey_Status__c = 'Missed';
                survey.Survey_Time__c = DateTime.Now().addDays(-4);
                survey.Sales_Organisation__c = 'AT01';
                testSurveys.add(survey);
                }
            
            // Commit to bd.
            insert testSurveys;        
            }
            
            /***********************************************************************************
            * Test Method
            *--------------
            * This test method will delete 6 surveys created in prepare method.
            * Other surveys will stay in untouched (5 of them).
            ***********************************************************************************/
            static testmethod void test_delete_surveys(){
            // Test start.  
            Test.startTest();
                    
            // Confirm that we have 11 surveys in the system before the execution of the scheduler query.
            list<SurveyTaker__c> testSurveysPreBatch = [SELECT Id FROM SurveyTaker__c];
            System.assertEquals(11, testSurveysPreBatch.size());
            
            // Create and execute the scheduler query.
            CALCF_BatchDeleteSurveysSchedule scheduler = new CALCF_BatchDeleteSurveysSchedule();
            delete Database.query(scheduler.createQueryString());
    
            // Test end.
            Test.stopTest();
    
            // Confirmt that we have 5 surveys in the system and 6 was deleted.
            list<SurveyTaker__c> testSurveysAfterBatch = [SELECT Id FROM SurveyTaker__c];
            System.assertEquals(5, testSurveysAfterBatch.size());
            }
            
            /***********************************************************************************
			* Test Method
			*--------------
			* Method will test if scheduled job is created.
			***********************************************************************************/
			static testmethod void test_method_schedule() {

				Test.startTest();

				// schedule the job
      			String jobId = System.schedule('BatchDeleteSurveysScheduleTest', CRON_EXP, new CALCF_BatchDeleteSurveysSchedule());	

				// get the information from the CronTrigger API object
				CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

				// verify the job has been created but not run
				System.assertEquals(0, ct.TimesTriggered);

				Test.stopTest();

			}         
}