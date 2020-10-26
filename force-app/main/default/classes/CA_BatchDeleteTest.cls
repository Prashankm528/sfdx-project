/******************************************************************************************************************************************
* Description : Unit Tests for the CA_BatchDelete Apex Class		
*
* Date 			Version #			Author				Description
* -----------------------------------------------------------------------------------------------------------
*		
* 2016-SEP-06	1.0					Grant Whitfield		Initial version	
* 2016-SEP-26	1.1					Grant Whitfield		CASSFO-167 - Added additonal logic to consider unmodified Cases regardless of status
********************************************************************************************************************************************/

@isTest
private class CA_BatchDeleteTest {

	/***********************************************************************************
	* Data Preparation Method 
	* ------------------------
	* Method to create custom settings prior to running tests. Default
	* values have settings enabled but may be changed in individual tests
	***********************************************************************************/
	@testSetup static void createBatchCustomSettings(){

		Batch_Settings__c createBS = new Batch_Settings__c();

		createBS.Name = 'BatchDeleteCases';
		createBS.Delete_Closed_Cases_After_Days__c = 90;
		createBS.Delete_Unmodified_Cases_After_Days__c = 180;

		insert createBS;
	}


	/***********************************************************************************
	* Data Preparation Method 
	* ------------------------
	* Method to create Case data to be used in testing. 
	* 40 Case records are created, but different Status and Siebel_Last_Updated_Date__c
	* to ensure scope is used correctly
	***********************************************************************************/
	@testSetup static void createTestCases(){

		// instantiate a list of cases to be used in testing of batch process
		list<Case> createTestCasesList = new list<Case>();

		// set the last updated date to today - modified with each set of records added
		Date siebelLastUpdate = date.today();

		// create 10 Closed cases that are updated outside of date range (to be deleted)
		for(integer i = 0; i < 10; i++){
			case createTestCase = new Case();
			createTestCase.Subject = 'Test Case ' + string.valueof(i);
			createTestCase.CASFOLCF_SiebelClosedDate__c = siebelLastUpdate.addDays(-100);
			createTestCase.Status = 'Closed';
			createTestCasesList.add(createTestCase);
		}


		// create 10 Closed Cases that are updated inside of date range (not to be deleted)
		for(integer i = 10; i < 20; i++){
			case createTestCase = new Case();
			createTestCase.Subject = 'Test Case ' + string.valueof(i);
			createTestCase.CASFOLCF_SiebelClosedDate__c = siebelLastUpdate.addDays(-1);
			createTestCase.Status = 'Closed';
			createTestCasesList.add(createTestCase);
		}

		// create 10 Non-Closed cases that are updated outside of date range (to be deleted)
		for(integer i = 20; i < 30; i++){
			case createTestCase = new Case();
			createTestCase.Subject = 'Test Case ' + string.valueof(i);
			createTestCase.Siebel_Last_Updated_Date__c = siebelLastUpdate.addDays(-200);
			createTestCase.Status = 'Open';
			createTestCasesList.add(createTestCase);
		}


		// create 10 Non_Closed Cases that are updated inside of date range (not to be deleted)
		for(integer i = 30; i < 40; i++){
			case createTestCase = new Case();
			createTestCase.Subject = 'Test Case ' + string.valueof(i);
			createTestCase.Siebel_Last_Updated_Date__c = siebelLastUpdate.addDays(-1);
			createTestCase.Status = 'Open';
			createTestCasesList.add(createTestCase);
		}

		// commit the Case list to db
		insert createTestCasesList;

	}

	/***********************************************************************************
	* Test Method 1
	* ------------------------
	* Checks how many Cases exist prior to running batch job, then executes batch and 
	* confirms how many Cases exist. 
	***********************************************************************************/
	static testmethod void test_method_1(){

		// Test start
		Test.startTest();

		// confirm how many cases are in the system pre-batch run
		list<Case> testCaseList = [SELECT Id, Siebel_Last_Updated_Date__c FROM CASE];
		System.assertEquals(40, testCaseList.size());

		// create instance of batch job to run
		CA_BatchDelete batchJob = new CA_BatchDelete();

		// build the query to be used in SOQL query
		CASFO_SchedulableBatchDeleteCases testClass = new CASFO_SchedulableBatchDeleteCases();
		batchJob.query = testClass.createQueryString();

		// Invoke the Delete Batch job to delete the records selected
		database.executebatch(batchJob);

		// Test end 
		Test.stopTest();		

		// confirm how many cases are in the system post-batch run across statuses
		list<Case> testCaseOpenList = [SELECT Id, Siebel_Last_Updated_Date__c FROM CASE WHERE Status = 'Open'];
		System.assertEquals(10, testCaseOpenList.size());		

		list<Case> testCaseClosedList = [SELECT Id, Siebel_Last_Updated_Date__c FROM CASE WHERE Status = 'Closed'];
		System.assertEquals(10, testCaseClosedList.size());	


	}

}