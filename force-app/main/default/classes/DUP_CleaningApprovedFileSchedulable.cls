/*****************************************************************************************
*       Date:        15OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: schedulable class for cleaning approved document files from SF
*****************************************************************************************/
global with sharing class DUP_CleaningApprovedFileSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        DUP_CleaningApprovedFileBatchable batchDocStores = new DUP_CleaningApprovedFileBatchable();
        Database.executebatch(batchDocStores);
    }
}