/************************************************************************************************************
* Description : Schedule class for CALCF_BatchUpdateSurveyToMissed
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_BatchUpdateSurveyToMissedSchedule implements Schedulable{
	
	 global void execute(SchedulableContext sc){
   
     CALCF_BatchUpdateSurveyToMissed obj = new CALCF_BatchUpdateSurveyToMissed();
     database.executeBatch(obj);             
     }
     
}