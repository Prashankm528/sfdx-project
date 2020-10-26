/************************************************************************************************************
* Description : Tests for CALCF_BatchUpdateSurveyToMissedSchedule class
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-10   1.0                 Frantisek Kolacny   Initial version
* 2017-Mar-22   1.0                 Frantisek Kolacny   Comments added 
*
*************************************************************************************************************/
@isTest
private class CALCF_BatchUpdateSurveyToMissedScheduleT {

    /***********************************************************************************
    * Test Method
    *--------------
    * Method will test if scheduled job is created.
    ***********************************************************************************/

    static testMethod void testUpdateSurveySchedule() {

        // Test start.
        Test.startTest();

        CALCF_BatchUpdateSurveyToMissedSchedule obj = new CALCF_BatchUpdateSurveyToMissedSchedule();
        String chron = '0 0 23 * * ?';
        String jobid = System.schedule('CALCF_BatchUpdateSurveyToMissedScheduleTest', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];

        System.assertEquals(chron,ct.CronExpression);

        // Test end.
        Test.stopTest();
    }
}