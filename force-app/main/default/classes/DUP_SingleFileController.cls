/*****************************************************************************************
*       Date:           22OCT19
*       Author:         Alessandro Miele - IBM
*       Description:    Controller class for DUP_SingleFileView component
*		Updates: 		rejectSingleDocument by Babul to update DUP_doc_submitted_status__c field
*****************************************************************************************/
public with sharing class DUP_SingleFileController {
    /**
	* @description 	delete a single contentDocument with its Id
	* @param Id fileId : contentDocument Id
    * @param Id docStoreId : document store Id
	* @return List<ContentDocumentLink>
	*/
    @AuraEnabled
    public static List<ContentDocumentLink> deleteSingleDocumentAndRefreshList(Id fileId, Id docStoreId){
        system.debug('in delete single file');
        ContentDocument contentDocumentToBeDeleted = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id = :fileId];        
        ContentVersion contentVersionToBeUploaded = new ContentVersion();
        contentVersionToBeUploaded.Id = contentDocumentToBeDeleted.LatestPublishedVersionId;
        contentVersionToBeUploaded.DUP_Status__c = 'Rejected';
        
        update contentVersionToBeUploaded;
        
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId,
                                                     ContentDocument.Title,
                                                     ContentDocument.FileExtension 
                                                     FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId = :docStoreId
                                                        AND (ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Uploaded'
                                                            OR ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Template')
                                                    ];
        if(contentDocumentList.size() == 0){
            return null;
        }
        return contentDocumentList;        
    }

    /**
	* @description:	method used to reject a document and set the document store
    *   back to requested.
	* @param: file id, document store id
    * @param: String param to determinate if the document store must be requested back, Reviewed or nothing
	* @return: Map<String,List<ContentDocumentLink>>
	*/      
    @AuraEnabled
    public static Map<String,List<ContentDocumentLink>> rejectSingleDocument(Id fileId, DUP_Document_Store__c docStore, String statusUpdate){
        ContentDocument contentDocumentTarget = [SELECT Title,FileExtension,LatestPublishedVersionId FROM ContentDocument WHERE Id = :fileId];
        ContentVersion contentVersionToBeUploaded = new ContentVersion();
        contentVersionToBeUploaded.Id = contentDocumentTarget.LatestPublishedVersionId;
        contentVersionToBeUploaded.DUP_Status__c = 'Rejected';
        //Added to resolve sharing issue for files
        try{
        	update contentVersionToBeUploaded;
    	}
        catch(Exception e){
            String file = '[{"name":"'+contentDocumentTarget.Title+'.'+contentDocumentTarget.FileExtension+'","documentId":"'+fileId+'"}]';
            DUP_CommunityMainViewController.shareFileWithAgent(docStore.Id,file);
            update contentVersionToBeUploaded;
        }
        //End of issue fix
		Map<String, List<ContentDocumentLink>> returnData = new Map<String, List<ContentDocumentLink>>();
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId,
                                                         ContentDocument.Title,
                                                         ContentDocument.FileExtension,
                                                         ContentDocument.LatestPublishedVersion.DUP_Status__c  
                                                         FROM ContentDocumentLink 
                                                         WHERE LinkedEntityId = :docStore.Id and ContentDocument.LatestPublishedVersion.DUP_Status__c!='Rejected'];

        if(statusUpdate != null) {        
            if(docStore.DUP_Reject_Comments__c!=null && docStore.DUP_Reject_Comments__c!='' && statusUpdate=='Requested'){
                docStore.DUP_RejectComments_Available__c = true;
            }
            docStore = DUP_SingleFileController.updateDocStore(docStore);   
        }        
        id documentRequestId;

        documentRequestId = docStore.DUP_Document_Request__c;
        statusUpdate = docStore.DUP_Document_Status__c;
        DUP_Document_Request__c documentRequest = [SELECT Name,DUP_doc_submitted_status__c FROM DUP_Document_Request__c WHERE Id =: documentRequestId];
        if(documentRequest != Null){
            if( statusUpdate=='Requested' || docStore.DUP_RejectComments_Available__c == true){
            	documentRequest.DUP_doc_submitted_status__c='Requested';
            }
            else if(documentRequest.DUP_doc_submitted_status__c!='Requested'){
                documentRequest.DUP_doc_submitted_status__c='Submitted';
            }
          }
        update documentRequest;
        //End of change
        returnData.put(docStore.DUP_Document_Status__c+':'+docStore.DUP_RejectComments_Available__c, contentDocumentList);
        return returnData;           
    }
    
    /**
* @description:	method used to approve a file linked to a DUP_Document_Store__c
* @param: file id, document store id
* @param: boolean updateStatus to determinate if the document store status must be updated
* @return: DUP_Document_Store__c
*/      
    @AuraEnabled
    public static DUP_SingleFileController.ApprovedData approveSingleDocument(Id fileId, DUP_Document_Store__c docStore, Boolean updateStatus){
        
        ContentDocument contentDocumentTarget = [SELECT Title,FileExtension,LatestPublishedVersionId FROM ContentDocument WHERE Id = :fileId];
        ContentVersion contentVersionToBeUploaded = new ContentVersion();
        contentVersionToBeUploaded.Id = contentDocumentTarget.LatestPublishedVersionId;
        contentVersionToBeUploaded.DUP_Status__c = 'Approved';
         //Added to resolve sharing issue for files
        try{
            update contentVersionToBeUploaded;
        }
        catch(Exception e){
            String file = '[{"name":"'+contentDocumentTarget.Title+'.'+contentDocumentTarget.FileExtension+'","documentId":"'+fileId+'"}]';
            DUP_CommunityMainViewController.shareFileWithAgent(docStore.Id,file);
            update contentVersionToBeUploaded;
        }
        //End of issue fix
        docStore = DUP_SingleFileController.updateDocStore(docStore);
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId,ContentDocument.FileExtension,
                                                         ContentDocument.Title,
                                                         ContentDocument.LatestPublishedVersion.DUP_Status__c  
                                                         FROM ContentDocumentLink 
                                                         WHERE LinkedEntityId = :docStore.Id];

        DUP_SingleFileController.ApprovedData processedData = new DUP_SingleFileController.ApprovedData(docStore, contentDocumentList);
        return processedData;
    }
    
    /**
* @description:	method used to sync document store record
* @param: document store id
* @return: DUP_Document_Store__c
*/      
    @AuraEnabled
    public static DUP_Document_Store__c updateDocStore(DUP_Document_Store__c docStore){
        String status = '';

        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId,
                                                         ContentDocument.LatestPublishedVersion.DUP_Status__c  
                                                         FROM ContentDocumentLink 
                                                         WHERE LinkedEntityId = :docStore.Id];

        List<ContentDocumentLink> reRequestedDocs = new List<ContentDocumentLink>();
        List<ContentDocumentLink> reviewedDocs = new List<ContentDocumentLink>();
        List<ContentDocumentLink> remainingDocs = new List<ContentDocumentLink>();
        
        if(contentDocumentList.size()>0){
            for(ContentDocumentLink doc : contentDocumentList){
                if(doc.ContentDocument.LatestPublishedVersion.DUP_Status__c=='Rejected'){
                    if(docStore.DUP_RejectComments_Available__c){
                        reRequestedDocs.add(doc);
                    }
                    else{
                        reviewedDocs.add(doc);
                    }
                }
                else if(doc.ContentDocument.LatestPublishedVersion.DUP_Status__c=='Uploaded'){
                    remainingDocs.add(doc);
                }
                else if(doc.ContentDocument.LatestPublishedVersion.DUP_Status__c=='Approved'){
                    reviewedDocs.add(doc);
                }
                
            }
        }
        if(remainingDocs.size()==0){
            if(reRequestedDocs.size()>0){
                status = 'Requested';
            }
            else{
                status = 'Reviewed';
            }
            docStore.DUP_Document_Status__c = status;
            update docStore;
        }
        else if(docStore.DUP_RejectComments_Available__c){             	
            	update docStore;
        }
        
        return docStore;
    } 

public class approvedData{
        @AuraEnabled
        public DUP_Document_Store__c ds;
        @AuraEnabled
        public List<ContentDocumentLink> contentDocumentList;
        
        public approvedData(DUP_Document_Store__c docStore,List<ContentDocumentLink> cdls){
            ds = docStore;
            contentDocumentList = cdls;
        }
        
    }
}