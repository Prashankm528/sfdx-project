/************************************************************************************************************
* Description : Batch Process for sending reminder email to customer.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-MAY-16   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
global class CALCF_FireSurveyReminder implements Database.Batchable<sObject>{
	
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		 	
    Datetime current = system.now();
	
	// Select all surveys for which reminder need to be sent. 
	// Check if contact is not opt out for surveys. 
    return Database.getQueryLocator([SELECT Id, Fire_Reminder__c FROM SurveyTaker__c 
    WHERE Survey_Reminder_Date__c <= :current
    AND Fire_Survey__c = true
    AND Fire_Reminder__c = false
    AND Survey_Status__c = 'Sent'
    AND Contact__r.Survey_Opt_Out__c = false 
    AND Mode__c = 'Batch']);
                           
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    		
    	List<SurveyTaker__c> surveysToUpdate = new List<SurveyTaker__c>();
		
    	for(SurveyTaker__c survey:(List<SurveyTaker__c>)scope){
    	 	survey.Fire_Reminder__c = true;
    	 	surveysToUpdate.add(survey);		 										
		}
			
		// Fire Reminder field will be updated for all surveys for which reminder need to be sent. 
		update surveysToUpdate;
    		
    }
    	
    global void finish(Database.BatchableContext BC){
    	
    } 
    
}