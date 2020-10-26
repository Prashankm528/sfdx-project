/*****************************************************************************************
*       Date:        25OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: Controller for DUP_NewDocumentRequest
*****************************************************************************************/
public with sharing class DUP_NewDocumentRequestController {
    
    public class LoadDataWrapper{
        @AuraEnabled
        public List<DUP_List_Of_Values__c> listOfValuesList {get;set;}
        @AuraEnabled
        public List<DUP_Document_Template__c> docTemplateList {get;set;}
    }

    /**
    * @description:	init method to load the required data
    * @param: 
    * @return: LoadDataWrapper 
    */  
    @AuraEnabled
    public static LoadDataWrapper loadSelectsValues(){
        LoadDataWrapper returnData = new LoadDataWrapper();
        returnData.listOfValuesList = [SELECT DUP_Type__c,
                                   DUP_Description__c,
                                   DUP_Document_Template__c
                               FROM DUP_List_Of_Values__c 
                               LIMIT 200];  
        returnData.docTemplateList = [SELECT Name FROM DUP_Document_Template__c LIMIT 200];
        return returnData;        
    }

    /**
    * @description:	method to save the new document request
    * @param: DUP_Document_Store__c record
    * @return: Id of the new record 
    */  
    @AuraEnabled
    public static Id createDocStore(DUP_Document_Store__c docStore){
        try {            
            upsert docStore;
            return docStore.Id;
        } catch (DmlException e){
            System.debug('Insert inserting new document store: ' + e.getMessage());
            return null;
        }
        
    }

    /**
    * @description: method to delete the new document request on cancel
    * @param: DUP_Document_Store__c record
    * @return: void
    */  
    @AuraEnabled
    public static void deleteDocStore(DUP_Document_Store__c docStore){
        try {            
            delete docStore;
        } catch (DmlException e){
            System.debug('Deleting new document store: ' + e.getMessage());
        }
    }
    
    /**
    * @description  method to get File information
    * @param document store from where to take the files
    * @return List<ContentDocumentLink> to get the info of the file
    */
    @AuraEnabled
    public static List<ContentDocumentLink> UpdateStatusAndReturnFiles(Id docStoreId){
        List<ContentDocumentLink> contentDocument = [SELECT ContentDocumentId,
                                                    ContentDocument.Title,
                                                    ContentDocument.FileExtension,
                                                     LinkedEntityId
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = :docStoreId
                                                    AND (ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Uploaded'
                                                        OR ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Template')
                                                ];
        if(contentDocument.size() == 0){
            return null;
        }else{
            //Added by Ankit on 2ndJan 2020, to update the DUP Status as 'Template' for all Doc uploaded
            List<ContentVersion> contentVersionList = [SELECT DUP_Status__c,contentdocumentid,contentdocument.title,contentdocument.fileextension,FirstPublishLocationId FROM ContentVersion where FirstPublishLocationId = :docStoreId and ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Uploaded'];
            String fileJSON = '[{';
            if(contentVersionList!=null && !contentVersionList.isEmpty()){
                for(ContentVersion cv : contentVersionList){
                    cv.DUP_Status__c = 'Template';
                    fileJSON = fileJSON + '"name":"' + cv.ContentDocument.Title+'.'+cv.ContentDocument.FileExtension + '","documentId":"' + cv.ContentDocumentId + '"},{';
                }
                fileJSON = fileJSON.removeEnd(',{');
            }
            else{
                fileJSON = fileJSON + '}';
            }
            //Added ] after } because tests were failing - Naglis Kazlauskas
            fileJSON = fileJSON + ']';
            system.debug('JSON---  '+fileJSON);
            update contentVersionList;
            //DUP_NewDocumentRequestController.shareFileWithCounterParty(docStoreId,fileJSON);
        }
        return contentDocument;
    }
    /**
    * @description  method to share uploaded files with CP
    * @param document store - from where we upload the files
    * @param files - the 1 or more files uploaded
    * @return String - the status of the sharing is ok or has error
    */
    //Added by Ankit on 6th Jan 2020, for sharing the uploaded file with CP
    @AuraEnabled
    public static String shareFileWithCounterParty(Id docStoreId,String files){
        return DUP_CommunityMainViewController.shareFileWithAgent(docStoreId,files);
    }
}