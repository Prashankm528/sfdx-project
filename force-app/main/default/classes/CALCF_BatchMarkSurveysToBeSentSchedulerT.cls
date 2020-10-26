/************************************************************************************************************
* Description : Tests for CALCF_BatchMarkSurveysToBeSentScheduler class
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added
*
*************************************************************************************************************/
@isTest
private  class CALCF_BatchMarkSurveysToBeSentSchedulerT {
	
	     @testSetup static void createSettings(){
     	
     	lcf_settings__c settings = new lcf_settings__c();
     	settings.Do_not_send_surveys_older_than__c = 2;
     	
     	insert settings;
	    }
	
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will test if scheduled job is created.
	***********************************************************************************/
    static testMethod void testUpdateSurveySchedule() {
    	            	    
    	// Test start.  
    	Test.startTest();
     
     	CALCF_BatchMarkSurveysToBeSentScheduler obj = new CALCF_BatchMarkSurveysToBeSentScheduler();   
     	String chron = '0 0 23 * * ?';        
     	String jobid = System.schedule('CALCF_BatchMarkSurveysToBeSentScheduler', chron, obj);
    	CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
     	System.assertEquals(chron,ct.CronExpression); 
     	    
    	// Test end.
    	Test.stopTest();
  	 	}
}