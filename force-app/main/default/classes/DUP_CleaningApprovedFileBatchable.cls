/*****************************************************************************************
*       Date:        14OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: batchable class for cleaning approved document files from SF
*       Update:      it cleans rejected files too
*****************************************************************************************/
global with sharing class DUP_CleaningApprovedFileBatchable implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT DUP_Document_Request__c
                                         FROM DUP_Document_Store__c 
                                         WHERE (DUP_Document_Status__c = 'Reviewed'
                                            AND DUP_Document_Request__r.DUP_ApprovedDate__c = LAST_N_DAYS:15)
                                            OR DUP_Document_Request__r.CreatedDate = LAST_N_DAYS:30
                                         ]);
    }
    
    global void execute(Database.BatchableContext BC, List<DUP_Document_Store__c> docStoreList) {
        Set<Id> contentDocumentIdToBeDeletedSet = new Set<Id>();
        Set<Id> docStoreIdSet = (new Map<Id,DUP_Document_Store__c>(docStoreList)).keySet();
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId,
                                                                ContentDocument.LatestPublishedVersion.DUP_Status__c
                                                            FROM ContentDocumentLink
                                                            WHERE LinkedEntityId IN :docStoreIdSet
                                                                AND (ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Rejected'
                                                                OR ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Sent to Sharepoint')];
        
        for (ContentDocumentLink cdl : contentDocumentLinkList){
            contentDocumentIdToBeDeletedSet.add(cdl.ContentDocumentId);
        }

        List<Id> contentDocumentIdToBeDeletedList = new List<Id>(contentDocumentIdToBeDeletedSet);

        try {
            if(!contentDocumentIdToBeDeletedList.isEmpty()){
                Database.delete(contentDocumentIdToBeDeletedList);
            }
        } catch (DmlException e){
            System.debug('An error during has occurred: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}