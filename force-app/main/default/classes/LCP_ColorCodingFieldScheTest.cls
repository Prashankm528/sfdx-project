@istest
public with sharing class LCP_ColorCodingFieldScheTest {
    public static testMethod void LCP_ColorCodingFieldSchedule_Test(){
        Test.startTest();
        LCP_ColorCodingFieldsBatchSchedulable ColorBatchSchedule= new LCP_ColorCodingFieldsBatchSchedulable();
        String sch = '0 0 23 * * ?';
		String jobid = system.schedule('Color Code Batch Run', sch, ColorBatchSchedule); 
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(sch,ct.CronExpression);
        Test.stopTest();
    }
}