/************************************************************************************************************
* Description : Schedule class for CALCF_BatchHighScoringEmail
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-JAN-23   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

global class CALCF_BatchHighScoringEmailScheduler implements Schedulable{
    
     global void execute(SchedulableContext sc){
   
     CALCF_BatchHighScoringEmail obj = new CALCF_BatchHighScoringEmail();
     database.executeBatch(obj);          
     }
     
}