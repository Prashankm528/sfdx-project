/************************************************************************************************************
* Description : Schedule class for CALCF_BatchMarkSurveysToBeSent
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_BatchMarkSurveysToBeSentScheduler implements Schedulable{
	
	 global void execute(SchedulableContext sc){
   
     CALCF_BatchMarkSurveysToBeSent obj = new CALCF_BatchMarkSurveysToBeSent();
     database.executeBatch(obj);          
     }
     
}