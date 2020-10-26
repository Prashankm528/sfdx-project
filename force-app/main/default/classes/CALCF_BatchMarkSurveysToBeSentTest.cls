/************************************************************************************************************
* Description : Test class for CALCF_BatchMarkSurveysToBeSent
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-13   1.0                 Frantisek Kolacny   Initial version
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added
*
*************************************************************************************************************/
@isTest
private class CALCF_BatchMarkSurveysToBeSentTest {
	    
    /***********************************************************************************
    * Data Preparation Method 
    * ---------------------------- 
    * Method to create survey data to be used in testing.
    * It will create 17 surveys. 
    * 5 of them will have current date and will be sent
    * 5 of them will have current date +10 minutes and will not be sent
    * 5 of them will be older than 2 days and will not be sent
    * One have opted out contact
    * Last one have valid contact
    ***********************************************************************************/    
     @testSetup static void createTestSurveys(){
     	
     	lcf_settings__c settings = new lcf_settings__c();
     	settings.Do_not_send_surveys_older_than__c = 2;
     	
     	insert settings;
     		
     	// List of surveys which will be used for testing.
        list<SurveyTaker__c> testSurveys = new list<SurveyTaker__c>();
        
        Account newAccount = new Account (name = 'testname', 
        BillingCity ='TestCity', BillingCountry ='TestCountry', 
        BillingStreet ='TestStreet', BillingPostalCode ='t3stcd3');
        
        insert newAccount;
        
        Account newAccount2 = new Account (name = 'testname1', 
        BillingCity ='TestCity1', BillingCountry ='TestCountry1', 
        BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd31');
        
        insert newAccount2;
        
        Contact NewContact = new Contact (FirstName = 'xyzFirst',
        LastName = 'XyZLast',AccountId = newAccount.Id,Email = 'xyzmail@mail.com',
        Survey_Opt_Out__c = false);
        
        insert NewContact;
        
        datetime currentDate = datetime.now();
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;
     		
     	// Create 5 surveys which needs to be send.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Time__c = currentDate;
            survey.Contact__c = NewContact.Id;
            survey.Fire_Survey__c = false;
            survey.Survey_Status__c = 'Pending';
            survey.Mode__c = 'Batch';
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Create 5 surveys not need to be send.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Time__c = currentDate.addMinutes(10);
            survey.Fire_Survey__c = false;
            survey.Contact__c = NewContact.Id;
            survey.Survey_Status__c = 'Pending';
            survey.Mode__c = 'Batch';
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        // Create 5 surveys not need to be send.
        for(integer i = 0; i < 5; i++){
            SurveyTaker__c survey = new SurveyTaker__c();
            survey.Survey__c = testTemplate.id;
            survey.Survey_Time__c = currentDate.addDays(-2).addMinutes(-1);
            survey.Fire_Survey__c = false;
            survey.Contact__c = NewContact.Id;
            survey.Survey_Status__c = 'Pending';
            survey.Mode__c = 'Batch';
            survey.Sales_Organisation__c = 'AT01';
            testSurveys.add(survey);
        }
        
        Contact contactOptOut = new Contact (FirstName = 'xyzFirst1',
        LastName = 'XyZLast1',AccountId = newAccount2.Id,Email = 'xyzmail@mail1.com',
        Survey_Opt_Out__c = false, Next_Surveyable_Date__c = Datetime.Now().addDays(1).Date() );
        
        insert contactOptOut;
        
        // Create survey that will not be sent.
        SurveyTaker__c survey = new SurveyTaker__c();
        survey.Survey__c = testTemplate.id;
        survey.Survey_Time__c = currentDate;
        survey.Contact__c = contactOptOut.Id;
        survey.Fire_Survey__c = false;
        survey.Survey_Status__c = 'Pending';
        survey.Mode__c = 'Batch';
        survey.Sales_Organisation__c = 'AT01';
        testSurveys.add(survey);
        
        // Create survey that will be sent.
        SurveyTaker__c surveySent = new SurveyTaker__c();
        surveySent.Survey__c = testTemplate.id;
        surveySent.Survey_Time__c = currentDate;
        surveySent.Contact__c = NewContact.Id;
        surveySent.Fire_Survey__c = false;
        surveySent.Survey_Status__c = 'Pending';
        surveySent.Mode__c = 'Batch';
        surveySent.Sales_Organisation__c = 'AT01';
        testSurveys.add(surveySent);
                    	
        // Commit to bd.
        insert testSurveys;        
     }
     
    /***********************************************************************************
	* Test Method
	*--------------
	* This test method will send 6 surveys created in prepare method.
    * Other surveys will stay in untouched (11 of them).
    ***********************************************************************************/
    static testmethod void test_sent_surveys(){
    // Test start.  
    Test.startTest();
    
    // Confirmt that we have 15 surveys in the system before batch run.
    list<SurveyTaker__c> testSurveysPreBatch = [SELECT Id FROM SurveyTaker__c];
    System.assertEquals(17, testSurveysPreBatch.size());
    
    // Create and run Batch job. 
    CALCF_BatchMarkSurveysToBeSent batchJob = new CALCF_BatchMarkSurveysToBeSent();
    database.executeBatch(batchJob); 
    
    // Test end.
    Test.stopTest();
    
    list<SurveyTaker__c> testSurveysToBeSent = [SELECT Id FROM SurveyTaker__c WHERE Fire_Survey__c = true];
    list<SurveyTaker__c> testSurveysNotToBeSent = [SELECT Id FROM SurveyTaker__c WHERE Fire_Survey__c = false];
    System.assertEquals(6, testSurveysToBeSent.size());
    System.assertEquals(11, testSurveysNotToBeSent.size());
     	
    } 
    
}