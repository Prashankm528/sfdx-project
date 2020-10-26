/*****************************************************************************************
*       Date:           03SEP19
*       Author:         Payal Ahuja - IBM
*       Description:    Controller class for DUP_AddDocumentController and DUP_AddDocumentSupport
*       Updated by:     Alessandro Miele - IBM (adding methods and refactoring)
*****************************************************************************************/

public With Sharing class DUP_AddDocumentController {
    /**
    * @description: method used in the init to initialise the component
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
                DUP_CPcomments__c,
                DUP_Document_Request__r.id,
                DUP_Reject_Comments__c,
                DUP_RejectComments_Available__c,
                DUP_Description__c,
                DUP_Certified_True_Copy__c 
            FROM DUP_Document_Store__c 
            WHERE DUP_Document_Request__r.id =: docRequestId 
                AND DUP_Requested__c = true
        ];     
        return documentList; 
    }  

    /**
    * @description: method used to retrieve the file linked to a DUP_Document_Store__c
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

    /**
    * @description: method used to resend the communication to the counterparty
    * @param: document request id
    * @return: void
    */      
    @AuraEnabled
    public static Integer sendReminder(Id docRequestId){     
        System.debug('inside sendReminder');
        List<DUP_Document_Request__c> documentRequestList = [SELECT Id FROM DUP_Document_Request__c WHERE Id =: docRequestId];
        Id reminderTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Reminder_VF_Template'].Id;
        //Create a list of Document Store with the Counterparty Email related to the Document Request list
        List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                DUP_Document_Request__c
            FROM DUP_Document_Store__c
            WHERE DUP_Requested__c = true
                AND DUP_Document_Status__c != 'Uploaded'
                AND DUP_Document_Status__c != 'Reviewed'
                AND DUP_Document_Request__c IN :documentRequestList
        ]; 
        system.debug('in sendreminder2'+reminderTemplateId);
        DUP_DocumentRequestUtil.sendEmailToCounterParty(documentRequestList, reminderTemplateId, docStoreRecords, true);
		Integer invocations2 = Limits.getEmailInvocations();
        return invocations2;	
    }

    /**
    * @description: method used to communicate rejection to the counterparty
    * @param: document request id
    * @return: void
    */      
    @AuraEnabled
    public static void sendRejection(Id docRequestId){     
        List<DUP_Document_Request__c> documentRequestList = [SELECT Id FROM DUP_Document_Request__c WHERE Id =: docRequestId];
        Id rejectTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Rejection_VF_Template'].Id;
        //Create a list of Document Store with the Counterparty Email related to the Document Request list
        List<DUP_Document_Store__c> docStoreRecordsWithRejectComment = new List<DUP_Document_Store__c>();
        List<DUP_Document_Store__c> docStoreRecords = [SELECT 
                DUP_Counterparty_Contact_Name__r.DUP_Email__c,
                DUP_Document_Request__c,
                DUP_Reject_Comments__c
            FROM DUP_Document_Store__c
            WHERE DUP_Requested__c = true
                AND DUP_Document_Status__c != 'Reviewed' AND (DUP_Document_Status__c = 'Requested'
                AND DUP_RejectComments_Available__c=true)
                AND DUP_Document_Request__c IN :documentRequestList
                AND DUP_Document_Request__r.DUP_Items_Received_Rollup__c=0
        ];  
        system.debug('size'+docStoreRecords.size());
        if(docStoreRecords.size() !=0){
        for(DUP_Document_Store__c ds : docStoreRecords){
            if(ds.DUP_Reject_Comments__c != null){
                docStoreRecordsWithRejectComment.add(ds);
            }
            else if(ds.DUP_Reject_Comments__c == null){
                throw new AuraHandledException('Problem Sending in email, Please check status!');
            }
        }     
        DUP_DocumentRequestUtil.sendEmailToCounterParty(documentRequestList, rejectTemplateId, docStoreRecordsWithRejectComment, true);     
        }
        else{
            throw new AuraHandledException('Problem Sending in email, Please check status!');
        }
            
    
    }

/**
    * @description: method used to change counterparty contact
    * @param: document request id
    * @return: void
    */      
    @AuraEnabled
    public static String changeCounterPartyContact(Id docRequestId,Id counterParty, String newEmail){
        Map<id,DUP_Document_Store__c> allDocStores =new Map<id,DUP_Document_Store__c>([Select id,(select id from ContentDocumentLinks where contentDocument.LatestPublishedVersion.Dup_Status__c='Uploaded' or contentDocument.LatestPublishedVersion.Dup_Status__c='Rejected'),DUP_Counterparty_Contact_Name__r.DUP_Email__c,DUP_Counterparty_Contact_Name__c,
                                                                                       DUP_Document_Request__r.DUP_Email_Templates__c,DUP_Document_Request__r.DUP_Requestor_Emails__c,
                                                                                       DUP_Document_Request__r.DUP_BP_Entity_Details__r.DUP_Return_Email__c
                                                                                       from DUP_Document_Store__c where DUP_Document_Request__c = :docRequestId and DUP_Document_Status__c='Requested']);
        
        List<DUP_Document_Request__c> docReqList = [select id,DUP_Email_Templates__c,DUP_Requestor_Emails__c,DUP_BP_Entity_Details__r.DUP_Return_Email__c from DUP_Document_Request__c where id=:docRequestId];
        Boolean flag = false;
        
        if(allDocStores!=null && allDocStores.size()>0){
            Id oldCPContact = allDocStores.values()[0].DUP_Counterparty_Contact_Name__c;
            for(DUP_Document_Store__c docStore : allDocStores.values()){
                if(oldCPContact == docStore.DUP_Counterparty_Contact_Name__c && docStore.DUP_Counterparty_Contact_Name__c != counterParty && (docStore.contentDocumentLinks==null || docStore.contentDocumentLinks.isEmpty())){
                	docStore.DUP_Counterparty_Contact_Name__c = counterParty;
                    flag = true;
                }
                else if(!docStore.contentDocumentLinks.isEmpty() || oldCPContact != docStore.DUP_Counterparty_Contact_Name__c){
                    return 'NoUpdate';
                }
            } 
            
            if(flag){
                update allDocStores.values();
                
                for(DUP_Document_Store__c docStore : allDocStores.values()){
                    docStore.DUP_Counterparty_Contact_Name__r = new DUP_Counterparty_Contact__c(Id=counterParty,DUP_Email__c = newEmail) ;
                }
                Id requestTemplateId;
                if(docReqList[0].DUP_Email_Templates__c.equalsIgnoreCase('Additional Info Request Template')|| 
                  docReqList[0].DUP_Email_Templates__c.equalsIgnoreCase('Additional Info Review Request Template')){
                    requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_AddInfo_VF_Template'].Id;
                }
                else if(docReqList[0].DUP_Email_Templates__c.equalsIgnoreCase('Review Template')  ){
                            requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Review_VF_Template'].Id;
                        }
                else{
                    requestTemplateId = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'DUP_Request_VF_Template'].Id;
                }
                
                DUP_DocumentRequestUtil.sendEmailToCounterParty(docReqList, requestTemplateId, allDocStores.values(), true);
                return 'Updated';
            }
            else {
                return 'NoUpdate';
            }
        }
        else{
            return 'NoUpdate';
        }
    } 
    
    @AuraEnabled
    public static List<sObject> getLookupList(String searchTerm, String objName) {
        return DUP_AddDocumentListController.getLookupList(searchTerm, objName);
    }
}