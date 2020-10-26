/****************************************************************************************************
*  Date          : 29-JAN-2020
*  Author        : Roselin Hephzibah
*  Description   : GCM_LinkInteractionDetails
*  Modifications : 29-JAN-2020 Roselin - Initial version.
                   22-APR-2020 Roselin - Enhanced to send updated case details to WDE.
                   24-JUN-2020 Roselin - Optimized the code.
****************************************************************************************************/
global with sharing class GCM_LinkInteractionDetails {
     
     private ApexPages.StandardController standardController;
     public static string interactionId {get {
        if (String.isBlank(interactionId) &&  String.isNotBlank(parentInteractionId)){
            interactionId = parentInteractionId;
        }
        return interactionId;
    }set;}
    public static string parentInteractionId {get;set;}
    public static boolean disableButton {get{
        boolean disableBtn = true;
        List<Id> idList = new List<Id>();
        try{
            String callCenterId = [SELECT Id, CallCenterId from User WHERE Id =: UserInfo.getUserId()].CallCenterId;
            if(String.isNotBlank(callCenterId)){
                disableBtn = false;
                idList.add(Id.valueof(callCenterId));
            }
        }Catch (Exception e){ BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'disableButton', idList, 'GCM_Application_Administrator'); 
        }
        return disableBtn;
    }set;}
    public List<Task> interactionList = new List<Task>();
    public List<SelectOption> interactionDisplayList 
    {
        get
        {
            List<Id> interactionIdList = new List<Id>();
            try {
                interactionList = [Select Id, WhoId, Type, Who.Name, softphone_it__IWS_Interaction_ID__c, softphone_it__IWS_Media_Name__c, GCM_Call_From__c, GCM_Call_To__c, calltype, Status, RecordTypeId, RecordType.DeveloperName from Task where Id =: apexpages.currentpage().getparameters().get('id') and ownerId =: UserInfo.getUserId() and RecordType.Developername =: 'GCM_Task' and softphone_it__IWS_Interaction_ID__c != null and GCM_Interaction_Mark_Done__c =: false];
                interactionDisplayList = new List<SelectOption>(); 
                interactionDisplayList.add(new SelectOption('', '--None--'));
                if(!interactionList.isEmpty()){
                    for(Task t : interactionList){  
                        String optionLabel = t.softphone_it__IWS_Interaction_ID__c;
                        String callTyp;
                        String mediaTyp;
                        String phoneNum;
                        if(t.CallType == 'Inbound'){
                            callTyp = 'In';
                            phoneNum = t.GCM_Call_From__c;
                        } else if(t.CallType == 'Outbound'){
                            callTyp = 'Out';
                            phoneNum = t.GCM_Call_To__c;
                        } 
                        if(t.softphone_it__IWS_Media_Name__c == 'voice') mediaTyp = 'Call'; 
                        else if(t.softphone_it__IWS_Media_Name__c == 'email') {
                            if(t.Type.startsWithIgnoreCase('Fax'))
                                mediaTyp = 'Fax';
                            else
                                mediaTyp = 'Email'; 
                        }
                        if(t.WhoId != null){
                            optionLabel = mediaTyp+' '+callTyp+' - '+t.Who.Name+' - '+phoneNum;
                        }else {
                            optionLabel = mediaTyp+' '+callTyp+' - '+phoneNum; 
                        }
                        interactionIdList.add(t.Id);
                        interactionDisplayList.add(new SelectOption(t.softphone_it__IWS_Interaction_ID__c,optionLabel)); 
                    }
                }
            }Catch (Exception e){ BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'interactionDisplayList', interactionIdList, 'GCM_Application_Administrator'); 
                }
            return interactionDisplayList;
        }
        set;
    }
     public static Task taskRec{get{
         List<Id> idList = new List<Id>();
         try{
             Task t = [Select Id, GCM_Account__r.Name, Who.Name, softphone_it__IWS_Interaction_ID__c, WhatId, status, GCM_Interaction_Mark_Done__c from Task Where Id =: apexpages.currentpage().getparameters().get('id') AND GCM_Interaction_Mark_Done__c =: False];
             if(String.isNOTBlank(t.WhatId) && String.valueof(t.WhatId).startswith('500')){
                 taskCaseRec = [Select Id, CaseNumber FROM Case WHERE Id =: t.WhatId];
             }
             idList.add(t.Id);
             return t;
         }catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_LinkInteractionDetails', 'taskRec', idList, 'GCM_Application_Administrator');  }
        return null;
        
     }set;}
     public static Case taskCaseRec{get;set;}
     
/****************************************************************************************************
  GCM_LinkInteractionDetails parameterized constructor.
 ****************************************************************************************************/
    public GCM_LinkInteractionDetails(ApexPages.StandardController standardController)
    {
        try{
        this.standardController = standardController;
        Task tsk = (Task)standardController.getRecord();
        tsk = [Select Id, softphone_it__IWS_Interaction_ID__c, WhatId, WhoId, Who.Name, GCM_Account__c FROM Task WHERE Id =: tsk.Id];
            parentInteractionId = tsk.softphone_it__IWS_Interaction_ID__c != null? tsk.softphone_it__IWS_Interaction_ID__c : null;
        }catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_LinkInteractionDetails', 'GCM_LinkInteractionDetails', new List<Id>{standardController.getId()}, 'GCM_Application_Administrator');  }
    }
    
/****************************************************************************************************
  GCM_LinkInteractionDetails parameterized constructor.
 ****************************************************************************************************/
    public void associateCaseToTask()
    {
        List<EmailMessage> insertEmailList = new List<EmailMessage>();
        List<EmailMessage> deleteEmailList = new List<EmailMessage>();
        List<Id> delEmailIdList = new List<Id>();
        List<Id> idList = new List<Id>();
        List<Task> updateExistingTaskList = new List<Task>();
        List<Case> updateExistingCaseList = new List<Case>();
        try{
            List<Task> taskList = [Select Id, GCM_Email_Message_Id__c, softphone_it__IWS_Interaction_ID__c, WhatId, status, GCM_Interaction_Mark_Done__c, GCM_Call_Start_Date__c  from Task Where Id =: apexpages.currentpage().getparameters().get('id') and softphone_it__IWS_Interaction_ID__c != null and status != 'Completed' and GCM_Interaction_Mark_Done__c = false];
            system.debug('task'+taskList);
            if(!taskList.isEmpty()){
                for(Task tsk : taskList){
                    idList.add(tsk.Id);
                    if(tsk.WhatId != null && String.valueof(tsk.WhatId).startswith('500') && tsk.GCM_Email_Message_Id__c != null){
                        List<EmailMessage> emailMsgList = [Select Id, ParentId, Parent.Status, Parent.IsClosed, RelatedToId, ActivityId, Subject, CcAddress, TextBody, HTMLBody, MessageDate, FromAddress, ToAddress, Status, Headers, CreatedById from EmailMessage Where Id =: tsk.GCM_Email_Message_Id__c];
                            if(!emailMsgList.isEmpty() && emailMsgList.get(0).ParentId != tsk.WhatId){
                                EmailMessage emg = new EmailMessage();
                                emg.ParentId = tsk.WhatId;
                                emg.RelatedToId = tsk.WhatId;
                                emg.ActivityId = tsk.Id;
                                emg.Subject = emailMsgList.get(0).Subject;
                                emg.TextBody = emailMsgList.get(0).TextBody;
                                emg.HTMLBody = emailMsgList.get(0).HTMLBody;
                                emg.MessageDate = tsk.GCM_Call_Start_Date__c;
                                emg.FromAddress = emailMsgList.get(0).FromAddress;
                                emg.ToAddress = emailMsgList.get(0).ToAddress;
                                emg.CcAddress = emailMsgList.get(0).CcAddress;
                                emg.Status = emailMsgList.get(0).Status;
                                emg.Headers = emailMsgList.get(0).Headers;
                                insertEmailList.add(emg);
                                deleteEmailList.add(emailMsgList.get(0));
                                delEmailIdList.add(emailMsgList.get(0).Id);
                            }
                    }
                }
                if(!insertEmailList.isEmpty() && !deleteEmailList.isEmpty()){
                    insert insertEmailList;
                    Task tas = new Task();
                    tas.Id = taskList.get(0).Id;
                    tas.GCM_Email_Message_Id__c = insertEmailList.get(0).Id;
                    tas.GCM_ByPassValidation_Timestamp__c = system.now();
                    updateExistingTaskList.add(tas);
                    if(!insertEmailList.get(0).Parent.IsClosed){
                        Case cas = new Case();
                        cas.Id = taskList.get(0).WhatId;
                        cas.GCM_Parent_Interaction_Id__c = taskList.get(0).softphone_it__IWS_Interaction_ID__c;
                        cas.GCM_ByPassValidation_Timestamp__c = system.now();
                        updateExistingCaseList.add(cas);
                    }
                }
                if(!updateExistingTaskList.isEmpty()){
                    update updateExistingTaskList;
                }
                if(!updateExistingCaseList.isEmpty()){
                    update updateExistingCaseList;
                }
                if(!insertEmailList.isEmpty() && !deleteEmailList.isEmpty()){
                    List<GCM_GSYS_DuplicateEmailHandler.FlowInputs> flowInputList = new List<GCM_GSYS_DuplicateEmailHandler.FlowInputs>();
                    GCM_GSYS_DuplicateEmailHandler.FlowInputs fi = new GCM_GSYS_DuplicateEmailHandler.FlowInputs();
                    fi.originalEmailMsg = deleteEmailList.get(0);
                    fi.newEmailMsgId = insertEmailList.get(0).Id;
                    flowInputList.add(fi);
                    if(!flowInputList.isEmpty()){
                        GCM_GSYS_DuplicateEmailHandler.cloneAttachment(flowInputList);
                    }
                }
            }
        }catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_LinkInteractionDetails', 'associateCaseToTask', idList, 'GCM_Application_Administrator'); }
    }

/****************************************************************************************************
  Custom Method for Page load
 ****************************************************************************************************/    
    public void pageLoad() {  }
}