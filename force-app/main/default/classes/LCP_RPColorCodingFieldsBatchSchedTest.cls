@istest
public with sharing class LCP_RPColorCodingFieldsBatchSchedTest {
    public static testMethod void LCP_RPColorCodingFieldsBatchSched_Test(){
        Test.startTest();
        LCP_RPColorCodingFieldsBatchSchedulable rpColorBatchSchedule= new LCP_RPColorCodingFieldsBatchSchedulable();
        String sch = '0 0 23 * * ?';
		String jobid = system.schedule('Rp Color Code Batch Run', sch, rpColorBatchSchedule); 
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(sch,ct.CronExpression);
        Test.stopTest();
    }
}