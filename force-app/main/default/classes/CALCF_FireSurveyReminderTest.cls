/************************************************************************************************************
* Description : Test class for clsFireSurveyReminder
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-MAY-16   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
@isTest
private class CALCF_FireSurveyReminderTest {
		 
    @testSetup static void createTestSurveys(){
     		
     	lcf_settings__c settings = new lcf_settings__c();
     	settings.Send_Reminder_After_Days__c = 5;
     	
     	insert settings;
     	
     	// List of surveys which will be used for testing.
        list<SurveyTaker__c> testSurveys = new list<SurveyTaker__c>();
        
        Account newAccount = new Account (name = 'testname', 
        BillingCity ='TestCity', BillingCountry ='TestCountry', 
        BillingStreet ='TestStreet', BillingPostalCode ='t3stcd3');
        
        insert newAccount;
        
        Contact NewContact = new Contact (FirstName = 'xyzFirst',
        LastName = 'XyZLast',AccountId = newAccount.Id,Email = 'xyzmail@mail.com',
        Survey_Opt_Out__c = false);
        
        insert NewContact;
        
        datetime currentDate = system.now();
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;
     		
     	// Create 5 surveys for which we need to send Remnder.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Time__c = currentDate.addDays(-5);
            survey.Contact__c = NewContact.Id;
            survey.Fire_Survey__c = true;
            survey.Fire_Reminder__c = false;
            survey.Survey_Status__c = 'Sent';
            survey.Mode__c = 'Batch';
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Create 5 surveys for which we do NOT need to send Remnder.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Time__c = currentDate.addDays(-4);
            survey.Fire_Survey__c = true;
            survey.Fire_Reminder__c = false;
            survey.Contact__c = NewContact.Id;
            survey.Survey_Status__c = 'Sent';
            survey.Mode__c = 'Batch';
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }    
        
        insert testSurveys;     
     }
     
    /***********************************************************************************
	* Test Method
	*--------------
	* This test method will fire 5 Reminders.
    ***********************************************************************************/
    static testmethod void test_missed_surveys(){
    	
    // Test start.  
    Test.startTest();
    
    // Confirmt that we have 10 surveys in the system before batch run.
    list<SurveyTaker__c> testSurveysPreBatch = [SELECT Id FROM SurveyTaker__c];
    System.assertEquals(10, testSurveysPreBatch.size());
    
    
    // Create and run Batch job. 
    CALCF_FireSurveyReminder batchJob = new CALCF_FireSurveyReminder();
    database.executeBatch(batchJob); 
    
    // Test end.
    Test.stopTest();
    
    // Confirm how many surveys are in Missed state and how many are in Pending state. 
    list<SurveyTaker__c> testReminderSent = [SELECT Id FROM SurveyTaker__c WHERE Fire_Reminder__c = true];
    list<SurveyTaker__c> testReminderNOTSent= [SELECT Id FROM SurveyTaker__c WHERE Fire_Reminder__c = false];
    System.assertEquals(5, testReminderSent.size());
    System.assertEquals(5, testReminderNOTSent.size()); 
    	
    }
}