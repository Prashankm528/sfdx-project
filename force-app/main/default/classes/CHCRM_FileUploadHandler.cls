/***********************************************************************************************
 * @author           Sean
 * @date             2020/03/17
 * @group            CHCRM
 * @description      controller class used by aura component for file upload

 * history
 * 2020/03/17  Sean  Created 
 ************************************************************************************************/
public with sharing class CHCRM_FileUploadHandler {

    /**
     * @description get files based on recordid
     * @param recordId of type string
     * @return List collection ContentDocument
     */
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId){ 
        // TO avoid following exception 
        // System.QueryException: Implementation restriction: ContentDocumentLink requires
        // a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or 
        // multiple Id's using the IN operator.
        // We have to add sigle record id into set or list to make SOQL query call
        Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        return [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
    } 
    
    /**
     * @description delete files based on sdocumentId
     * @param sdocumentId of type string
     * @return void
     */
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];       
    }
}