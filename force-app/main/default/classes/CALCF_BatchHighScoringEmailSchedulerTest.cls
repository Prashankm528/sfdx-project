/************************************************************************************************************
* Description : Tests for CALCF_BatchHighScoringEmailScheduler class
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-JAN-29   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
@isTest
private  class CALCF_BatchHighScoringEmailSchedulerTest {
    
    /***********************************************************************************
    * Test Method
    *--------------
    * Method will test if scheduled job is created.
    ***********************************************************************************/
    static testMethod void testUpdateSurveySchedule() {
                            
        // Test start.  
        Test.startTest();
     
        CALCF_BatchHighScoringEmailScheduler obj = new CALCF_BatchHighScoringEmailScheduler();   
        String chron = '0 0 23 * * ?';        
        String jobid = System.schedule('CALCF_BatchHighScoringEmailScheduler', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
            
        // Test end.
        Test.stopTest();
        }
}