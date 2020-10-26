/**************************************************************************************************************************
 * Date           : 23-MAR-2020
 * Author         : Roselin Hephzibah
 * Description    : Handler class for ANZ Bots
 * Modifications  : 23-MAR-2020 Roselin - Initial
                    30-APR-2020 Roselin - Cancel LOT case when it has no/multi attachments.
                    22-MAY-2020 Roselin - Remove Content Version Id and use Content Document Id.
                    01-JUL-2020 Roselin - Bulkified the code.
                    19-AUG-2020 Roselin - Handled Siebel migrated VOC/LOT Cases without EmailMessage and Attachments in Case.
 ****************************************************************************************************************************/ 
public with sharing class GCM_ANZ_Bot_Handler {
/********************************************************************************
 * Adds attachment Ids (Content Document Id) and Case Id to GCM ANZ Bot Attachment object.
 ********************************************************************************/ 
    @InvocableMethod
    public static void addAttachmentRecords(List<Id> caseIdList) {
        try{
            GCM_ANZ_Bot_Handler.addAttachmentRecordsFuture(caseIdList);
        }catch(Exception e) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_ANZ_Bot_Handler', 'addAttachmentRecords', caseIdList, 'GCM_Application_Administrator');
        }
    }
    
    @future
    public static void addAttachmentRecordsFuture (List<Id> caseIdList){
        Map<Id,Sobject> attachParentMap = new Map<Id, Sobject>();
        Map<Id,Id> ContentDocumentParentMap = new Map<Id,Id>();
        Map<Id,Id> EmailCaseMap = new Map<Id,Id>();
        Map<Id,List<Id>> CaseContentDocumentMap = new Map<Id,List<Id>>();
        List<Id> cancelCaseIdList = new List<Id>();
        List<GCM_ANZ_Bot_Attachment__c> anzBotAttachList = new List<GCM_ANZ_Bot_Attachment__c>();
        Set<String> allowedFileExtSet = new Set<String>{'pdf','xlsx','xls','csv'}; 
        String botName;
        
        try{
            Map<Id,Case> caseMap = new Map<ID, Case>([SELECT Id, CaseNumber, OwnerId, Owner.Name, Description, SuppliedEmail, GCM_Site__c, AccountId, Account.Name, Account.AccountNumber, Account.Account_ERP_ID__c FROM Case Where Id IN: caseIdList and IsClosed =: false]);
            if(!caseMap.isEmpty()){
                List<EmailMessage> emailList = [Select Id, ParentId from EmailMessage Where ParentId IN: caseMap.keyset() and Incoming = true];
                if(!emailList.isEmpty()){
                    for(Case cas : caseMap.values()){
                        Boolean emailtocase = false;
                        for(EmailMessage e : emailList){
                            if(cas.Id.equals(e.ParentId)){
                                emailtocase = true;
                                attachParentMap.put(e.Id,e);
                                EmailCaseMap.put(e.Id, e.ParentId);
                            }
                        }
                        if(!emailtocase){
                            attachParentMap.put(cas.Id,cas);
                        }
                     }
                 }else {
                    attachParentMap.putAll(caseMap);             
                }
            }
            
            if(!attachParentMap.isEmpty()){
                for(Id attachParentId : attachParentMap.Keyset()){
                    //Query Content Document Links
                    List<ContentDocumentLink> cdLinkList = [Select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink Where LinkedEntityId =: attachParentId];
                    if(!cdLinkList.isEmpty()){
                        List<Id> contentDocumentIdList = new List<Id>();
                        for(ContentDocumentLink cdlink : cdLinkList){
                            contentDocumentIdList.add(cdlink.ContentDocumentId);
                        }
                        if(String.valueof(attachParentId).StartsWith('02s')){
                            CaseContentDocumentMap.put(EmailCaseMap.get(attachParentId),contentDocumentIdList);
                        } else {
                            CaseContentDocumentMap.put(attachParentId , contentDocumentIdList);
                        }
                    } else {
                        if(String.valueof(attachParentId).StartsWith('02s')){
                                CaseContentDocumentMap.put(EmailCaseMap.get(attachParentId), new List<Id>());
                            } else {
                                CaseContentDocumentMap.put(attachParentId , new List<Id>());
                            }
                    }
                }
            }
                 
            for(Case cas : caseMap.values()){ 
                String caseOwner = cas.Owner.name;
                Matcher pm = Pattern.compile('(?<=AU\\s)(.*)(?=\\sBOT)').matcher(caseOwner);
                Boolean matchFound = pm.find();
                if(matchFound){ 
                    botName = pm.group();
                    system.debug('botName'+botName);
                } else {
                    Matcher pml = Pattern.compile('(?<=Lubes\\s)(.*)(?=\\sBOT)').matcher(caseOwner);
                    Boolean matchFoundLubes = pml.find();
                    if(matchFoundLubes){ 
                        botName = pml.group();
                        system.debug('botName'+botName);
                    }
                }
                
                   
                List<Id> cdLinkIdList = CaseContentDocumentMap.get(cas.Id);
                
                if(cdLinkIdList.isEmpty() && String.isNotBlank(botName) && botName.equalsIgnoreCase('LOT')){
                    cancelCaseIdList.add(cas.Id);
                }else {
                    List<GCM_ANZ_Bot_Attachment__c> anzBotAttachCaseList = new List<GCM_ANZ_Bot_Attachment__c>();
                    List<GCM_ANZ_Bot_Attachment__c> existingAttach = [Select Id, GCM_Case_Id__c, GCM_Content_Document_Id__c from GCM_ANZ_Bot_Attachment__c Where GCM_Case_Id__c =: cas.Id];
                    List<Id> existingContentDocumentIDList = new List<Id>();
                    if(!existingAttach.isEmpty()){
                        for(GCM_ANZ_Bot_Attachment__c battach : existingAttach){
                            existingContentDocumentIDList.add(battach.GCM_Content_Document_Id__c);
                        }
                    }
                    system.debug('***'+existingContentDocumentIDList.size());
                    List<ContentDocument> cdList = [Select Id, Title, FileType, FileExtension from ContentDocument Where Id IN: cdLinkIdList];
                    if(!cdList.isEmpty()){
                       for(ContentDocument cd : cdList){
                            if(allowedFileExtSet.contains(cd.FileExtension)){
                                system.debug('Inside allowed ext');
                                if(existingContentDocumentIDList.isEmpty() || (!existingContentDocumentIDList.isEmpty() && !existingContentDocumentIDList.contains(cd.ID))){
                                    GCM_ANZ_Bot_Attachment__c aba = new GCM_ANZ_Bot_Attachment__c();
                                    aba.GCM_File_Extension__c = cd.FileExtension;
                                    aba.GCM_Case_Id__c = cas.Id;
                                    aba.GCM_Sender_Email__c = cas.SuppliedEmail;
                                    aba.GCM_Site__c = cas.GCM_Site__c;
                                    aba.GCM_Title__c = cd.Title;
                                    aba.GCM_Content_Document_Id__c = cd.Id;
                                    aba.GCM_Bot_Name__c = botName;
                                    aba.GCM_Case_Number__c = cas.CaseNumber;
                                    aba.GCM_Account_Identifier__c = cas.Account.AccountNumber;
                                    anzBotAttachCaseList.add(aba);
                                }
                            }
                        }
                    }
                        
                    if((anzBotAttachCaseList.isEmpty() || anzBotAttachCaseList.size() > 1) && String.isNotBlank(botName) && botName.equalsIgnoreCase('LOT')){
                        //Cancel Case When there are multiple attachments for LOT.
                        cancelCaseIdList.add(cas.Id);
                        //GCM_ANZ_Bot_Handler.cancelLOTCase(caseMap.get(caseIdList[0]).Id);
                    } else {
                        anzBotAttachList.addall(anzBotAttachCaseList);
                    }
                }
            }
            //Insert staging Records
            if(!anzBotAttachList.isEmpty()){
                insert anzBotAttachList;
            }
            //Cancel LOT Case
            if(!cancelCaseIdList.isEmpty()){
                GCM_ANZ_Bot_Handler.cancelLOTCase(cancelCaseIdList);
            }
        }catch(Exception e) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_ANZ_Bot_Handler', 'addAttachmentRecordsFuture', new Id[]{}, 'GCM_Application_Administrator');
        }
    }
    
    public static void cancelLOTCase(List<Id> caseIds){
        try{
            List<Case> updateCaseList = new List<Case>();
            for(Id casId : caseIds){
                Case c = new Case();
                c.Id = casId;
                c.Status = 'Cancelled';
                c.Sub_Status__c = 'Cancelled';
                c.GCM_BOT_Resolution_Code__c = 'LOT Case Cancelled';
                c.GCM_ByPassValidation_Timestamp__c = system.now();
                updateCaseList.add(c);
            }
            if(!updateCaseList.isEmpty())
                Database.update(updateCaseList, false);
        }catch(Exception e) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_ANZ_Bot_Handler', 'cancelLOTCase', caseIds, 'GCM_Application_Administrator');
        }
    }
}