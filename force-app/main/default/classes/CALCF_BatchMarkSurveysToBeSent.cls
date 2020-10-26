/************************************************************************************************************
* Description : Batch Process for updating Survey.To_be_sent__c if meet requirements.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-13   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
global class CALCF_BatchMarkSurveysToBeSent implements Database.Batchable<sObject>{
    
        
        global Database.QueryLocator start(Database.BatchableContext BC){
        	
        	lcf_settings__c settings = lcf_settings__c.getInstance();
        	
        	Datetime current = system.now();
        	Datetime fromTime = system.now().addDays(- integer.valueof(settings.Do_not_send_surveys_older_than__c));
	
			// Select all surveys which needs to be sent now and add surveys which are no more than 2 days old (can be changed in custom settings).
			// Check if contact is not opt out for surveys. 
        	return Database.getQueryLocator([SELECT Id, Fire_Survey__c, Survey_Fire_Time__c FROM SurveyTaker__c 
        	WHERE Survey_Time__c != null
        	AND Survey_Time__c > :DateTime.newInstanceGmt(fromTime.dateGMT(), fromTime.timeGmt())
        	AND Survey_Time__c <= :current
        	AND Fire_Survey__c = false 
        	AND Survey_Status__c = 'Pending'
        	AND ((Contact__r.Next_Surveyable_Date__c = null) OR (Contact__r.Next_Surveyable_Date__c <= :current.dateGMT()))
        	AND Contact__r.Survey_Opt_Out__c = false
        	AND Mode__c = 'Batch']);                       
    	}
    	
    	
    	global void execute(Database.BatchableContext BC, List<sObject> scope){
    		
    		List<SurveyTaker__c> surveysToUpdate = new List<SurveyTaker__c>();
    		
    		//Datetime sendDatetime = Datetime.newInstance(surveyDateTime.year(),surveyDateTime.month(),surveyDateTime.addDays(1).day(), surveyDateTime.hour(), surveyDateTime.minute(),0);
    		
    		for(SurveyTaker__c survey:(List<SurveyTaker__c>)scope){
    		 	survey.Fire_Survey__c = true;
    		 	survey.Survey_Fire_Time__c = datetime.now();
    		 	surveysToUpdate.add(survey);		 										
			}
			
			update surveysToUpdate;
    		
    	}
    	
    	global void finish(Database.BatchableContext BC){
    		
    	} 
}