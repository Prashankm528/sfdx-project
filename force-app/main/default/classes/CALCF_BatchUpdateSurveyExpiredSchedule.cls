/************************************************************************************************************
* Description : Schedule class for CALCF_BatchUpdateSurveyExpired
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_BatchUpdateSurveyExpiredSchedule implements Schedulable{
	
	 global void execute(SchedulableContext sc){
   
     CALCF_BatchUpdateSurveyExpired obj = new CALCF_BatchUpdateSurveyExpired();
     database.executeBatch(obj);          
     }
     
}