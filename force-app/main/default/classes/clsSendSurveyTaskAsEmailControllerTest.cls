/************************************************************************************************************
* Description : Tests for clsSendSurveyTaskAsEmailController class 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JUL-11   1.0                 Frantisek Kolacny    Initial version 
*
*************************************************************************************************************/
@isTest
private class clsSendSurveyTaskAsEmailControllerTest {
	
	/********************************************************************
	* Data Preparation Method 
	* ------------------------
	* Method to create data prior to running tests. 
	********************************************************************/
	private static string createData(){
		
		// New account.
        Account acc = new Account();
        acc.Name = 'David Gilmour';
        acc.Account_ERP_ID__c = '123456789';
        acc.Alias__c = 'auto';
        acc.Business_Unit__c = 'Lubricants - Automotive'; 
    	acc.Type = 'Competitor';
    	acc.Phone = '+4490923902323';
    	acc.BillingStreet = 'street';
    	acc.BillingCity = 'Banska Bystrica';
    	acc.BillingState = 'ACT';
    	acc.BillingPostalCode = '040 11';
    	acc.BillingCountry = 'Slovakia';
    	acc.Account_Siebel_ID__c = '987654321';
        
        insert acc;
        
        // New contact.    
        Contact con = new Contact();
        con.FirstName = 'David';
        con.LastName = 'Gilmour';
        con.AccountId = acc.Id;
        con.Email = 'david@ibm.com';
        con.Home_Location__c = 'United Kingdom';
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Preferred_Language__c = 'English-British';
        con.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        con.Contact_Siebel_Id__c = '12345';
        
        insert con; 
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        insert testTemplate;
        
        SurveyTaker__c survey = new SurveyTaker__c();
        survey.Survey__c = testTemplate.id;
        survey.Account__c = acc.Id;
        survey.Contact__c = con.Id;
        survey.Sales_Organisation__c = 'UK01';
        survey.Reference_Number__c = '123';
         
        insert survey;
                       
        Task myTask = new Task();
        myTask.whatid = survey.Id;
        
        insert myTask;
        
        return myTask.Id; 
	}
	
	/********************************************************************
	* Test Method
	* ------------------------
	* Mathod will test getting all reqired Account data 
	********************************************************************/
	static testmethod void getAccountDataTest(){
    	
    	// Arrange;
    	string taskId = createData();
    	Test.startTest();
    	clsSendSurveyTaskAsEmailController target = new clsSendSurveyTaskAsEmailController();
    	target.taskId = taskId;
    	
    	// Act
    	Account result = target.getaccountData();

		// Assert
    	System.assertEquals('David Gilmour', result.Name);
    	System.assertEquals('123456789', result.Account_ERP_ID__c); 
    	System.assertEquals('auto', result.Alias__c); 
    	System.assertEquals('Lubricants - Automotive', result.Business_Unit__c); 
    	System.assertEquals('Competitor', result.Type); 
    	System.assertEquals('+4490923902323', result.Phone);
		System.assertEquals('Banska Bystrica', result.BillingCity); 
		System.assertEquals('ACT', result.BillingState); 
		System.assertEquals('040 11', result.BillingPostalCode); 
		System.assertEquals('Slovakia', result.BillingCountry); 
		System.assertEquals('987654321', result.Account_Siebel_ID__c); 
   	   	
    	Test.stopTest();
    }
    
    /********************************************************************
	* Test Method
	* ------------------------
	* Mathod will test getting all reqired Survey data 
	********************************************************************/
	static testmethod void getSurveyDataTest(){
    	
    	// Arrange;
    	string taskId = createData();
    	Test.startTest();
    	clsSendSurveyTaskAsEmailController target = new clsSendSurveyTaskAsEmailController();
    	target.taskId = taskId;
    	
    	// Act
    	SurveyTaker__c result = target.getsurveyData();

		// Assert
		System.assertEquals('123', result.Reference_Number__c);
   	   	System.assertEquals('12345', result.Contact__r.Contact_Siebel_Id__c);
   	   	System.assertEquals('David Gilmour', result.Contact__r.Name);
   	   	
    	Test.stopTest();
    }
    
}