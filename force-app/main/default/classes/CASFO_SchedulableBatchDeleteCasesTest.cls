/******************************************************************************************************************
* Description : Unit Tests for the CASFO_SchedulableBatchDeleteCases Apex Class		
*
* Date 			Version #			Author				Description
* -----------------------------------------------------------------------------------------------------------
*		
* 2016-SEP-06	1.0					Grant Whitfield		Initial version	
* 2016-SEP-26	1.1					Grant Whitfield		Added additonal custom settings values for unmodified cases
* 2020-JAN-19	1.2					Ignacio Sarmiento	859685 Updated closed date to be consistent with custom settings
*******************************************************************************************************************/

@isTest
private class CASFO_SchedulableBatchDeleteCasesTest {

	// Because this is a test, job should execute immediately after Test.stopTest().
	public static String CRON_EXP = '0 0 1 * * ?';

	/********************************************************************
	* Data Preparation Method 
	* ------------------------
	* Method to create custom settings prior to running tests. 
	********************************************************************/
	@testSetup static void createBatchCustomSettings(){

		Batch_Settings__c createBS = new Batch_Settings__c();

		createBS.Name = 'BatchDeleteCases';
		createBS.Delete_Closed_Cases_After_Days__c = 180;
		createBS.Delete_Unmodified_Cases_After_Days__c = 180;

		insert createBS;
	}


	/********************************************************************
	* Test Method 1
	* ------------------------
	* Test scheduled job is created
	*
	********************************************************************/
	static testmethod void test_method_one() {

		Test.startTest();

		// schedule the job
      	String jobId = System.schedule('ScheduleBatchDeleteCasesTest', CRON_EXP, new CASFO_SchedulableBatchDeleteCases());	

		// get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		// verify the job has been created but not run
		System.assertEquals(0, ct.TimesTriggered);

		Test.stopTest();

	}

}