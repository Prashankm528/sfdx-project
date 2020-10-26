/************************************************************************************************************
* Description : Test class for CALCF_SurveyTakerUpdateTimeHandler
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-12   1.0                 Frantisek Kolacny   Initial version
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added  
*
*************************************************************************************************************/

@isTest
private class CALCF_SurveyTakerUpdateTimeHandlerTest {
	
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will check if time on survey will be updated according to contact. 
    * Method will test part of code responsible for positive timeshift.
    ***********************************************************************************/
    static testmethod void test_positive_values_of_timeshift(){
    	            	    
    	// Test start.  
    	Test.startTest();
    	
    	// Arrange. 
    	Map<Id, Contact> contactMap = new Map<Id, Contact>();
	 	Contact newContact = new Contact();
	 	newContact.TimeZone__c = '(GMT+09:30) Darwin';
	 	contactMap.put(newContact.id, newContact);
	 	
    	CALCF_SurveyTakerUpdateTimeHandler.NOW = Datetime.newInstanceGmt(2017, 1, 1, 12, 0, 0);
    	list<SurveyTaker__c> surveyLst = prepareSurvey(newContact);
    	
    	// Act.
    	CALCF_SurveyTakerUpdateTimeHandler.updateSurveyTimeAccordingToContact(surveyLst, contactMap);
    	
    	// Assert. 
    	System.assertEquals(Datetime.newInstanceGmt(2017, 1, 2, 5, 30, 0), surveyLst[0].Survey_Time__c); 
     	    
    	// Test end.
    	Test.stopTest();
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will check if time on survey will be updated according to contact. 
    * Method will test part of code responsible for negative timeshift.
    ***********************************************************************************/
    static testmethod void test_negative_values_of_timeshift(){
    	            	    
    	// Test start.  
    	Test.startTest();
    	
    	// Arrange. 
    	Map<Id, Contact> contactMap = new Map<Id, Contact>();
	 	Contact newContact = new Contact();
	 	newContact.TimeZone__c = '(GMT-05:00) Eastern Time (US & Canada)';
	 	contactMap.put(newContact.id, newContact);
	 	
    	CALCF_SurveyTakerUpdateTimeHandler.NOW = Datetime.newInstanceGmt(2017, 1, 1, 12, 0, 0);
    	list<SurveyTaker__c> surveyLst = prepareSurvey(newContact);
    	
    	// Act.
    	CALCF_SurveyTakerUpdateTimeHandler.updateSurveyTimeAccordingToContact(surveyLst, contactMap);
    	
    	// Assert.
    	System.assertEquals(Datetime.newInstanceGmt(2017, 1, 1, 20, 00, 0), surveyLst[0].Survey_Time__c); 
     	    
    	// Test end.
    	Test.stopTest();
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will check if time on survey will be updated according to contact. 
    * Method will test part of code responsible GMT.
    ***********************************************************************************/
    static testmethod void test_zero_values_of_timeshift(){
    	            	    
    	// Test start.  
    	Test.startTest();
    	
    	// Arrange. 
    	Map<Id, Contact> contactMap = new Map<Id, Contact>();
	 	Contact newContact = new Contact();
	 	newContact.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
	 	contactMap.put(newContact.id, newContact);
	 	
    	CALCF_SurveyTakerUpdateTimeHandler.NOW = Datetime.newInstanceGmt(2017, 1, 1, 12, 0, 0);
    	list<SurveyTaker__c> surveyLst = prepareSurvey(newContact);
    	
    	// Act.
    	CALCF_SurveyTakerUpdateTimeHandler.updateSurveyTimeAccordingToContact(surveyLst, contactMap);
    	
    	// Assert.
    	System.assertEquals(Datetime.newInstanceGmt(2017, 1, 1, 15, 00, 0), surveyLst[0].Survey_Time__c); 
     	    
    	// Test end.
    	Test.stopTest();
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will check if time on survey will be updated according to contact. 
    * Method will test part of code responsible for negative timeshift.
    ***********************************************************************************/
    static testmethod void test_negative_values_of_timeshift_next_day(){
    	            	    
    	// Test start.  
    	Test.startTest();
    	
    	// Arrange. 
    	Map<Id, Contact> contactMap = new Map<Id, Contact>();
	 	Contact newContact = new Contact();
	 	newContact.TimeZone__c = '(GMT-02:00) Mid-Atlantic';
	 	contactMap.put(newContact.id, newContact);
	 	
    	CALCF_SurveyTakerUpdateTimeHandler.NOW = Datetime.newInstanceGmt(2017, 1, 1, 18, 0, 0);
    	list<SurveyTaker__c> surveyLst = prepareSurvey(newContact);
    	
    	// Act.
    	CALCF_SurveyTakerUpdateTimeHandler.updateSurveyTimeAccordingToContact(surveyLst, contactMap);
    	
    	// Assert.
    	System.assertEquals(Datetime.newInstanceGmt(2017, 1, 2, 17, 00, 0), surveyLst[0].Survey_Time__c); 
     	    
    	// Test end.
    	Test.stopTest();
    }
     
    private static list<SurveyTaker__c> prepareSurvey(Contact contact){

		list<SurveyTaker__c> result = new list<SurveyTaker__c>();
        SurveyTaker__c survey = new SurveyTaker__c();
        survey.Contact__c = contact.id;
        result.add(survey);
        return result;
    }
}