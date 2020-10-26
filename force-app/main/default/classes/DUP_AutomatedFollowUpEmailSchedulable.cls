/*****************************************************************************************
*       Date:        14OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: schedulable class for automated follow up email
*****************************************************************************************/
global with sharing class DUP_AutomatedFollowUpEmailSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        DUP_AutomatedFollowUpEmailBatch batchDocStores = new DUP_AutomatedFollowUpEmailBatch();
        Database.executebatch(batchDocStores);
    }
}