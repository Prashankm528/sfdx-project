/*****************************************************************************************
*   Date:           07SEPT20
*   Author:         Atanu Ghosh – TCS (Tata Consultancy Services Ltd.)
*   Description:    Server-side controller for Mass Upload
*   Modifications:  
****************************************************************************************/
global with sharing class GEFUE_SendEmailOpportunitySchedulable implements Schedulable{
    global void execute(SchedulableContext ctx) {
        GEFUE_SendEmailOpportunityBatchable sendEmailOppty = new GEFUE_SendEmailOpportunityBatchable();
        database.executebatch(sendEmailOppty,200);
    }
}