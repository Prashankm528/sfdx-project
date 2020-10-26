/**
* @author      Jagannathareddy Pula
* @date      04/10/2019
* @description    Test class to test the Schedule class :GCP_TFD_CaseCloserLCScheduleClass
*/
@istest
public with sharing class GCP_TFD_Schedule_CaseCloseClass_Test
{
    //Method for executing the scheduled job...
	static testmethod void method1()
    {
        Test.startTest();
        	String sch = '0 0 23 * * ?';
        	GCP_TFD_Schedule_CaseCloseClass ascl = new GCP_TFD_Schedule_CaseCloseClass();
        	String jobId = system.schedule('Test check', sch, ascl);
        	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        	System.assertEquals(0, ct.TimesTriggered);
        Test.stoptest();
    }
}