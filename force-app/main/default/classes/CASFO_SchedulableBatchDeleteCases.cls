/*********************************************************************************************************************************************
* Description : Schedulable class used to remove Cases that have not been updated in Siebel within a defined 
* 				period of time. This time periods are within Custom Settings object : Batch_Settings__c		
*
* Date 			Version #			Author				Description
* -----------------------------------------------------------------------------------------------------------
*		
* 2016-SEP-06	1.0					Grant Whitfield		Initial version	
* 2016-SEP-26	1.1					Grant Whitfield		CASSFO-167 - Added additonal logic to consider unmodified Cases regardless of status
* 2019-MAR-19   1.2					Maros Zilka			Acting only on Cases with general record type.
* 2020-JAN-19   1.3					Ignacio Sarmiento	859685 Updated query to user Siebel Closed Date
*********************************************************************************************************************************************/

global class CASFO_SchedulableBatchDeleteCases implements Schedulable {

	// Set string for obtaining parameters from Batch_Settings__c custom setting
	public String settingName = 'BatchDeleteCases';
    
    // Genereal record type
	public String RecordTypeDevName = 'General_Case';

	// String for the SOQL query used to select records for deletion
	public String query;

	//GMT format
	String gmtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

	/************************************************************************
	* createQueryString
	* ------------------------
	* Method for calculating the date variables to be used in SOQL query
	* and generating SOQL query string to select scope of records to delete
	************************************************************************/
	public string createQueryString(){

		// Get the Custom Settings that store the parameters for controlling the SOQL query scope
		Batch_Settings__c BS = Batch_Settings__c.getValues(settingName);

		// Integer to store the number of days after which a case should be deleted 
		Integer closedCasesNotUpdatedInDays = integer.valueof(BS.Delete_Closed_Cases_After_Days__c);
		Integer allCasesNotUpdatedInDays = integer.valueof(BS.Delete_Unmodified_Cases_After_Days__c);

		// Dates to store the day to be used in selecting the records to be deleted
		Datetime closedCasesLastUpdate;
		Date unmodifiedCaseslastUpdate;

		// String to store the converted last update day, to be used in SOQL string
		String strClosedCasesLastUpdate;
		String strUnmodifiedCasesLastUpdate;

		// Check to ensure that custom settings exist
		if(closedCasesNotUpdatedInDays != null){
	
			// Set the closedCasesLastUpdate date and convert to string to be used in SOQL 
			closedCasesLastUpdate = Datetime.now();
			closedCasesLastUpdate = closedCasesLastUpdate.addDays(- closedCasesNotUpdatedInDays);
			strClosedCasesLastUpdate = closedCasesLastUpdate.formatGMT(gmtFormat);
		}

		// Check to ensure that custom settings exist
		if(allCasesNotUpdatedInDays != null){

			// Set the unmodifiedCaseslastUpdate date and convert to string to be used in SOQL 
			unmodifiedCaseslastUpdate = date.today();
			unmodifiedCaseslastUpdate = unmodifiedCaseslastUpdate.addDays(- allCasesNotUpdatedInDays);
			strUnmodifiedCasesLastUpdate = string.valueof(unmodifiedCaseslastUpdate);

		}

		query = 'SELECT Id FROM Case WHERE RecordType.DeveloperName = \'' + RecordTypeDevName + '\' AND ((isClosed = TRUE AND CASFOLCF_SiebelClosedDate__c < ' +
            	+ strClosedCasesLastUpdate + ') OR (Siebel_Last_Updated_Date__c < ' + strUnmodifiedCasesLastUpdate + '))';

        //System.debug('Query: ' + query);
		
        return query;
	}

	/********************************************************************
	* execute
	* ------------------------
	* Method to execute the schedulable interface
	********************************************************************/

	global void execute(SchedulableContext sc) {

		// Create instance of the batch job that will delete records
		CA_BatchDelete batchJob = new CA_BatchDelete();

		// Generate the SOQL query to return the scope of the records that need to be deleted from the system
		batchJob.query = createQueryString();	

		// Invoke the Delete Batch job to delete the records selected
		database.executebatch(batchJob);
		
	}

}