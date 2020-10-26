/**
* @author    Jagannathareddy Pula
* @date      04/10/2019
* @description    Schedule class to execute Batch apex class :GCP_TFD_BatchApexAutomatedCaseCloserLC
*/
global with sharing class GCP_TFD_Schedule_CaseCloseClass implements schedulable
{
    /**
* @description execute method for Schedulable class
*/
	global void execute(SchedulableContext SC)
    {
        GCP_TFD_Batch_AutomatedCaseClose abc = new GCP_TFD_Batch_AutomatedCaseClose();
        database.executebatch(abc);
    }
}