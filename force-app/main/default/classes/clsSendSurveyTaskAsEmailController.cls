/*********************************************************************************************************************************************
* Description : Apex Controller for Survey Task Email Body component. Used for various opeations:
*  - getaccountData
*  - getsurveyData
*  - getresponsesData

* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------       
* 2017-JUL-11   1.0                 Frantisek Kolacny    Initial version 
/*********************************************************************************************************************************************/
public class clsSendSurveyTaskAsEmailController {
	
	public String taskId {get; set;}
	public String taskParentId;
	public String taskType;
	public Task myTask;
	   
    /***********************************************************************************
    * getaccountData
    * ------------------------
    * Method will return all required data of Account which will be shown on email template. 
    ***********************************************************************************/
    
    public Account getaccountData(){
    	
    	loadTaskData();
    	
    	List<SurveyTaker__c> survey = [SELECT  Name, Account__c, Account__r.Sales_Organisation__c, Account__r.Name, Account__r.Account_ERP_ID__c, Account__r.Alias__c,
        Account__r.Business_Unit__c, Account__r.Type , Account__r.Phone , Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
        Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.Account_Siebel_ID__c, Reference_Number__c, Contact__r.Name, 
        Record_Type_Name__c, Contact__r.Contact_Siebel_Id__c  FROM SurveyTaker__c Where Id = :myTask.whatId];
                
        Account myAcc = new Account();
               
        if (survey.size() > 0) {
        	        	
        	myAcc.Name = survey[0].Account__r.Name;
        	myAcc.Account_ERP_ID__c = survey[0].Account__r.Account_ERP_ID__c;
        	myAcc.Alias__c = survey[0].Account__r.Alias__c;
        	myAcc.Business_Unit__c = survey[0].Account__r.Business_Unit__c;
    		myAcc.Type = survey[0].Account__r.Type;
    		myAcc.Phone = survey[0].Account__r.Phone;
    		myAcc.BillingStreet = survey[0].Account__r.BillingStreet;
    		myAcc.BillingCity = survey[0].Account__r.BillingCity;
    		myAcc.BillingState = survey[0].Account__r.BillingState;
    		myAcc.BillingPostalCode = survey[0].Account__r.BillingPostalCode;
    		myAcc.BillingCountry = survey[0].Account__r.BillingCountry;
    		myAcc.Account_Siebel_ID__c = survey[0].Account__r.Account_Siebel_ID__c;
        }
        
    	return myAcc;
    	
    } 
    
    /***********************************************************************************
    * getsurveyData
    * ------------------------
    * Method will return all required data of Survey which will be shown on email template. 
    ***********************************************************************************/
    
    public SurveyTaker__c getsurveyData(){
    	
    	loadTaskData();
    	
    	List<SurveyTaker__c> survey = [SELECT Reference_Number__c, Contact__r.Name, Record_Type_Name__c, Contact__r.Contact_Siebel_Id__c 
    	FROM SurveyTaker__c Where Id = :myTask.whatId];
    	
    	if (survey.size() > 0) {
    		
    		return survey[0];
    	}else{
    		
    		return null;
    	}
	    	
    }
    
    /***********************************************************************************
    * getresponsesData
    * ------------------------
    * Method will return all required data of Survey Question Responses which will be shown on email template. 
    ***********************************************************************************/
    
    public list<SurveyQuestionResponse__c> getresponsesData(){
    	
    	loadTaskData();
    	
    	list<SurveyQuestionResponse__c> responses = [SELECT lcf_Survey_Question__c, Response__c FROM SurveyQuestionResponse__c Where SurveyTaker__c = :myTask.whatId];
    	
    	if (responses.size() > 0) {
    		
    		return responses;
    	}else{
    		
    		return null;
    	}
	    	
    }
    
    public void loadTaskData(){
    		
    	myTask = [SELECT Id, what.type, whatId FROM Task WHERE Id = :taskId];    	 
   		
    }
     
     
}