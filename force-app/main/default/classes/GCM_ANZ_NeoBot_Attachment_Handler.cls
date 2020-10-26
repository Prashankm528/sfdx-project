/**************************************************************************************************************************
 * Date           : 26-SEP-2020
 * Author         : IBM
 * Description    : Handler class for ANZ Neo BOT Platform Event
 * Modifications  : 26-SEP-2020 IBM - Initial
                    
****************************************************************************************************************************/ 
public class GCM_ANZ_NeoBot_Attachment_Handler {
    /********************************************************************************
     * This method called by Process Builder and upsert GCM ANZ Bot Attachment.
     ********************************************************************************/     
    @InvocableMethod
    public static void upsertBOTAttachment(List<NeoBotEvent> botEvents) {
        System.debug('Neo BOT Platform Event Fired ' + botEvents);
        if(botEvents.size()>0){
            //Create new BOT Attachment
            if(String.isNotBlank(botEvents[0].contentDocumentId) && String.isNotBlank(botEvents[0].linkedEntityId)){
                System.debug('Creating BOT Attachment ');
                createBOTAttachment(botEvents[0].linkedEntityId, botEvents[0].contentDocumentId, botEvents[0].fileAlias, botEvents[0].botName);
            }
            else if(String.isNotBlank(botEvents[0].contentDocumentId) && String.isBlank(botEvents[0].linkedEntityId)){
                System.debug('Updating BOT Attachment ');
                updateBOTAttachment(botEvents[0].contentDocumentId, botEvents[0].fileAlias, botEvents[0].botName);
            }
        }
    }
    @future
    public static void createBOTAttachment(String linkedEntityId, String contentDocumentId, String fileAlias, String botName){
        
        Set<String> allowedFileExtSet = new Set<String>{'pdf','xlsx','xls','csv', 'xlsm'};
        try{
            Map<Id,Case> caseMap = new Map<ID, Case>([SELECT Id, CaseNumber, OwnerId, Owner.Name, SuppliedEmail, GCM_Site__c, AccountId, Account.AccountNumber, GCM_Opportunity__c FROM Case Where Id = :linkedEntityId and IsClosed = false]);
            Map<Id,ContentDocumentLink> contentDocLinkMap = new Map<Id,ContentDocumentLink>();
            List<GCM_ANZ_Bot_Attachment__c> botAttachCreate = new List<GCM_ANZ_Bot_Attachment__c>();
            for(ContentDocumentLink conLink : [Select Id, LinkedEntityId, ContentDocumentId, ContentDocument.FileExtension, ContentDocument.Title  from ContentDocumentLink where LinkedEntityId = :linkedEntityId and ContentDocumentId = :contentDocumentId]){
                contentDocLinkMap.put(conLink.ContentDocumentId, conLink);
            }
            Map<Id, ContentVersion> contentDocVersionMap = new Map<Id, ContentVersion>();
            for(ContentVersion contVersion : [Select Id, ContentDocumentId, IsMajorVersion from ContentVersion where ContentDocumentId = :contentDocumentId and IsLatest = true]){
                contentDocVersionMap.put(contVersion.ContentDocumentId, contVersion);
            }
            System.debug('Case Map '+caseMap.size());
            System.debug('ContentDocumentLink  '+contentDocLinkMap.size());
            System.debug('contentDocVersionMap  '+contentDocVersionMap.size());
            for(ContentDocumentLink conLink : contentDocLinkMap.values()){
                
                Case cas = caseMap.get(conLink.LinkedEntityId);
                String fileExtension = String.isNotBlank(conLink.ContentDocument.FileExtension) ? conLink.ContentDocument.FileExtension : '';
                System.debug('fileExtension '+fileExtension);
                if(allowedFileExtSet.contains(fileExtension)){
                    
                    GCM_ANZ_Bot_Attachment__c botAttachment = new GCM_ANZ_Bot_Attachment__c();
                    botAttachment.GCM_File_Extension__c = fileExtension;
                    botAttachment.GCM_Case_Id__c = conLink.LinkedEntityId;
                    botAttachment.GCM_Sender_Email__c = (cas != null) ? cas.SuppliedEmail : '';
                    botAttachment.GCM_Site__c = (cas != null) ? cas.GCM_Site__c : '';
                    botAttachment.GCM_Title__c = String.isNotBlank(conLink.ContentDocument.Title) ? conLink.ContentDocument.Title : '';
                    botAttachment.GCM_Content_Document_Id__c = conLink.ContentDocumentId;
                    botAttachment.GCM_Bot_Name__c = botName;
                    botAttachment.GCM_Case_Number__c = (cas != null) ? cas.CaseNumber : '';
                    botAttachment.GCM_Account_Identifier__c = (String.isNotBlank(cas.AccountId) && String.isNotBlank(cas.Account.AccountNumber)) ? cas.Account.AccountNumber : '';
                    botAttachment.GCM_Opportunity_Id__c = (cas != null) ? cas.GCM_Opportunity__c : null;
                    botAttachment.GCM_File_Alias__c = fileAlias;
                    System.debug('Is majorversion ' + contentDocVersionMap.containsKey(conLink.ContentDocumentId));
                    botAttachment.GCM_Is_Major_Version__c = contentDocVersionMap.containsKey(conLink.ContentDocumentId) != null ? contentDocVersionMap.get(conLink.ContentDocumentId).IsMajorVersion : false;
                    botAttachCreate.add(botAttachment);                    
                }
            }
            System.debug('BOT Attachment Create size '+botAttachCreate.size());
            if(botAttachCreate.size()>0){
                insert botAttachCreate;
            }
         }catch(Exception e) {
            System.debug('Exception in creating BOT Attachment ' + e.getStackTraceString());
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_ANZ_NeoBot_Attachment_Handler', 'createBOTAttachment', new Id[]{linkedEntityId}, 'GCM_Application_Administrator');
        }
    }
    @future
    public static void updateBOTAttachment(String contentDocumentId, String fileAlias, String botName){
        
        Set<String> allowedFileExtSet = new Set<String>{'pdf','xlsx','xls','csv', 'xlsm'};
        try{
            List<Id> caseIds = new List<Id>();
            Map<Id, ContentVersion> contentDocVersionMap = new Map<Id, ContentVersion>();
            List<GCM_ANZ_Bot_Attachment__c> botAttachUpdate = new List<GCM_ANZ_Bot_Attachment__c>();
            List<GCM_ANZ_Bot_Attachment__c> botAttachments = [Select Id, GCM_Case_Id__c, GCM_Content_Document_Id__c from GCM_ANZ_Bot_Attachment__c where GCM_Content_Document_Id__c = :contentDocumentId];
            
            for(GCM_ANZ_Bot_Attachment__c botAttach : botAttachments){
                caseIds.add(botAttach.GCM_Case_Id__c);
            }
            Map<Id,Case> caseMap = new Map<ID, Case>([SELECT Id, CaseNumber, OwnerId, Owner.Name, SuppliedEmail, GCM_Site__c, AccountId, Account.AccountNumber, GCM_Opportunity__c FROM Case Where Id = :caseIds and IsClosed = false]);            
            Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>([Select Id, Title, FileType, FileExtension from ContentDocument Where Id = :contentDocumentId]);            
            for(ContentVersion contVersion : [Select Id, ContentDocumentId, IsMajorVersion from ContentVersion where ContentDocumentId = :contentDocumentId and IsLatest = true]){
                contentDocVersionMap.put(contVersion.ContentDocumentId, contVersion);
            }
            System.debug('botAttachments count '+ botAttachments.size());
            System.debug('botAttachments '+ botAttachments);
            for(GCM_ANZ_Bot_Attachment__c botAttach : botAttachments){ 
                
                ContentDocument contentDoc = contentDocMap.get(botAttach.GCM_Content_Document_Id__c);
                system.debug('contentDoc '+contentDoc);
                if(contentDoc != null && allowedFileExtSet.contains(contentDoc.FileExtension)){
                   
                    if(contentDocMap.containsKey(contentDoc.Id)){
                        
                        Case cas = caseMap.get(botAttach.GCM_Case_Id__c);
                        String fileExtension = String.isNotBlank(contentDoc.FileExtension) ? contentDoc.FileExtension : '';
                        GCM_ANZ_Bot_Attachment__c botAttachment = new GCM_ANZ_Bot_Attachment__c();
                        botAttachment.Id = botAttach.Id;
                        botAttachment.GCM_File_Extension__c = fileExtension;
                        botAttachment.GCM_Case_Id__c = cas.Id;
                        botAttachment.GCM_Sender_Email__c = (cas != null) ? cas.SuppliedEmail : '';
                        botAttachment.GCM_Site__c = (cas != null) ? cas.GCM_Site__c : '';
                        botAttachment.GCM_Title__c = String.isNotBlank(contentDoc.Title) ? contentDoc.Title : '';
                        botAttachment.GCM_Content_Document_Id__c = contentDoc.Id;
                        botAttachment.GCM_Bot_Name__c = botName;
                        botAttachment.GCM_Case_Number__c = (cas != null) ? cas.CaseNumber : '';
                        botAttachment.GCM_Account_Identifier__c = (String.isNotBlank(cas.AccountId) && String.isNotBlank(cas.Account.AccountNumber)) ? cas.Account.AccountNumber : '';
                        botAttachment.GCM_Opportunity_Id__c = (cas != null) ? cas.GCM_Opportunity__c : null;
                        botAttachment.GCM_File_Alias__c = fileAlias;
                        System.debug('Is majorversion ' + contentDocVersionMap.containsKey(contentDoc.Id));
                        botAttachment.GCM_Is_Major_Version__c = contentDocVersionMap.containsKey(contentDoc.Id) != null ? contentDocVersionMap.get(contentDoc.Id).IsMajorVersion : false;
                        //botAttachment.GCM_Downloaded__c = false;
                        botAttachUpdate.add(botAttachment);                        
                    }
                }
            }
            System.debug('Update BOT Attachment Size ' + botAttachUpdate.size());
            if(botAttachUpdate.size()>0){
            	update botAttachUpdate;    
            }            
         }catch(Exception e) {
            System.debug('Exception in updating BOT Attachment ' + e.getStackTraceString());
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_ANZ_NeoBot_Attachment_Handler', 'updateBOTAttachment', new Id[]{contentDocumentId}, 'GCM_Application_Administrator');
        }
    }
 
    //Wrapper Class for BOT Platform Event for Process Builder
    public class NeoBotEvent{
    
        @InvocableVariable
        public String botName;
        @InvocableVariable
        public String fileAlias;        
        @InvocableVariable
        public String linkedEntityId;
        @InvocableVariable
        public String contentDocumentId;
    }
}