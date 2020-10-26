/*****************************************************************************************
*       Date:           18OCT19
*       Author:         Alessandro Miele - IBM
*       Description:    Controller class for DUP_ApprovedDocumentRequestView and 
*                       DUP_ReviewedDocumentStoreView
*****************************************************************************************/

public With Sharing class DUP_ApprovedDocumentRequestController {

    public class FileInfo {
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String status;
    }

    public class LoadDataWrapper{
        @AuraEnabled
        public List<ContentDocumentLink> contentDocumentLinkList {get;set;}
        @AuraEnabled
        public List<FileInfo> fileInfoList {get;set;}
    }
    
    private static DUP_Integration_Setting__mdt[] getIntegrationSettings () {
        return [SELECT Base_Folder_List__c, Sharepoint_Url__c FROM DUP_Integration_Setting__mdt WHERE DeveloperName ='DUP_Sharepoint'];
    }
         
    /**
	* @description:	method used in the init to initialise the component
	* @param: document request id
	* @return: list of DUP_Document_Store__c against the param Id
	*/    
    @AuraEnabled
    public static List<DUP_Document_Store__c> getDocumentStore(Id docRequestId){
        List<DUP_Document_Store__c> documentList = [SELECT Name,
                DUP_Options__c,
                DUP_Document_Status__c,
                DUP_Document_Name__c,
                DUP_Requested__c,
                DUP_Document_Request__r.Id,
                DUP_SharepointUrl__c 
            FROM DUP_Document_Store__c 
            WHERE DUP_Document_Request__r.Id =: docRequestId 
                AND DUP_Requested__c = true
        ];     
        return documentList; 
    } 

    /**
	* @description:	method used to send a file linked to a DUP_Document_Store__c to SP
	* @param: document store 
	* @return: void
	*/      
    @AuraEnabled
    public static LoadDataWrapper sendFileToSharepoint(DUP_Document_Store__c docStore, Id contentVersionId){
       
        Map<Id,DUP_Document_Store__c> idDocStoreMap = new Map<Id,DUP_Document_Store__c>([SELECT Id,DUP_Document_Request__c,DUP_SharepointUrl__c FROM DUP_Document_Store__c WHERE Id= :docStore.Id]);//PBI 961039
        //idDocStoreMap.put(docStore.Id, docStore);
        Set<Id> docStoreIdSet = idDocStoreMap.keySet();

        DUP_Document_Request__c docRequest = [SELECT DUP_ICOSId__c  FROM DUP_Document_Request__c WHERE Id = :docStore.DUP_Document_Request__c];
        String subfolder = docRequest.DUP_ICOSId__c ;
        List<ContentDocumentLink> contentDocumentLinkList = [
            SELECT ContentDocument.LatestPublishedVersion.VersionData,
                ContentDocument.LatestPublishedVersion.Title,
                LinkedEntityId,
            	ContentDocument.LatestPublishedVersion.FileExtension,
            	ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :docStoreIdSet
                AND ContentDocument.LatestPublishedVersionId = :contentVersionId
        ];

        BPI_SharepointAPIService spApiService = BPI_SharepointAPIService.init(getIntegrationSettings()[0].Base_Folder_List__c, subfolder);
        Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse = spApiService.pushSingleFileToSharepoint(contentDocumentLinkList);
        processResponse(idDocStoreMap, mapResponse); 
        return getFile(docStore.Id);          
    }

    /**
	* @description:	method used to send all files linked to a DUP_Document_Request__c to SP
	* @param: document request id
	* @return: List<DUP_Document_Store__c>
	*/      
    @AuraEnabled
    public static ID sendAllFileToSharepoint(Id docRequestId){
        List<DUP_Document_Store__c> docStoreList = [SELECT Id,
                    DUP_SharepointUrl__c,
                    DUP_Document_Request__r.DUP_ICOSId__c 
                FROM DUP_Document_Store__c
                WHERE DUP_Document_Request__c = :docRequestId
                    AND DUP_Document_Status__c = 'Reviewed'];
          if( docStoreList[0].DUP_SharepointUrl__c != Null){
           return null;
            }
        else{
        String subfolder = docStoreList[0].DUP_Document_Request__r.DUP_ICOSId__c ;
        Map<Id,DUP_Document_Store__c> idDocStoreMap = new Map<Id,DUP_Document_Store__c>(docStoreList);
        Set<Id> docStoreIdSet = (idDocStoreMap).keySet();
        DUP_FileShareBatch fileBatch = new DUP_FileShareBatch(docStoreIdSet);
        return Database.executeBatch(fileBatch,1);
        }
    }     

    /**
	* @description:	it processes the response updating DUP_Document_Store__c and ContentVersion
	* @param: ap<Id,DUP_Document_Store__c> idDocStoreMap, Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse
	* @return: void
	*/       
    public static void processResponse(Map<Id,DUP_Document_Store__c> idDocStoreMap, Map<Id,List<BPI_SharepointAPIService.ResponseWrapper>> mapResponse){
        List<DUP_Document_Store__c> docStoreToBeUploaded = new List<DUP_Document_Store__c>();
        List<ContentVersion> contentVersionToBeUploaded = new List<ContentVersion>();
        for(Id docStoreId : mapResponse.keySet()){
            List<BPI_SharepointAPIService.ResponseWrapper> httpResponseWrapperList = mapResponse.get(docStoreId);
            DUP_Document_Store__c ds =  idDocStoreMap.get(docStoreId);
            String sharepointUrl = ds.DUP_SharepointUrl__c;

            for(BPI_SharepointAPIService.ResponseWrapper hrWrapper : httpResponseWrapperList){
                ContentVersion cv = new ContentVersion();
                cv.Id = hrWrapper.contentVersionId;
                HttpResponse res = hrWrapper.response;
                if(res.getStatusCode() == 200){
                    system.debug(res.getBody());
                    JSONParser parser = JSON.createParser(res.getBody());
                    String path;        
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                            String fieldName = parser.getText();
                            parser.nextToken();
                            if (fieldName == 'path') {
                                path = getIntegrationSettings()[0].Sharepoint_Url__c + parser.getText();
                            } 
                        }
                    }
                    //update Urls on Document Store
                    if(sharepointUrl == null){
                        sharepointUrl = path;
                    } else {
                        sharepointUrl += ',' + path;
                    }
                    ds.DUP_SharepointUrl__c = sharepointUrl;
                    docStoreToBeUploaded.add(ds);

                    //Update status on contentVersion
                    cv.DUP_SharepointError__c = null;
                    cv.DUP_Status__c = 'Sent to Sharepoint';                    
                } else {
                    JSONParser parser = JSON.createParser(res.getBody());
                    String errorString;  
                    String messageString;      
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                            String fieldName = parser.getText();
                            parser.nextToken();
                            if (fieldName == 'error') {
                                errorString = parser.getText();
                            }
                            if (fieldName == 'message') {
                                messageString = parser.getText();
                            } 
                        }
                    }
                    cv.DUP_SharepointError__c = (errorString != null ? errorString : messageString) + ' for:';                        
                }
                contentVersionToBeUploaded.add(cv);
            }
        } 

        MAP<Id,DUP_Document_Store__c> docMap = new MAP<Id,DUP_Document_Store__c>();
 		docMap.putall(docStoreToBeUploaded);

        if(!docStoreToBeUploaded.isEmpty()){
            update docMap.values();
        }

        if(!contentVersionToBeUploaded.isEmpty()){
            update contentVersionToBeUploaded;
        }                
    }    

    /**
	* @description:	method used to retrieve the file linked to a DUP_Document_Store__c
	* @param: document store id
	* @return: List<LoadDataWrapper>
	*/      
    @AuraEnabled
    public static LoadDataWrapper getFile(Id docStoreId){
        LoadDataWrapper returnData = new LoadDataWrapper();
        returnData.contentDocumentLinkList = [SELECT ContentDocumentId,
                                                    ContentDocument.LatestPublishedVersionId,
                                                    ContentDocument.Title,
                                                    ContentDocument.FileExtension,
                                                    ContentDocument.LatestPublishedVersion.DUP_Status__c,
                                                    ContentDocument.LatestPublishedVersion.DUP_SharepointError__c
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = :docStoreId
                                                    AND ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Approved'
                                            ];
        
        
        DUP_Document_Store__c ds = [SELECT DUP_SharepointUrl__c FROM DUP_Document_Store__c WHERE Id = :docStoreId];
        if(ds.DUP_SharepointUrl__c != null){
            List<FileInfo> fileInfoList = new List<FileInfo>();
            List<String> urlList = ds.DUP_SharepointUrl__c.split(',');
            for(String url : urlList){
                FileInfo fileInfo = new FileInfo();
                fileInfo.url = url;
                fileInfo.status = 'Sent to Sharepoint';
                fileInfoList.add(fileInfo);
            }
            returnData.fileInfoList = fileInfoList;            
        }
        return returnData;
    }

    @AuraEnabled
    public static void updateSharepointField(Id recordId){
        DUP_Document_Request__c currentRecord = [SELECT DUP_Sharepoint_Success__c 
                                                FROM DUP_Document_Request__c
                                                WHERE Id = :recordId];
       
        currentRecord.DUP_Sharepoint_Success__c = TRUE;
        
        update currentRecord;
    }    
    @AuraEnabled 
    public static void updateFileName( Id contentVersionId,String fileName){
        ContentVersion conVersionObj = new ContentVersion(Id=contentVersionId);
        conVersionObj.title = fileName;
        update conVersionObj;
    }
    
    @AuraEnabled 
    public static Boolean checkPermission(String permissionName){
        Boolean hasPermission = FeatureManagement.checkPermission(permissionName);
        return hasPermission;		
    }
	
	@AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
}