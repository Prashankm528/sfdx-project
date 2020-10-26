/**
* @author      Avinash Jain
* @date      04/10/2019
* @description   Schedulable class for the batch class GCP_TFD_UpdateServiceConsole       
*/
global with sharing class GCP_TFD_Schedule_UpdateServiceConsole implements schedulable
{
	global void execute(SchedulableContext SC)
    {
        GCP_TFD_UpdateServiceConsole USC = new GCP_TFD_UpdateServiceConsole();
        database.executebatch(USC);
    }
}