/************************************************************************************************************
* Description : Schedule class for CALCF_FireSurveyReminder
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_FireSurveyReminderSchedule implements Schedulable{
	
	 global void execute(SchedulableContext sc){
   
     CALCF_FireSurveyReminder obj = new CALCF_FireSurveyReminder();
     database.executeBatch(obj);          
     }
     
}