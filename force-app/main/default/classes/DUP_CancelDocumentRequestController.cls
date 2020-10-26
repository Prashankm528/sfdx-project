/*****************************************************************************************
*       Date:        17Mar2020
*       Author:      Wipro
*       Description: Controller class for DUP_CancelDocumentRequest component
*****************************************************************************************/
public with sharing class DUP_CancelDocumentRequestController {
    
    /**
    * @description: gives the status of the document request whose id is passed as parameter
    * @param: documentRequestId
    * @return: String
    */
    @AuraEnabled
    public static String getStatus(Id docRequestId){
        String tempStatus = '';
        List<DUP_Document_Request__c> currentRequest = [select Id,DUP_Status_Upload__c from DUP_Document_Request__c where id=:docRequestId];
        if(currentRequest!=null && !currentRequest.isEmpty()){
            tempStatus = currentRequest[0].DUP_Status_Upload__c;
        }
        return tempStatus;
    }
    
    /**
    * @description: Sets teh  status of the document request as Canceleld whose id is passed as parameter
    * @param: documentRequestId
    * @return: void
    */
    @AuraEnabled
    public static void cancelRequest(Id docRequestId){
        try{
            DUP_Document_Request__c docRequest = new DUP_Document_Request__c(Id=docRequestId);
            docRequest.DUP_Status_Upload__c = 'DUP_Cancelled';
            update docRequest;
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
                
    }
}