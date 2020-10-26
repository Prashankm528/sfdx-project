/************************************************************************************************************
* Description : Batch Process for updating Survey to Expired after period of time defined in custom setting
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-09   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_BatchUpdateSurveyExpired implements Database.Batchable<sObject>{
	
   global Database.QueryLocator start(Database.BatchableContext BC){
	
		// Select all surveys flagged as Sent.
        return Database.getQueryLocator([SELECT Id, Survey_Status__c, Survey_Expiry_Date__c FROM SurveyTaker__c WHERE IsSent__c = true AND IsTaken__c = false AND Survey_Expiry_Date__c != null AND Survey_Expiry_Date__c <= TODAY]);                       
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
	
		// Surveys to update. 
		List<SurveyTaker__c> lstUpteSurveys = new List<SurveyTaker__c>();
		
        for(SurveyTaker__c Survey:(List<SurveyTaker__c>)scope){
		
			Survey.Survey_Status__c = 'Expired';
			lstUpteSurveys.add(Survey);
			System.debug('*** Survey to be updated : ***' + Survey);									
		}
		
		// Update selected surveys.
		if(!lstUpteSurveys.isEmpty()){
			try{
			
			System.debug('*** Survey to be updated as expired ***' + lstUpteSurveys);
			update lstUpteSurveys;
			}
			catch(Exception e){ 
			
                system.debug('*** Exception Occured while updating records ***' +  'Exception: ' + e.getTypeName() + ': ' + e.getMessage() + ' -- ' +  e.getCause() +'##'+  
                        e.getStackTraceString());
            }		
		}
    }

    global void finish(Database.BatchableContext BC){
    }  
}