public with sharing class DUP_RequestAdditionalDocuments {

     /**
    * @description: gives the status of the document request whose id is passed as parameter
    * @param: documentRequestId
    * @return: String
    */
    @AuraEnabled
    public static String getStatus(Id docRequestId){
        return DUP_CancelDocumentRequestController.getStatus(docRequestId);
    }
    
    /**
	* @description 	creates an additional document request
	* @param Id requestId : document request Id
	* @return Id of the newly created document request
	*/
    @AuraEnabled
    public static Id createDocumentRequest(Id requestId){
        DUP_Document_Request__c request = [select id,DUP_BP_Entity_Details__c,DUP_RBU__c,
                                           DUP_doc_submitted_status__c,DUP_Status_Upload__c,
                                           DUP_Requestor_Emails__c, DUP_CounterParty_Name__c,
                                           DUP_ICOSId__c,DUP_Linked_Document_Request__c,
                                           RecordTypeId,DUP_Email_Templates__c,DUP_Risk_Status__c  
                                           from DUP_Document_Request__c where id=:requestId];
        
        DUP_Document_Request__c additionalRequest = new DUP_Document_Request__c();
        additionalRequest.DUP_BP_Entity_Details__c = request.DUP_BP_Entity_Details__c;
        additionalRequest.DUP_RBU__c = request.DUP_RBU__c;
        additionalRequest.RecordTypeId = request.RecordTypeId;
        additionalRequest.DUP_Requestor_Emails__c = request.DUP_Requestor_Emails__c;
        additionalRequest.DUP_ICOSId__c = request.DUP_ICOSId__c;
        additionalRequest.DUP_doc_submitted_status__c = system.Label.DUP_DocumentReqStatus_ConfirmDetails;
        additionalRequest.DUP_Status_Upload__c = system.Label.DUP_Status_For_Popup;
        if(request.DUP_Linked_Document_Request__c!=null){
            additionalRequest.DUP_Linked_Document_Request__c = request.DUP_Linked_Document_Request__c;
        }
        else{
        	additionalRequest.DUP_Linked_Document_Request__c = request.Id;
        }
        additionalRequest.DUP_CounterParty_Name__c = request.DUP_CounterParty_Name__c;
        additionalRequest.DUP_Risk_Status__c = request.DUP_Risk_Status__c;
        
        if(request.DUP_Email_Templates__c == system.label.DUP_EmailTemplate_NewRequest || request.DUP_Email_Templates__c == system.label.DUP_EmailTemplate_AdditionalRequest){
            additionalRequest.DUP_Email_Templates__c = system.label.DUP_EmailTemplate_AdditionalRequest;
        }
        else if(request.DUP_Email_Templates__c == system.label.DUP_EmailTemplate_NewReviewRequest || request.DUP_Email_Templates__c == system.label.DUP_EmailTemplate_AdditionalReviewRequest){
            additionalRequest.DUP_Email_Templates__c = system.label.DUP_EmailTemplate_AdditionalReviewRequest;
        }
        
        insert additionalRequest;
        DUP_DocumentRequestUtil.createDocumentStores(new List<DUP_Document_Request__c>{additionalRequest} );

        return additionalRequest.Id;
    }
}