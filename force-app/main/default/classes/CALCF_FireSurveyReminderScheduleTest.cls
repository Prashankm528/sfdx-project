/*****************************************************************************************
*	    Date:		    20APR2020
*       Author:         Rahma Belghouti - Infosys
*       Description:    Test CALCF_FireSurveyReminderSchedule class
*       Modifications:  
****************************************************************************************/
@isTest
private with sharing class CALCF_FireSurveyReminderScheduleTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    

    @testSetup static void setupData(){
     		
     	lcf_settings__c setting = new lcf_settings__c();
     	setting.Send_Reminder_After_Days__c = 5;
     	insert setting;
     	
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
     		
     	// Create 5 surveys for which we need to send Reminder.
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
        
        // Create 5 surveys for which we do NOT need to send Reminder.
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


    @isTest static void itShouldCreateReminderForSurveys(){
        
        test.startTest();
        CALCF_FireSurveyReminderSchedule scheduler= new CALCF_FireSurveyReminderSchedule();
        scheduler.execute(null);
        
        //Verify that the job has not run yet
        Id surveyTemplateId = [SELECT Id FROM Survey__c WHERE Name='testtest'].Id;
        List<SurveyTaker__c> surveys = [SELECT Id, Fire_Reminder__c 
                                         FROM SurveyTaker__c
                                         WHERE Fire_Reminder__c = true AND Survey__c = :surveyTemplateId];
        System.assertEquals(0, surveys.size());
        test.stopTest();
        
        //Verify that the job has run and created the reminder
        surveys = [SELECT Id, Fire_Reminder__c 
                                         FROM SurveyTaker__c
                                         WHERE Fire_Reminder__c = true AND Survey__c = :surveyTemplateId];
        System.assertEquals(5, surveys.size());
    }
}