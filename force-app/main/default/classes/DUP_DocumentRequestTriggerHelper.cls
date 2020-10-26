public with sharing class DUP_DocumentRequestTriggerHelper {    
    /**
* @description: sends an email with the uploaded documents to counterparty when the stage is changed
* @param: oldMap from DUP_Document_Request__c Trigger, newList from DUP_Document_Request__c Trigger
* @return: void
*/
    //public static Boolean runOnce = true;
    public void afterUpdateOperations(Map<Id, DUP_Document_Request__c> oldDocumentRequestMap, List<DUP_Document_Request__c> newDocumentRequestList){
        List<DUP_Document_Request__c> docRequestSendEmailToCounterpartyList = new List<DUP_Document_Request__c>();
        List<DUP_Document_Request__c> docRequestSendEmailToCounterpartyForReviewList = new List<DUP_Document_Request__c>();
        List<DUP_Document_Request__c> docRequestSendEmailToCounterpartyForAddInfoList = new List<DUP_Document_Request__c>();
        List<DUP_Document_Request__c> docRequestForCreateDocumentStoreList = new List<DUP_Document_Request__c>();        
        Boolean status_changed = false;
        for(DUP_Document_Request__c dr : newDocumentRequestList ){
            system.debug('old'+oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c);
            system.debug('new'+dr.DUP_Status_Upload__c);    
            if(oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c != dr.DUP_Status_Upload__c) {  
                status_changed = true;
                break;
            }            
        }
        if(status_changed){
            for(DUP_Document_Request__c newDocRequest : newDocumentRequestList){
                if(oldDocumentRequestMap.get(newDocRequest.Id).DUP_Status_Upload__c != System.label.DUP_DocumentReqStatus_Review && newDocRequest.DUP_Status_Upload__c == System.label.DUP_DocumentReqStatus_Review){
                    if(('Additional Info Request Template').equalsIgnoreCase(newDocRequest.DUP_Email_Templates__c) || 
                       ('Additional Info Review Request Template').equalsIgnoreCase(newDocRequest.DUP_Email_Templates__c)){//newDocRequest.DUP_Additional_Information__c){
                           docRequestSendEmailToCounterpartyForAddInfoList.add(newDocRequest);
                       } else if(('Review Template').equalsIgnoreCase(newDocRequest.DUP_Email_Templates__c) ){
                           docRequestSendEmailToCounterpartyForReviewList.add(newDocRequest);
                       }else {
                           docRequestSendEmailToCounterpartyList.add(newDocRequest);
                       }                 
                }
                else if(oldDocumentRequestMap.get(newDocRequest.Id).DUP_Status_Upload__c == System.Label.DUP_DocumentReqStatus_New && newDocRequest.DUP_Status_Upload__c == System.Label.DUP_Status_For_Popup){
                    docRequestForCreateDocumentStoreList.add(newDocRequest); 
                }        
            }        
            if(!docRequestSendEmailToCounterpartyList.isEmpty()) {
                //Create a list of Document Store with the Counterparty Email related to the Document Request list
                List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                                                               DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                               DUP_Document_Request__c
                                                               FROM DUP_Document_Store__c
                                                               WHERE DUP_Requested__c = true
                                                               AND DUP_Document_Status__c != 'Uploaded'
                                                               AND DUP_Document_Status__c != 'Reviewed'
                                                               AND DUP_Document_Request__c IN :docRequestSendEmailToCounterpartyList
                                                              ];
                if(!docStoreRecords.isEmpty()) {
                    Id requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Request_VF_Template'].Id;
                    DUP_DocumentRequestUtil.sendEmailToCounterParty(docRequestSendEmailToCounterpartyList, requestTemplateId, docStoreRecords, true);
                }
            }        
            if(!docRequestSendEmailToCounterpartyForAddInfoList.isEmpty()) {
                
                List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                                                               DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                               DUP_Document_Request__c
                                                               FROM DUP_Document_Store__c
                                                               WHERE DUP_Requested__c = true
                                                               AND DUP_Document_Status__c != 'Uploaded'
                                                               AND DUP_Document_Status__c != 'Reviewed'
                                                               AND DUP_Document_Request__c IN :docRequestSendEmailToCounterpartyForAddInfoList
                                                              ];
                if(!docStoreRecords.isEmpty()) {
                    Id addInfoTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_AddInfo_VF_Template'].Id;
                    DUP_DocumentRequestUtil.sendEmailToCounterParty(docRequestSendEmailToCounterpartyForAddInfoList, addInfoTemplateId, docStoreRecords, true);
                }
            }
            if(!docRequestForCreateDocumentStoreList.isEmpty()) {
                DUP_DocumentRequestUtil.createDocumentStores(docRequestForCreateDocumentStoreList);
            }   
            if(!docRequestSendEmailToCounterpartyForReviewList.isEmpty()) {
                //Create a list of Document Store with the Counterparty Email related to the Document Request list
                List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                                                               DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                                                               DUP_Document_Request__c
                                                               FROM DUP_Document_Store__c
                                                               WHERE DUP_Requested__c = true
                                                               AND DUP_Document_Status__c != 'Uploaded'
                                                               AND DUP_Document_Status__c != 'Reviewed'
                                                               AND DUP_Document_Request__c IN :docRequestSendEmailToCounterpartyForReviewList
                                                              ];
                if(!docStoreRecords.isEmpty()) {
                    Id reviewTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Review_VF_Template'].Id;
                    DUP_DocumentRequestUtil.sendEmailToCounterParty(docRequestSendEmailToCounterpartyForReviewList, reviewTemplateId, docStoreRecords, true);
                }
            }                    
        }
    }
    
    /**
* @description: it checks the status changes in the DUP_Document_Request__c records and add errors
* @param: oldMap from DUP_Document_Request__c Trigger, newList from DUP_Document_Request__c Trigger
* @return: void
*/
    public void checkOnStatusChanges(Map<Id, DUP_Document_Request__c> oldDocumentRequestMap, List<DUP_Document_Request__c> newDocumentRequestList){
        Set<Id> documentRequestIds = oldDocumentRequestMap.keySet();
        Map<Id, DUP_Document_Store__c> documentRequestMap = new Map<Id, DUP_Document_Store__c>();
        List<DUP_Document_Request__c> documentRequestTemp = new List<DUP_Document_Request__c>();
        Map<Id, DUP_Document_Store__c> notUploadedDocumentMap = new Map<Id, DUP_Document_Store__c>();       
        
        for(DUP_Document_Request__c d : newDocumentRequestList){
           if(oldDocumentRequestMap.get(d.Id).DUP_Status_Upload__c != d.DUP_Status_Upload__c){
               //system.debug('in help'+d.DUP_Status_Upload__c);
                documentRequestTemp.add(d);
            }
            documentRequestTemp.add(d);
        }        
        if(documentRequestTemp!= Null && !documentRequestTemp.isEmpty()){
            List<DUP_Document_Store__c> documentStoreList;
            documentStoreList = [SELECT DUP_Requested__c, DUP_Counterparty_Contact_Name__c, DUP_Document_Request__c,DUP_Document_Status__c
                                 FROM DUP_Document_Store__c
                                 WHERE DUP_Requested__c = true 
                                 AND (DUP_Counterparty_Contact_Name__c = null 
                                      OR DUP_Document_Status__c  != 'Reviewed')
                                 AND DUP_Document_Request__c IN :documentRequestTemp
                                ];          
            
            /* Map for Counterparty & Uploaded status check*/
            for(DUP_Document_Store__c ds : documentStoreList){
               if(ds.DUP_Counterparty_Contact_Name__c == null){
                    documentRequestMap.put(ds.DUP_Document_Request__c, ds);
                }
                if(ds.DUP_Document_Status__c != 'Reviewed') {
                    notUploadedDocumentMap.put(ds.id, ds);
                }
            }
            
            for(DUP_Document_Request__c dr : newDocumentRequestList){
                //if(oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c != dr.DUP_Status_Upload__c) {               
                if(dr.DUP_Status_Upload__c == System.Label.DUP_DocumentReqStatus_New){dr.DUP_doc_submitted_status__c= 'New Request';}
                else if(dr.DUP_Status_Upload__c == System.Label.DUP_Status_For_Popup){dr.DUP_doc_submitted_status__c= 'Confirm Details';}           
                else if(dr.DUP_Status_Upload__c == System.Label.DUP_DocumentReqStatus_Review){
                    if(dr.DUP_doc_submitted_status__c == 'Confirm Details'){dr.DUP_doc_submitted_status__c= 'Requested';}
                }            
                else if(dr.DUP_Status_Upload__c == System.Label.DUP_DocumentReqStatus_Cancelled){
                    dr.DUP_doc_submitted_status__c= 'Cancelled';
                    continue;
                }            
                else if(oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c == System.Label.DUP_Status_For_Popup && documentStoreList.size() == 0){
                    dr.addError('You must select and save at least one document');
                }           
                if(oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c == System.Label.DUP_Status_For_Popup && dr.DUP_Status_Upload__c == System.Label.DUP_DocumentReqStatus_Review 
                   && documentRequestMap.containsKey(dr.Id)){
                       dr.addError('You must populate the counterparty contact for the selected documents');  
                   }
                else if(oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c != System.Label.DUP_DocumentReqStatus_New && dr.DUP_Status_Upload__c == System.Label.DUP_DocumentReqStatus_New
                        && oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c != null){
                            dr.addError('You can\'t go to the New Request. Please create a New Document Request if needed');
                        }            
               if(oldDocumentRequestMap.get(dr.Id).DUP_Status_Upload__c == System.label.DUP_DocumentReqStatus_Review){
                    if(dr.DUP_Status_Upload__c == System.label.DUP_DocumentReqStatus_Approved && !notUploadedDocumentMap.isEmpty()){
                        dr.addError('Not all requested documents have been uploaded or approved');                
                    }               
                    if(dr.DUP_Status_Upload__c == System.label.DUP_Status_For_Popup){
                        dr.DUP_Additional_Information__c = true;                    
                    }             
                    if(dr.DUP_Status_Upload__c == System.label.DUP_DocumentReqStatus_Approved){
                        if(dr.DUP_ICOSId__c == null){
                            dr.addError('Before approving the request, the ICOSId must be populated');
                        }
                        dr.DUP_ApprovedDate__c = System.now().date();
                        dr.DUP_doc_submitted_status__c= 'Review Completed';
                    }                
                }            
            }                 
        }      	
    }
    
    /**
* @description: it validates the DUP_requestor_emails__c changes in the DUP_Document_Request__c records and add errors
* @param: newList from DUP_Document_Request__c Trigger
* @return: void
*/
    public void validateRequestorEmail(List<DUP_Document_Request__c> newDocumentRequestList,Map<Id, DUP_Document_Request__c> oldDocumentRequestMap){
        for(DUP_Document_Request__c dr : newDocumentRequestList){
            if((oldDocumentRequestMap!=null && oldDocumentRequestMap.get(dr.Id).DUP_Requestor_emails__c != dr.DUP_Requestor_emails__c) || oldDocumentRequestMap==null ){
                if(dr.DUP_Requestor_emails__c!=null && dr.DUP_Requestor_emails__c!=''){
                    String temp = dr.DUP_Requestor_emails__c.trim();
                    //temp = temp.replace(' ', '');
                    //dr.DUP_Requestor_emails__c = temp;
                    String tempDomain = temp.toLowerCase();
                    temp = temp.replace('.', '');
                    temp = temp.replace('-', '');
                    temp = temp.replace('_', '');
                    temp = temp.replace(',', '');
                    temp = temp.replace('@', '');
                    temp = temp.replace('\r\n','');
                    temp = temp.replace('\n','');
                    temp = temp.replace('\r','');
                    
                    if(!temp.isAlphanumeric()){
                        dr.DUP_Requestor_emails__c.addError('Please enter valid BP email addresses and if there are multiple email addresses kindly separate them with a ",". Spaces are not allowed.!');
                    }
                    else{
                        dr.DUP_Requestor_emails__c = (dr.DUP_Requestor_emails__c.trim()).removeEnd(',');
                        List<String> requestorEmails = tempDomain.split(',');
                        if(requestorEmails!=null && !requestorEmails.isEmpty()){
                            for(String email : requestorEmails){
                                email = email.trim();                                
                                if(email.length()>1 && !((email.substring(0, 1)).isAlphanumeric()) || (!email.endsWith('.bp.com') && !email.endsWith('@bp.com')) || email.countMatches('@')!=1 || email.indexOf('.com') < email.lastindexOf('.') ){
                                  dr.DUP_Requestor_emails__c.addError('Please enter valid BP email addresses and if there are multiple email addresses kindly separate them with a ","!');
                                }
                                
                            }
                        }
                    }               
                }
            } 
        }
    }
}