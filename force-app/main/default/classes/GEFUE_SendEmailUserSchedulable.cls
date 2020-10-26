/*****************************************************************************************
*   Date:           07SEPT20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Schedulable class for Email notification to users
*   Modifications:  
****************************************************************************************/
global with sharing class GEFUE_SendEmailUserSchedulable implements Schedulable{
	global void execute(SchedulableContext sc) {
        GEFUE_SendEmailUserBatchable b = new GEFUE_SendEmailUserBatchable(); 
        database.executebatch(b);
    }
}