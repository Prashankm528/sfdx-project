/************************************************************************************************************
* Description : Schedulable class for Delete Surveys batch process  
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_BatchDeleteSurveysSchedule implements Schedulable{
      

    // Set string for obtaining parameters from Batch_Settings__c custom setting
    public String settingName = 'BatchDeleteMissedSurveys';
    
    // Get the Custom Settings that store the parameters
    Batch_Settings__c BS = Batch_Settings__c.getValues(settingName);

    // Integer to store the number of days after which a survey should be deleted
    Integer surveyDaysToDelete = integer.valueof(BS.Delete_Missed_Survey_After_Days__c);
    String strDeleteDate;

    // Determine query for batch job
    public string createQueryString(){
        
        DateTime dateOfDelete = DateTime.Now().addDays(-surveyDaysToDelete);            
        String sDTTM;
        // Add crazy date time formating for query. 
        sDTTM = dateOfDelete.formatGMT('yyyy-MM-dd') + 'T' + dateOfDelete.formatGMT('HH:mm:ss.SSS') + 'Z';
        return 'SELECT Id FROM SurveyTaker__c WHERE Survey_Time__c <= ' + sDTTM + ' AND Survey_Status__c = \'Missed\'';  
        }
  
    global void execute(SchedulableContext sc){
        // Create instance of the batch job that will delete records
        CA_BatchDelete batchJob = new CA_BatchDelete();

        // Generate the SOQL query to return the scope of the records that need to be deleted from the system
        batchJob.query = createQueryString();
  
        System.debug('*** Query to be executed *** ' + batchJob.query);

        // Invoke the Delete Batch job to delete the records selected
        database.executebatch(batchJob);             
    }
}