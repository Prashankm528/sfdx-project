/*****************************************************************************************
*       Date:           31AUG19
*       Author:         Payal Ahuja - IBM
*       Description:    Controller class for DUP_AddDocument
*       Updated by:     Alessandro Miele - IBM (adding methods and refactoring)
*****************************************************************************************/
public without sharing class DUP_AddDocumentListController {
    /**
* @description: method used in the init to initialise the component
* @param: document request id
* @return: list of DUP_Document_Store__c against the param Id
*/  
    @AuraEnabled
    public static List<DUP_Document_Store__c> loadLOVRecords(Id docReqId){
        
        List<DUP_Document_Store__c> returnDSList = [SELECT DUP_Counterparty_Contact_Name__c,
                                                    DUP_Counterparty_Contact_Name__r.Name,
                                                    DUP_Document_Name__c,
                                                    DUP_Document_Request__c,
                                                    DUP_Requested__c,
                                                    DUP_Options__c, 
                                                    DUP_Document_Template__c, 
                                                    DUP_Document_Template__r.Name,
                                                    DUP_Document_Status__c,
                                                    DUP_Description__c,
                                                    DUP_Certified_True_Copy__c,
                                                    DUP_ManualUpload__c,
                                                    (select ContentDocument.Title,LinkedEntityId
                                                     FROM ContentDocumentLinks 
                                                     WHERE  (ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Uploaded'
                                                             OR ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Template'))
                                                    FROM DUP_Document_Store__c 
                                                    WHERE DUP_Document_Request__r.Id =: docReqId]; 
        //
        return returnDSList ;
        
    }
    
     /**
* @description: method used in the init to initialise the component
* @param: document request id
* @return: map of group title and list of DUP_Document_Store__c against the param Id
*/  
    @AuraEnabled
    public static Map<String,List<DUP_Document_Store__c>> loadRecords(Id docReqId){
        
        List<DUP_Document_Store__c> docStoreList;
        Map<String,List<DUP_Document_Store__c>> groupTitleSubHeadingListMap = new Map<String,List<DUP_Document_Store__c>>();
        for(DUP_Document_Store__c docStore : [SELECT DUP_Counterparty_Contact_Name__c,
                                                    DUP_Counterparty_Contact_Name__r.Name,
                                                    DUP_Document_Name__c,
                                              		DUP_Group_Title__c,
                                                    DUP_Document_Request__c,
                                                    DUP_Requested__c,
                                                    DUP_Options__c, 
                                                    DUP_Document_Template__c, 
                                                    DUP_Document_Template__r.Name,
                                                    DUP_Document_Status__c,
                                                    DUP_Description__c,
                                                    DUP_Certified_True_Copy__c,
                                                    DUP_ManualUpload__c,
                                                    (select ContentDocument.Title,LinkedEntityId
                                                     FROM ContentDocumentLinks 
                                                     WHERE  (ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Uploaded'
                                                             OR ContentDocument.LatestPublishedVersion.DUP_Status__c = 'Template'))
                                                    FROM DUP_Document_Store__c 
             WHERE DUP_Document_Request__r.Id =: docReqId and DUP_Group_Title__c != '' order by DUP_Group_Title__c ]){
                 if(groupTitleSubHeadingListMap.containsKey(docStore.DUP_Group_Title__c)){
                     docStoreList = groupTitleSubHeadingListMap.get(docStore.DUP_Group_Title__c);
                 }else{
                     docStoreList = new List<DUP_Document_Store__c>();
                 }
                 docStoreList.add(docStore);
                 groupTitleSubHeadingListMap.put(docStore.DUP_Group_Title__c,docStoreList);
                 
             } 
        
        system.debug('MAp is==='+groupTitleSubHeadingListMap);
        return groupTitleSubHeadingListMap ;
        
    }
    /**
* @description: method used to update a list of Document Store by a given Document
* Request
* @param: document request id, map with Doc Store Id and Counterparty Id
* @return: void
*/      
    @AuraEnabled
    public static void updateDocStore(List<DUP_Document_Store__c> docStoreRecs){
        
        if(!docStoreRecs.isEmpty()){
            update docStoreRecs;
        }
        
        Set<Id> documentsToDelete = new Set<Id>();
        Map<Id, Id> contentVersionToBeInsertMap = new Map<Id, Id>();
        List<ContentVersion> documentsToSave = new List<ContentVersion>();
        
        for (DUP_Document_Store__c docStore : docStoreRecs ) {
            //can only allow this on the first pass, if we have requested the document our CP may have already uploaded their copy
            if (docStore.DUP_Document_Template__c != null && (docStore.DUP_Document_Status__c == 'Created' || docStore.DUP_Document_Status__c == 'Requested' ) ){
                
                documentsToDelete.add(docStore.Id);
                contentVersionToBeInsertMap.put(docStore.Id, docStore.DUP_Document_Template__c);  
            }         
        }
        if(!documentsToDelete.isEmpty()){
            deleteFiles(documentsToDelete); 
        }
        if(!contentVersionToBeInsertMap.isEmpty()){
            documentsToSave = createContentVersion(contentVersionToBeInsertMap);
        }
        
        if(documentsToSave != null && !documentsToSave.isEmpty()){
            Database.SaveResult[] srList = Database.insert(documentsToSave, true);
            List<Id> insertedContentVersionId = new List<Id>();
            for (Database.SaveResult sr : srList) {
                insertedContentVersionId.add(sr.getId());
            }
            Set<Id> contentDocumentIds = new Set<Id>();
            List<ContentVersion> contentVersionList = [SELECT ContentDocumentId 
                                                       FROM ContentVersion
                                                       WHERE Id IN :insertedContentVersionId];
            for(ContentVersion cv : contentVersionList){
                contentDocumentIds.add(cv.ContentDocumentId);
            }     
            List<ContentDocumentLink> contentDocumentLink = [SELECT Id,
                                                             ShareType
                                                             FROM ContentDocumentLink
                                                             WHERE ContentDocumentId IN :contentDocumentIds]; 
            for(ContentDocumentLink cdl : contentDocumentLink){
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
            }
            if(!contentDocumentLink.isEmpty()){
                update contentDocumentLink;
            }
        }        
    } 
    
    /**
* @description: method used to create a copy of the file linked to the template record
* Request
* @param: Id DocumentStoreId, Id DocumentTemplateId
* @return: void
*/   
    private static List<ContentVersion> createContentVersion (Map <Id, Id> documentTemplateMap ) {
        Set<Id> docStoreIdSet = documentTemplateMap.keySet();
        List<Id> docTemplateIdList = documentTemplateMap.values();
        //We can access the contentVersion using the ContentDocumentLink
        List<ContentDocumentLink> contentDocumentLinkList = [
            SELECT ContentDocument.LatestPublishedVersion.Title,
            ContentDocument.LatestPublishedVersion.PathOnClient,
            ContentDocument.LatestPublishedVersion.VersionData,
            LinkedEntityId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :docTemplateIdList
        ];                                      
        if(contentDocumentLinkList.size() == 0) {
            return null;
        }
        
        //2. make a copy
        List<ContentVersion> contentVersionCopyList = new List<ContentVersion>();
        
        for(Id storeId : docStoreIdSet){
            for(ContentDocumentLink cdl : contentDocumentLinkList){
                if(cdl.LinkedEntityId == documentTemplateMap.get(storeId)){   
                    ContentVersion contentVersionCopy = new ContentVersion();
                    contentVersionCopy.Title = cdl.ContentDocument.LatestPublishedVersion.Title ;
                    contentVersionCopy.PathOnClient = cdl.ContentDocument.LatestPublishedVersion.PathOnClient ;
                    contentVersionCopy.VersionData = cdl.ContentDocument.LatestPublishedVersion.VersionData ;
                    contentVersionCopy.FirstPublishLocationId = storeId;
                    contentVersionCopy.DUP_Status__c = 'Template';
                    contentVersionCopyList.add(contentVersionCopy);
                }
            }            
        }
        
        if(!contentVersionCopyList.isEmpty()){
            return contentVersionCopyList;
        }
        
        return null;
    }
    
    private static void deleteFiles(Set <Id> contentDocumentIdSet){
        
        List<Id> contentDocumentIds = new List<Id>();
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId
                                                         FROM ContentDocumentLink 
                                                         WHERE LinkedEntityId IN :contentDocumentIdSet
                                                        ];
        
        for (ContentDocumentLink cd : contentDocumentList ){
            if(!contentDocumentIds.contains(cd.ContentDocumentId)){
                contentDocumentIds.add(cd.ContentDocumentId);
            }            
        }
        if(!contentDocumentIds.isEmpty()){
            Database.delete(contentDocumentIds); 
        }        
    }
    
    @AuraEnabled
    public static List<sObject> getLookupList(String searchTerm, String objName) {
        String addtionalField = '';
        String additionalClause = '';
        
        if(objName.equals('DUP_Counterparty_Contact__c')){
            addtionalField = ',DUP_Email__c';
            additionalClause = ' or DUP_Email__c like \'%' + searchTerm + '%\'';
        }
            
        String query = 'Select Id, Name '+addtionalField+'  from ' + objName + ' Where Name Like \'%' + searchTerm + '%\' ' + additionalClause+  ' LIMIT  5';
        
        List<sObject> dataList = Database.query(query) ;
        return dataList;
        
    }
    
}