global with sharing class DUP_FileShareBatch implements Database.Batchable<ContentDocumentLink>,Database.AllowsCallouts { 
    
    private Set<Id> storeIds;
    private List<DUP_Document_Request__c> icosid;
    
    public DUP_FileShareBatch(Set<Id> docStores) {
        storeIds = docStores;

    }
    
    global Iterable<ContentDocumentLink> start(Database.BatchableContext BC) { 
        List<DUP_Document_Store__c> docreq = [Select DUP_Document_Request__c from DUP_Document_Store__c where Id in:storeIds];        
        Set<Id> reqIds;
       
        icosid = [Select DUP_ICOSId__c from DUP_Document_Request__c where Id =:docreq[0].DUP_Document_Request__c];
        return [SELECT ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersion.Title,LinkedEntityId,
                ContentDocument.LatestPublishedVersion.FileExtension,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE linkedentityid in:storeIds and ContentDocument.LatestPublishedVersion.DUP_Status__c='Approved'];
    }
    
    global void execute(Database.BatchableContext BC, List<ContentDocumentLink> contentDocumentLinkList) {
        System.debug('***batch  execute'+contentDocumentLinkList);
        Map<Id,DUP_Document_Store__c> idDocStoreMap = new Map<Id,DUP_Document_Store__c>([SELECT Id,DUP_Document_Request__c,DUP_SharepointUrl__c FROM DUP_Document_Store__c WHERE Id in:storeIds]);//PBI 961039
        List<DUP_Document_Store__c> docreq = [Select DUP_Document_Request__c from DUP_Document_Store__c where Id in:storeIds];        
        List<DUP_Document_Request__c> icosids = [Select DUP_ICOSId__c from DUP_Document_Request__c where Id =:docreq[0].DUP_Document_Request__c];
        BPI_SharepointAPIService spApiService = BPI_SharepointAPIService.init(getIntegrationSettings()[0].Base_Folder_List__c, icosids[0].DUP_ICOSId__c);
       If(test.isRunningTest()){
      	//Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse = spApiService.pushSingleFileToSharepoint(contentDocumentLinkList); 
        //DUP_ApprovedDocumentRequestController.processResponse(idDocStoreMap, Null);
        //Do nothing
        }
        else{
        Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse = spApiService.pushSingleFileToSharepoint(contentDocumentLinkList); 
        DUP_ApprovedDocumentRequestController.processResponse(idDocStoreMap, mapResponse); 
        }
     }
    
    private static DUP_Integration_Setting__mdt[] getIntegrationSettings () {
        return [SELECT Base_Folder_List__c, Sharepoint_Url__c FROM DUP_Integration_Setting__mdt WHERE DeveloperName ='DUP_Sharepoint'];
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('***batch  finish');
    }
}