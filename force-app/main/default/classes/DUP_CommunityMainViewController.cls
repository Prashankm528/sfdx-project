/*****************************************************************************************
*       Date:        19SEP2019
*       Author:      Alessandro Miele - IBM
*       Description: Controller for DUP_CommunityMainView and DUP_CommunitySingleDocumentView
*       Updated by:  Arron Kukadia - IBM (shareFileWithAgent to handle multiple files uploaded)
*					 Babul Jha - Wipro (getDocumentStore to only show the doc request
where they are in DUP_Review_Upload stage)	
*****************************************************************************************/

public without sharing class DUP_CommunityMainViewController {
    
    /**
* @description 	method to get the status if the counterparty has logged in previously
* @param 
* @return true if the user has logged in previously
*/
    @AuraEnabled
    public static boolean getLoggedInUser(){
        Id uId = UserInfo.getUserId();
        User user = [select DUP_First_Login__c from user where id=:uId limit 1];
        if(user!=null && !user.DUP_First_Login__c){
            user.DUP_First_Login__c = true;
            update user;
            return true;
        }
        else
            return false;
    }
    
    /**
* @description 	method to populate all the lines in the community view
* @param String document Request Name, Id userId of the counterparty logging in
* @return List<DUP_Document_Store__c>
*/
    @AuraEnabled
    public static List<DUP_Document_Store__c> getDocumentStore(String docReqName, Id userId){
        String userEmail = [SELECT Email FROM User WHERE Id = :userId].Email;
        List<DUP_Document_Store__c> documentList = [
            SELECT Id,Name,
            DUP_Options__c,
            DUP_Document_Status__c,
            DUP_Document_Name__c,
            DUP_Requested__c,
            DUP_CPcomments__c,
            DUP_Document_Request__r.Name,
            DUP_Description__c,
            DUP_Certified_True_Copy__c,
            DUP_RejectComments_Available__c
            FROM DUP_Document_Store__c 
            WHERE DUP_Document_Request__r.Name =: docReqName 
            AND DUP_Requested__c = true
            AND DUP_Document_Status__c = 'Requested'
            AND DUP_Document_Request__r.DUP_Status_Upload__c = 'DUP_Review_Upload'
            AND DUP_Counterparty_Contact_Name__r.DUP_Email__c = :userEmail
        ];  
        return documentList; 
    } 
    
    /**
* @description 	method to delete all files against a document request except the passed one
* @param document store to be cleaned, file to not be deleted
* @return Boolean
*/
    @AuraEnabled
    public static Boolean deleteFiles(Id docStoreId, Id fileId){
        List<Id> contentDocumentIds = new List<Id>();
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId
                                                         FROM ContentDocumentLink 
                                                         WHERE LinkedEntityId = :docStoreId
                                                         AND ContentDocumentId != :fileId
                                                        ];
        for (ContentDocumentLink cd : contentDocumentList ){
            if(!contentDocumentIds.contains(cd.ContentDocumentId)){
                contentDocumentIds.add(cd.ContentDocumentId);
            }            
        }
        if(!contentDocumentIds.isEmpty()){
            Database.delete(contentDocumentIds); 
            return true;
        } 
        return false;             
    }
    
    /**
* @description 	method to get File information
* @param document store from where to take the files
* @return List<ContentDocumentLink> to get the info of the file
*/
    @AuraEnabled
    public static List<ContentDocumentLink> getFile(Id docStoreId){
        List<ContentDocumentLink> contentDocument = [SELECT ContentDocumentId,
                                                     ContentDocument.Title,
                                                     ContentDocument.FileExtension 
                                                     FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId = :docStoreId
                                                     AND ContentDocument.LatestPublishedVersion.DUP_Status__c != 'Rejected'
                                                    ];
        if(contentDocument.size() == 0){
            return null;
        }
        return contentDocument;
    }
    
    /**
* @description 	method to get File information
* @param document store from where to take the files
* @return List<ContentDocumentLink> to get the info of the file
*/
    @AuraEnabled
    public static List<ContentDocumentLink> getUploadedFile(Id docStoreId){
        List<ContentDocumentLink> contentDocument = [SELECT ContentDocumentId,
                                                     ContentDocument.Title,
                                                     ContentDocument.FileExtension,
                                                     ContentDocument.LatestPublishedVersion.DUP_Status__c,
                                                     LinkedEntityId
                                                     FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId = :docStoreId
                                                     AND (ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Uploaded'
                                                          OR ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Template')
                                                    ];
        if(contentDocument.size() == 0){
            return null;
        }
        return contentDocument;
    }
    
    /**
* @description 	method to delete a single file
* @param Id of the file
* @return void
*/
    @AuraEnabled
    public static void deleteSingleDocument(Id fileId){
        List<ContentDocument> contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :fileId];
        if(!contentDocument.isEmpty()){
            delete contentDocument;
        }        
    }
    
    /**
* @description 	method to delete all invalid files
* @param list of Id of the files to be deleted
* @return void
*/
    @AuraEnabled
    public static void deleteInvalidDocument(String fileIds){
        Type idArrType = Type.forName('List<Id>');
    	List<Id> idList = (List<Id>) JSON.deserialize(fileIds, idArrType);
        List<ContentDocument> contentDocument = [SELECT Id FROM ContentDocument WHERE Id in :idList];
        if(!contentDocument.isEmpty()){
            delete contentDocument;
        }        
    }
    
    /**
* @description 	method to upload the status the document store list and send communication
* @param List<DUP_Document_Store__c>
* @return void
*/
    @AuraEnabled
    public static void uploadDocStoreStatus(List<DUP_Document_Store__c> docStoreList){
        try{
        id documentRequestId;
        for(DUP_Document_Store__c ds : docStoreList ){
            ds.DUP_Document_Status__c = 'Uploaded';
            ds.DUP_RejectComments_Available__c=false;
            if(documentRequestId == null){
                documentRequestId = ds.DUP_Document_Request__c;
            }
        }
        update docStoreList; 
        DUP_Document_Request__c documentRequest = [SELECT Name,
                                                   DUP_doc_submitted_status__c,
                                                   OwnerId,DUP_Email_Templates__c, 
                                                   DUP_BP_Entity_Details__r.DUP_Return_Email__c,
                                                   DUP_Requestor_Emails__c,
                                                   DUP_CounterParty_Name__c 
                                                   FROM DUP_Document_Request__c 
                                                   WHERE Id =: documentRequestId];
       	
        String Recordlink = System.label.BPISTDUPLightningBaseUrl+'/lightning/r/DUP_Document_Request__c/'+documentRequestId+'/view';
        List<DUP_Document_Store__c> docStoreList2 = [Select id,DUP_Document_Status__c,
                                                     DUP_Document_Request__c,
                                                     DUP_Document_Request__r.DUP_doc_submitted_status__c
                                                     FROM DUP_Document_Store__c 
                                                     WHERE DUP_Document_Request__c =: documentRequestId
                                                     AND DUP_Document_Status__c != 'Created'];
        if(docStoreList2 != Null || !docstoreList2.isEmpty()) {
          for(DUP_Document_Store__c ds : docStoreList2 ){
            if(ds.DUP_Document_Status__c == 'Requested'){
                documentRequest.DUP_doc_submitted_status__c = 'Requested';
                break;
            }
            else if(ds.DUP_Document_Status__c == 'Uploaded'){
                documentRequest.DUP_doc_submitted_status__c = 'Submitted';
            }
        }
         update documentRequest;     
        }
        else{
            if(documentRequest != Null) {
                documentRequest.DUP_doc_submitted_status__c = 'Submitted';   
            }           
            update documentRequest;          
        }        
        String emailBody='<html><body><p>NOTIFICATION:</p>'+
            +'<p>This is to notify you that documents regarding '+documentRequest.Name+' have been updated by Counterparty: <b> '+documentRequest.DUP_CounterParty_Name__c+'</b>.</p>'+'<p>Please follow the below link to navigate - <br>'+Recordlink+'</p></body></html>';
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        if(documentRequest.DUP_Email_Templates__c == 'Additional Info Review Request Template' || documentRequest.DUP_Email_Templates__c == 'Review Template')
        {
            if(documentRequest.DUP_Requestor_Emails__c!=null){
            list<string> emailList = documentRequest.DUP_Requestor_Emails__c.split(',');
            for(string email:emailList){
                toAddresses.add(email.trim());
                system.debug('Email List:'+email);                                
            }
            }
            //toAddresses.add(documentRequest.DUP_Requestor_Emails__c);
        }
        else{
            toAddresses.add(documentRequest.DUP_BP_Entity_Details__r.DUP_Return_Email__c);
        }
        Messaging.SingleEmailMessage email = DUP_MessagingServices.createEmailMessage(documentRequest.OwnerId, null, documentRequestId, null, toAddresses, ccAddresses);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(email.getToAddresses());
        emailToSend.setCCAddresses(email.getCcAddresses());
        emailToSend.setHTMLBody(emailBody);
        emailToSend.setPlainTextBody('NOTIFICATION: This is to notify you that documents regarding '+documentRequest.Name+' have been updated by Counterparty: '+documentRequest.DUP_CounterParty_Name__c+'. Please follow the below link to navigate - '+Recordlink);
        emailToSend.setSubject('DUP Document Portal Request Update');
        emailToSend.setSaveAsActivity(true);
        emailToSend.setWhatId(email.getWhatId());
        DUP_MessagingServices.sendEmail(emailToSend);
        }
        catch(Exception ex){
            DUP_DocumentRequestUtil.sendEmailOnException('Exception in class "DUP_CommunityMainViewController" in method "uploadDocStoreStatus" while being executed by '+UserInfo.getUserName()+
                                                        '. Error in line: '+ex.getLineNumber() +' due to: '+ex.getMessage());
        }
    }    
    /**
* @description 	method to share the files uploaded with the agent
* @param document store id and file id
* @return void
*/
    
    @AuraEnabled
    public static String shareFileWithAgent(Id docStoreId,String files){
        try{
            String returnVal = 'OK';
            List<DUP_FileList> fileList = DUP_FileList.parseFiles(files);
            List<Id> fileIds = new List<Id>();
            
            if(fileList!=null && !fileList.isEmpty()){
                for(DUP_FileList file : fileList){
                    fileIds.add(file.documentId);
                    if(deleteFileIfTooLarge(file.documentId)){
                        returnVal = 'fileTooLarge';
                    }
                }
            }
            System.debug(fileIds);
            
            
            if (returnVal != 'fileTooLarge') {
                List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id,ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :docStoreId AND ContentDocumentId IN :fileIds FOR UPDATE];
                List<ContentDocumentLink> contentDocumentLinkForUpdate = new List<ContentDocumentLink>();
                
                for (ContentDocumentLink cd : contentDocumentLinkList ){
                    cd.ShareType = 'I';
		    cd.Visibility = 'AllUsers';
                    contentDocumentLinkForUpdate.add(cd);
                }
                update contentDocumentLinkForUpdate;
            }
            return returnVal;
        }
        catch(Exception ex){
            DUP_DocumentRequestUtil.sendEmailOnException('Exception in class "DUP_CommunityMainViewController" in method "shareFileWithAgent" while being executed by '+UserInfo.getUserName()+
                                                        '. Error in line: '+ex.getLineNumber() +' due to: '+ex.getMessage());
            return null;
        }
    }
    
    /**
* @description 	method to delete the files greater than 4.4 mb in size
* @param file id
* @return true if file deleted successfully
*/
    private static boolean deleteFileIfTooLarge (Id fileId) {
        
        boolean fileOk = false;
        List<ContentVersion> files = [SELECT ContentSize FROM ContentVersion WHERE ContentDocumentId =: fileId];
        integer fileSize = 0;
        if(files!=null && !files.isEmpty())
            fileSize = files[0].ContentSize;
        String fileSizeInMB = String.valueOf((Decimal.valueOf(fileSize)).divide((1024*1024),2));
        if (Decimal.valueOf(fileSizeInMB) > Decimal.valueOf(System.Label.DUP_File_Size)) { 
        	deleteSingleDocument (fileId);
            fileOk = true;
        }
        return fileOk;
        
    }
    
    @AuraEnabled
    public static void saveComments(ID docStoreId, string cpcomments ){
        DUP_Document_Store__c ds = new DUP_Document_Store__c();
        ds.id = docStoreId;
        if(cpcomments !=Null){
                ds.DUP_CPcomments__c = cpcomments;
            }
        update ds;
    } 
        
}