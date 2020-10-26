/**
* @author      Avinash Jain
* @date      04/10/2019
* @description    Test class for the Schedulable class GCP_TFD_UpdateServiceConsole_Schedulable       
*/
@istest
public with sharing class GCP_TFD_Schedule_UpdateSerConsole_Test
{
    //Method for executing the scheduled job...
	static testmethod void method1()
    {
        Test.startTest();
        	String sch = '0 0 23 * * ?';
        	GCP_TFD_Schedule_UpdateServiceConsole ascl = new GCP_TFD_Schedule_UpdateServiceConsole();
        	String jobId = system.schedule('Test check', sch, ascl);
        	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        	System.assertEquals(0, ct.TimesTriggered);
        Test.stoptest();
    }
}