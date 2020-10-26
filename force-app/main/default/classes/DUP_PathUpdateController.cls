public without sharing class DUP_PathUpdateController {
    @AuraEnabled
    public static String emailBody{get;set;}
    
    @AuraEnabled
    public static String getStatus(Id docRequestId){
        String tempStatus = '';
        List<DUP_Document_Request__c> currentRequest = [select Id,DUP_Status_Upload__c from DUP_Document_Request__c where id=:docRequestId];
        if(currentRequest!=null && !currentRequest.isEmpty()){
            tempStatus = currentRequest[0].DUP_Status_Upload__c;
        }
        return tempStatus;
    }
    
    @AuraEnabled
    public static String getSelectedocumentStore(Id docRequestId){
        String tempStatus = '';
        Id requestTemplateId;
        List<DUP_Document_Request__c> currentRequest = [select Id,DUP_Status_Upload__c,DUP_Email_Templates__c from DUP_Document_Request__c where id=:docRequestId];
        if(currentRequest!=null && !currentRequest.isEmpty()){
            tempStatus = currentRequest[0].DUP_Status_Upload__c;
            if(currentRequest[0].DUP_Email_Templates__c.equalsIgnoreCase('Additional Info Request Template')|| 
              currentRequest[0].DUP_Email_Templates__c.equalsIgnoreCase('Additional Info Review Request Template')){
                requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_AddInfo_VF_Template'].Id;
            }
            else if(currentRequest[0].DUP_Email_Templates__c.equalsIgnoreCase('Review Template')  ){
                        requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Review_VF_Template'].Id;
                    }
            else{
                requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Request_VF_Template'].Id;
            }
        }
        if(tempStatus==System.Label.DUP_Status_For_Popup){
            List<DUP_Document_Store__c> documentList = [SELECT Name,
                                                        DUP_Options__c,
                                                        DUP_Document_Status__c,
                                                        DUP_Document_Name__c,
                                                        DUP_Requested__c,
                                                        DUP_Counterparty_Contact_Name__c,
                                                        DUP_Counterparty_Contact_Name__r.Id,
                                                        DUP_Counterparty_Contact_Name__r.Name,
                                                        DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                        DUP_Document_Request__r.id,
                                                        DUP_Certified_True_Copy__c 
                                                        FROM DUP_Document_Store__c 
                                                        WHERE DUP_Document_Request__r.id =: docRequestId 
                                                        AND DUP_Requested__c = true
                                                       ]; 
            Boolean flag = true;
            for(DUP_Document_Store__c tempDoc : documentList){
                if(tempDoc.DUP_Counterparty_Contact_Name__c == null){
                    emailBody = null;
                    flag = false;
                    break;
                }
            }
            if(flag){
            	DUP_DocumentRequestUtil.sendEmailToCounterParty(currentRequest, requestTemplateId, documentList, false);
            }
            
            return JSON.serialize(documentList)+'--emailBody--'+emailBody;
        }
        
        return null;
    }  
    
    /**
* @description:	method used to retrieve the file linked to a DUP_Document_Store__c
* @param: document store id
* @return: List<ContentDocumentLink>
*/      
    @AuraEnabled
    public static List<ContentDocumentLink> getFile(Id docStoreId){
        List<ContentDocumentLink> contentDocument = [SELECT ContentDocumentId,
                                                     ContentDocument.Title,
                                                     ContentDocument.FileExtension,
                                                     ContentDocument.LatestPublishedVersion.DUP_Status__c
                                                     FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId = :docStoreId
                                                     AND ContentDocument.LatestPublishedVersion.DUP_Status__c != 'Rejected'
                                                    ];
        if(contentDocument.size() == 0){
            return null;
        }
        return contentDocument;
    }
    
    @AuraEnabled
    public static String updateDocReqStage(Id docRequestId, String currentStatus, boolean isReverse){
        try{
            List<String> statusList = (System.Label.DUP_StatusFlow).split(';');
            Map<String,String> statusMap = new Map<String,String>();
            for(String statusGroup : statusList){
                List<String> temp = statusGroup.split(':');
                statusMap.put(temp[0],temp[1]);
            }
            List<DUP_Document_Request__c> currentRequest = [select Id,DUP_Status_Upload__c from DUP_Document_Request__c where id=:docRequestId];
            if(currentRequest!=null && !currentRequest.isEmpty() && currentRequest[0].DUP_Status_Upload__c!='DUP_Cancelled'){
                if(currentRequest[0].DUP_Status_Upload__c=='DUP_Approved'){
                    return currentRequest[0].DUP_Status_Upload__c;
                }
                if(!isReverse)
                	currentRequest[0].DUP_Status_Upload__c=statusMap.get(currentStatus);
                update currentRequest;
                return currentRequest[0].DUP_Status_Upload__c;
            }
            else{
                throw new AuraHandledException('This request has been cancelled. Please create a new request');
            }
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
  /*  @AuraEnabled
    public static String updateDocReqStageToPrev(Id docRequestId, String currentStatus, boolean isReverse){
        try{
            List<String> statusList = (System.Label.DUP_StatusFlow).split(';');
            Map<String,String> statusMap = new Map<String,String>();
            Map<String,String> statusMapReverse = new Map<String,String>();
            for(String statusGroup : statusList){
                List<String> temp = statusGroup.split(':');
                statusMap.put(temp[1],temp[0]);
                statusMapReverse.put(temp[0],temp[1]);
            }
            List<DUP_Document_Request__c> currentRequest = [select Id,DUP_Status_Upload__c from DUP_Document_Request__c where id=:docRequestId];
            if(currentRequest!=null && !currentRequest.isEmpty()){
                if(!isReverse){
                    currentRequest[0].DUP_Status_Upload__c=statusMap.get(currentStatus);
                }
                else{
                    currentRequest[0].DUP_Status_Upload__c=statusMapReverse.get(currentStatus);
                }
                //update currentRequest;
                return currentRequest[0].DUP_Status_Upload__c;
            }
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    */
    /*@AuraEnabled
public static void cancelRequest(Id docRequestId){
try{
DUP_Document_Request__c docRequest = new DUP_Document_Request__c(Id=docRequestId);
docRequest.DUP_Status_Upload__c = 'Cancelled';
update docRequest;
}
catch(Exception e) {
throw new AuraHandledException(e.getMessage());
}

}*/
}