/**
 * @author Jewelslyn Shama P
 * @company Tata Consultancy Services
 * @date 
 * @group Fuels
 * @description      Test class for OLCM_AccountMarkForDeleteSchedule
 */

@istest
private class OLCM_AccountMarkForDeleteScheduleTest{    
     static testMethod void AccountMarkForDeleteSchedule(){
         String sch = '0 0 23 * * ?';
         Test.startTest();
        OLCM_AccountMarkForDeleteSchedule accDeleteSchedule = new OLCM_AccountMarkForDeleteSchedule();      
        
        String jobid = System.schedule('OLCM_AccountMarkForDeleteSchedule', sch, accDeleteSchedule);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        
        Test.stopTest();
         System.assertEquals(sch,ct.CronExpression,'ck value');
        }
}