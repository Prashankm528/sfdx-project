/****************************************************************************************************
*  Date          : 24-DEC-2019
*  Author        : Roselin Hephzibah
*  Description   : GCM_CTIController
*  Modifications : 24-DEC-2019 Roselin - Initial Version.
                   02-JAN-2020 Roselin - Modified to include Type field on task creation.
****************************************************************************************************/
global with sharing class GCM_CTIController {
    
    private ApexPages.StandardController standardControllerExt;
    public static Id caseRecordId{get;set;}
    public static string caseNum{get;set;}
    public static string accName{get;set;}
    public static string conName{get;set;}
    public static Case caseRec{get;set;}
    public static string interactionId {get {
        if (String.isBlank(interactionId) &&  String.isNotBlank(parentInteractionId)){
            interactionId = parentInteractionId;
        }
        return interactionId;
    }set;}
    public static string parentInteractionId {get;set;}
    public static boolean caseAssociated {get;set;}
    public static string disableButton {get{
        string disableBtn = 'None';
        List<Id> idList = new List<Id>();
        try{
            User u  = [SELECT Id, CallCenterId, ProfileId, Profile.Name, UserRoleId, UserRole.DeveloperName from User WHERE Id =: UserInfo.getUserId()];
            if(String.isNotBlank(u.CallCenterId)){
                disableBtn = 'CallCenter';
                idList.add(Id.valueof(u.CallCenterId));
                String profName = u.ProfileId != null? u.Profile.Name : null;
                String roleName = u.UserRoleId != null? u.UserRole.DeveloperName : null;
                if((profName != null && profName.StartsWith('GCM') && profName.EndsWith('GSYS')) || (roleName != null && roleName == 'GCM_Global_Operations')){
                    disableBtn = 'NewEmail';
                }
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
                interactionList = [Select Id, WhoId, Type, Who.Name, softphone_it__IWS_Interaction_ID__c, softphone_it__IWS_Media_Name__c, GCM_Call_From__c, GCM_Call_To__c, calltype, Status, RecordTypeId, RecordType.DeveloperName from Task where ownerId =: UserInfo.getUserId() and RecordType.Developername =: 'GCM_Task' and softphone_it__IWS_Interaction_ID__c != null and GCM_Interaction_Mark_Done__c =: false];
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

/****************************************************************************************************
  GCM_CTIController constructor.
 ****************************************************************************************************/    
    public GCM_CTIController() { } 
    
/****************************************************************************************************
  GCM_CTIController parameterized constructor.
 ****************************************************************************************************/
    public GCM_CTIController(ApexPages.StandardController standardControllerExt)
    {
        List<Id> caseIdList = new List<Id>();
        try {
            this.standardControllerExt = standardControllerExt;
            Case c = (Case)standardControllerExt.getRecord();
            caseAssociated = false;
            c = [Select Id, CaseNumber, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email, GCM_Parent_Interaction_Id__c, Type, Area__c, Sub_Area__c, Priority, Status, Sub_Status__c, Owner.Name from Case where Id =: c.Id];
            caseRecordId = c.Id;
            caseRec = c;
            caseIdList.add(c.Id);
            caseNum = c.CaseNumber;
            accName = c.AccountId != null? c.Account.Name : null;
            conName = c.ContactId != null? c.Contact.Name : null;
            parentInteractionId = c.GCM_Parent_Interaction_Id__c != null? c.GCM_Parent_Interaction_Id__c : null;
        }Catch (Exception e){ BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'GCM_CTIController', caseIdList, 'GCM_Application_Administrator'); 
                }
    }
    
/****************************************************************************************************
  Fetch the task record with Id.
 ****************************************************************************************************/    
    @AuraEnabled
    public static Task getTaskDetails(Id taskId) {
        List<Id> taskIdList = new List<Id>();
        try{
            List<Task> taskRecList = [Select Id, GCM_BU__c, WhatId, GCM_Call_Start_Date__c, softphone_it__IWS_Media_Name__c , GCM_Account__c, WhoId, softphone_it__IWS_Interaction_ID__c, Subject, Description, Status, GCM_Sales_Organisation__c, GCM_Account__r.Business_Unit__c from Task where Id =: taskId and Status != 'Completed' and softphone_it__IWS_Interaction_ID__c != null];
            if(!taskRecList.isEmpty()){
                if(taskRecList[0].WhatId != null && string.valueof(taskRecList[0].WhatId).startsWith('500')){
                    List<Case> casList = [Select Id, CaseNumber, GCM_Parent_Interaction_Id__c from Case WHERE Id =: taskRecList[0].WhatId];
                    if(!casList.isEmpty() && casList[0].GCM_Parent_Interaction_Id__c == taskRecList[0].softphone_it__IWS_Interaction_ID__c){
                        return null;
                    }
                }
                taskIdList.add(taskRecList[0].Id);
                return taskRecList[0];
            }
        }catch(Exception e){  BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'getTaskDetails', taskIdList, 'GCM_Application_Administrator'); }
        return null;
    }
    
/****************************************************************************************************
  Fetch the Case recordType Id.
 ****************************************************************************************************/    
    @AuraEnabled
    public static Id getCaseRecordTypeId(String businessUnit, String accBusinessUnit) {
        List<Id> recTypeIdList = new List<Id>();
        try{
            if(accBusinessUnit != null && accBusinessUnit != ''){
                List<GCM_Data_Map__mdt> dataMapList = new List<GCM_Data_Map__mdt>([Select Id, GCM_Active__c, GCM_Source__c, GCM_Target__c, GCM_Type__c from GCM_Data_Map__mdt WHERE GCM_Type__c =: 'CTI_CaseRecordTypeMap' AND GCM_Active__c = TRUE AND GCM_Source__c =: accBusinessUnit]);
                if(!dataMapList.isEmpty()){
                    String recordTypeDeveloperName;
                    for(GCM_Data_Map__mdt dm: dataMapList){
                        recordTypeDeveloperName = dm.GCM_Target__c;
                    }
                    Id recTypeId = getRecordTypeId(recordTypeDeveloperName, 'Case');
                    if(recTypeId != null){
                        return recTypeId;
                        }
                }
            }
        }catch(Exception e){    BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'getCaseRecordTypeId', recTypeIdList, 'GCM_Application_Administrator');    }
        return null;
    }

/****************************************************************************************************
  Associate existing case to task on 'Link Interaction' button click on case detail page.
 ****************************************************************************************************/    
    public void associateExistingCasetoTask(){
        List<Task> updateTaskList = new List<Task>();
        List<Task> taskList = new List<Task>();
        List<Case> updateExistingCaseList = new List<Case>();
        List<Id> taskIdList = new List<Id>();
        try{
            if(interactionId != null && interactionId != '')
            taskList = [Select Id, softphone_it__IWS_Interaction_ID__c, WhatId, status, GCM_Interaction_Mark_Done__c from Task Where softphone_it__IWS_Interaction_ID__c =: interactionId and status != 'Completed' and GCM_Interaction_Mark_Done__c = false];
            List<Case> caseList = [Select Id, CaseNumber, GCM_Case_Number__c, AccountId, ContactId, GCM_Parent_Interaction_Id__c from Case WHERE Id =: apexpages.currentpage().getparameters().get('id')];
            if(!taskList.isEmpty()){
                for(Task tsk : taskList){
                    if(tsk.WhatId != apexpages.currentpage().getparameters().get('id')){
                        tsk.WhatId = apexpages.currentpage().getparameters().get('id');
                        taskIdList.add(tsk.Id);
                        updateTaskList.add(tsk);
                        if(!caseList.isEmpty()){
                            //Update Case Parent Interaction Id with the latest interaction.
                            caseList.get(0).GCM_Parent_Interaction_Id__c = tsk.softphone_it__IWS_Interaction_ID__c;
                            caseList.get(0).GCM_ByPassValidation_Timestamp__c = system.now();
                            updateExistingCaseList.add(caseList.get(0));
                        }
                    }
                }
            }
            
            if(!updateTaskList.isEmpty()){
                update updateTaskList;
            }
            if(!updateExistingCaseList.isEmpty()){
                update updateExistingCaseList;
            }
        }catch(Exception e){    BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'associateExistingCasetoTask', taskIdList, 'GCM_Application_Administrator');   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));}
    }
    
/****************************************************************************************************
  Check if its current user.
 ****************************************************************************************************/    
    @RemoteAction
    global static boolean checkCurrentUser(String ntid){
        Boolean isCurrentUser = false;
        if(String.isNotBlank(ntid)){
            try{
                List<User> userList = [Select Id, NTID__c from User Where NTID__c =: ntid];
                if(!userList.isEmpty()){
                    for(User u : userList){
                        if(u.Id == UserInfo.getUserId()) isCurrentUser = true;
                    }
                }
            }catch(Exception e){    BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'checkCurrentUser', (List<Id>)null, 'GCM_Application_Administrator');  }
       
        }
        return isCurrentUser;
    }

/****************************************************************************************************
  Fetch the case record with Id. Referenced in CTIScripUtil to get case details and update the interaction in Genesys
 ****************************************************************************************************/    
    @RemoteAction
    global static Case getCaseDetails(String caseId) {
        List<Id> caseIdList = new List<Id>();
        try{
            List<Case> caseRecList = [Select Id, CaseNumber, Type, Area__c, Priority, Sub_Area__c, Sub_Status__c , Subject, Description, Status, ContactId, ContactEmail from Case where Id =: Id.valueOf(caseId)];
            if(!caseRecList.isEmpty()){
                caseIdList.add(caseRecList[0].Id);
                return caseRecList[0];
            }
        }catch(Exception e){  BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'getCaseDetails', caseIdList, 'GCM_Application_Administrator'); }
        return null;
    }
    
/****************************************************************************************************
  Method to update EndDate and MarkDone flag on task.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task updateTaskDetail(String taskId, String field, String taskTyp) {
         List<Id> taskIdList = new List<Id>();
         if(String.isNotBlank(taskId)){
         try{          
             List<Task> taskList = [Select Id, OwnerId from Task Where Id =: Id.valueof(taskId)];
             Task tas = new Task();
             tas.Id = Id.valueof(taskId);
             if(field == 'EndDate'){
                 tas.GCM_Call_End_Date__c = system.now();
                 tas.GCM_ByPassValidation_Timestamp__c = system.now();
             }
             if(field == 'MarkDone'){
                 tas.GCM_Interaction_Mark_Done__c = true;
                 tas.GCM_ByPassValidation_Timestamp__c = system.now().addHours(1);
             }
             if(field == 'EmailReleased'){
                 tas.GCM_Call_End_Date__c = system.now();
                 tas.GCM_Interaction_Mark_Done__c = true;
                 tas.GCM_ByPassValidation_Timestamp__c = system.now();
                 tas.Status = 'Completed';
             }
            taskIdList.add(tas.Id);
            if(taskTyp != '' && taskTyp != null) tas.Type = taskTyp;
             if(!taskList.isEmpty() && taskList[0].OwnerId == UserInfo.getUserId()){
                 Database.SaveResult sr =  Database.update(tas);
                 return tas;
             }
         }catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'updateTaskDetail'+field, taskIdList, 'GCM_Application_Administrator');    }
         }return null;
    }

/****************************************************************************************************
  Update task owner when the interaction is transferred.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task updateTaskOwner(String taskId) {
         List<Id> taskIdList = new List<Id>();
         try{
             List<GCM_Update_Record.ResponseWrapper> reswp = new List<GCM_Update_Record.ResponseWrapper>();
             Id recordId = Id.valueof(taskId);
             taskIdList.add(recordId);
             Map<Id,Map<String, String>> recsToBeUpdated = new Map<Id,Map<String, String>>();
             List<Task> taskList = [Select Id, OwnerId, Type, WhatId from Task Where Id =: recordId];
             if(!taskList.isEmpty()){
                for(Task tsk : taskList){
                    if(tsk.OwnerId != UserInfo.getUserId()){
                        Map<String, String> fieldMap = new Map<String, String>();
                        fieldMap.put('GCM_ByPassValidation_Timestamp__c', String.valueof(system.now()));
                        fieldMap.put('ownerId', String.valueof(UserInfo.getUserId()));
                        recsToBeUpdated.put(tsk.Id, fieldMap);
                        if(tsk.Type.startswith('Email') && tsk.WhatId != null && String.valueof(tsk.WhatId).startswith('500')){
                            recsToBeUpdated.put(tsk.WhatId, fieldMap);
                        }
                    }
                }
                if(!recsToBeUpdated.isEmpty()){
                    reswp = GCM_Update_Record.updateRecords(recsToBeUpdated, false);
                }
                return taskList[0];
             }
        } catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'updateTaskOwner', taskIdList, 'GCM_Application_Administrator');   }
        return null;
    }
    
/****************************************************************************************************
  Create task for outbound call interaction.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task createTaskforOutboundCall(Task task, String value, string contactRecId) {
        List<Id> taskIdList = new List<Id>();
        try{        
            List<Contact> contactList = new List<Contact>();
            List<Case> caseList = new List<Case>();
            If(contactRecId != null && contactRecId != '' && contactRecId.startsWith('500')){
                caseList = Database.query('Select Id, AccountId, ContactId from Case where Id = \'' + Id.valueof(contactRecId) + '\'');
            }else If(contactRecId != null && contactRecId != ''){
                contactList = Database.query('Select id,AccountId,Email,FirstName,LastName,Phone,MobilePhone,HomePhone,OtherPhone,AssistantPhone from Contact where Id = \'' + Id.valueof(contactRecId) + '\'');
            } else {
                contactList = Database.query('Select id,AccountId,Email,FirstName,LastName,Phone,MobilePhone,HomePhone,OtherPhone,AssistantPhone from Contact where phone = \'' + value + '\' or AssistantPhone = \''+ value + '\' or HomePhone = \''+ value + '\' or OtherPhone = \''+ value + '\' or MobilePhone = \''+ value + '\'');
            }
            
            //When Contact Id is received
            if ( !contactList.isEmpty() && contactList.size() == 1 ){
                task.WhoId = contactList.get(0).Id;
                if(contactList.get(0).AccountId != null ){
                    task.GCM_Account__c = contactList.get(0).AccountId;
                    task.WhatId = contactList.get(0).AccountId;
                } 
            }
            
            //When Case Id is received
            if (!caseList.isEmpty() && caseList.size() == 1){
                task.WhatId = caseList.get(0).Id;
                if(caseList.get(0).AccountId != null ) task.GCM_Account__c = caseList.get(0).AccountId;
                if(caseList.get(0).ContactId != null ) task.WhoId = caseList.get(0).ContactId;    
            }
            
            //Get GCM Task RecordType
            Id recTypeId = getRecordTypeId('GCM_Task', 'Task');
            if(recTypeId != null){
                task.RecordTypeId = recTypeId;
            }
            
            task.GCM_Call_Start_Date__c = system.now();
            task.Status = 'In Progress';
            task.Type = 'Call-Outbound';
            taskIdList.add(task.Id);
        } catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'createTaskforOutboundCall', taskIdList, 'GCM_Application_Administrator'); }
        
        try{           
            Database.SaveResult sr =  Database.insert(task);   
            return task;
        } catch(Exception e){   BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'createTaskforOutboundCallInsert', taskIdList, 'GCM_Application_Administrator');   }
        return null;
    }

/****************************************************************************************************
  Create task for inbound call interactions.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task createTaskforInboundCall(Task task, String value, String accId, String conId, String matchType, String defAccId, String defConId) {
        List<Id> taskIdList = new List<Id>();
        try{    
            Id matchedAccountorDefId = (accId instanceOf Id) ? (Id)accId : (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id matchedContactorDefId = (conId instanceOf Id) ? (Id)conId : (defConId instanceOf Id) ? (Id)defConId : null;
            Id defaultAccountId = (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id defaultContactId = (defConId instanceOf Id) ? (Id)defConId : null;
            
            if(String.isNotBlank(matchType)){
                if(matchType == 'Single'){
                    task.GCM_Account__c = matchedAccountorDefId;
                    task.WhatId = matchedAccountorDefId;
                    task.WhoId = matchedContactorDefId; 
                } else if(matchType == 'ContactMultiAccount'){
                    Id matchedContactId = (conId instanceOf Id) ? (Id)conId : null;
                    If(matchedContactId != null){
                        task.WhoId = matchedContactId;
                        List<Contact> conList = [Select Id, AccountId from Contact Where Id =: matchedContactId];
                        if(!conList.isEmpty() && conList.size() == 1){
                            task.GCM_Account__c = conList.get(0).AccountId;
                            task.WhatId = conList.get(0).AccountId;
                        }
                    } else {
                        task.GCM_Account__c = defaultAccountId;
                        task.WhatId = defaultAccountId;
                        task.WhoId = matchedContactorDefId;
                    }
                }else if(matchType == 'AccountMultiContact' || matchType == 'SingleAccount'){
                        task.GCM_Account__c = matchedAccountorDefId;
                        task.WhatId = matchedAccountorDefId; 
                        task.WhoId = defaultContactId; 
                }else{
                    task.GCM_Account__c = defaultAccountId;
                    task.WhatId = defaultAccountId;
                    task.WhoId = defaultContactId;
                }
            }
            
            //task.GCM_Default_Account__c = defaultAccountId;
            //task.GCM_Default_Contact__c = defaultContactId;
            
            //Get GCM Task RecordType
            Id recTypeId = getRecordTypeId('GCM_Task', 'Task');
            if(recTypeId != null){
                task.RecordTypeId = recTypeId;
            }
            
            task.GCM_Call_Start_Date__c = system.now();
            task.Status = 'In Progress';
            taskIdList.add(task.Id);
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskforInboundCall', taskIdList, 'GCM_Application_Administrator');  }
        finally{
            try{  
                task.Type = 'Call-Inbound';
                Database.SaveResult sr =  Database.insert(task); 
                return task;
            } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskforInboundCallInsert', taskIdList, 'GCM_Application_Administrator');    }
        }
            return null;
    }
    
/****************************************************************************************************
  Create Task, EmailMessage and Case (For CreateSR = Y) for inbound email interactions.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task createTaskforInboundEmail(Task task, String accId, String conId, String matchType, String defAccId, String defConId, String startDate, String subject, String messageText, String createSR, Case cas, String commMethod, String caseNum, String hasAttachment, String ccAddresses, String recType) {
        List<Id> taskIdList = new List<Id>();
        List<Case> updateCaseList = new List<Case>();
        EmailMessage emailMsg;
        List<Case> casRec = new List<Case>();
        List<Task> existingTaskList = [SELECT Id, softphone_it__IWS_Interaction_ID__c FROM Task WHERE softphone_it__IWS_Interaction_ID__c =: task.softphone_it__IWS_Interaction_ID__c and RecordType.DeveloperName =: 'GCM_Task'];
        if(!existingTaskList.isEmpty()){
            return null;
        }
        try{    
            //Recognition
            Id matchedAccountorDefId = (accId instanceOf Id) ? (Id)accId : (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id matchedContactorDefId = (conId instanceOf Id) ? (Id)conId : (defConId instanceOf Id) ? (Id)defConId : null;
            Id defaultAccountId = (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id defaultContactId = (defConId instanceOf Id) ? (Id)defConId : null;
            
            if(matchType != null){
                if(matchType == 'Single'){
                    task.GCM_Account__c = matchedAccountorDefId;
                    task.WhatId = matchedAccountorDefId;
                    task.WhoId = matchedContactorDefId;
                } else if(matchType == 'ContactMultiAccount'){
                    Id matchedContactId = (conId instanceOf Id) ? (Id)conId : null;
                    If(matchedContactId != null){
                        task.WhoId = matchedContactId;
                        List<Contact> conList = [Select Id, AccountId from Contact Where Id =: matchedContactId];
                        if(!conList.isEmpty() && conList.size() == 1){
                            task.GCM_Account__c = conList.get(0).AccountId;
                            task.WhatId = conList.get(0).AccountId;
                        }
                    } else {
                        task.GCM_Account__c = defaultAccountId;
                        task.WhatId = defaultAccountId;
                        task.WhoId = matchedContactorDefId;
                    }
                }else if(matchType == 'MultiContact'){
                    //Check if it is Single or Multi Account
                    If(conId != null && conId != ''){
                        List<String> conIdList = conId.split('\\|');
                        set<Contact> contactSet = new set<Contact>([select id, Name, AccountId from Contact Where Id IN: conIdList]);
                        set<Id> accIdSet = new set<Id>();
                        for (Contact cons : contactSet) {
                            accIdSet.add(cons.AccountId);
                        }
                        //Single Account
                        if(accIdSet.size() == 1) {
                            task.GCM_Account__c = (new List<Id>(accIdSet))[0];
                            task.WhatId = (new List<Id>(accIdSet))[0];
                        } 
                        //Multi Account
                        else {
                            task.GCM_Account__c = defaultAccountId;
                            task.WhatId = defaultAccountId;
                        } 
                    }
                    task.WhoId = defaultContactId;
                }else{
                    task.GCM_Account__c = defaultAccountId;
                    task.WhatId = defaultAccountId;
                    task.WhoId = defaultContactId;
                }
            }
            //task.GCM_Default_Account__c = defaultAccountId;
            //task.GCM_Default_Contact__c = defaultContactId;
            
            //Get GCM Task RecordType
            Id recTypeId = getRecordTypeId('GCM_Task', 'Task');
            if(recTypeId != null){
                task.RecordTypeId = recTypeId;
            }
            
            task.GCM_Call_Start_Date__c = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
            task.Status = 'In Progress';
            taskIdList.add(task.Id);
            
            //Create EmailMessage Record
            emailMsg = new EmailMessage();
            emailMsg.Subject = task.Subject;
            emailMsg.TextBody = messageText;
            if (task.Description.length() > 131072) {
                emailMsg.HTMLBody = task.Description.substring(0, 131072);
            } else {
                emailMsg.HTMLBody = task.Description;
            }
            emailMsg.FromAddress = task.GCM_Call_From__c;
            emailMsg.ToAddress = task.GCM_Call_To__c;
            emailMsg.CcAddress = ccAddresses;
            emailMsg.Status = '1';
            emailMsg.Incoming = true;
            if(hasAttachment == 'true'){
                emailMsg.GCM_Has_Attachment__c = true;
            } else {
                emailMsg.GCM_Has_Attachment__c = false;
            } 
            emailMsg.MessageDate = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
            if(commMethod == 'Email'){
                task.Type = 'Email-Inbound';
            } else if(commMethod == 'Fax'){
                task.Type = 'Fax-Inbound';
            }
            task.Description = messageText;
            
            //Create Case Record when createSR = 'Y'
            if(createSR == 'Y' && cas != null){
                cas.AccountId = task.GCM_Account__c;
                cas.ContactId = task.WhoId;
                cas.Subject = Subject;
                cas.Origin = task.softphone_it__IWS_Media_Name__c;
                cas.GCM_Parent_Interaction_Id__c = task.softphone_it__IWS_Interaction_ID__c;
                cas.Description = task.Description;
                cas.GCM_ByPassValidation_Timestamp__c = system.now();
                cas.GCM_Received_Date__c = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
                if(String.isNotBlank(recType)){
                    Id caseRecTypeId = getRecordTypeId(recType, 'Case');
                    if(caseRecTypeId != null){
                        cas.RecordTypeId = caseRecTypeId;
                    }
                }
            }
            if(String.isNotBlank(caseNum)){
                casRec = [Select Id, CaseNumber, GCM_Parent_Interaction_Id__c, Status from Case Where CaseNumber =: caseNum];
                if(!casRec.isEmpty()){
                    if(casRec[0].Status != 'Closed' && casRec[0].Status != 'Cancelled'){
                        casRec[0].GCM_Parent_Interaction_Id__c = task.softphone_it__IWS_Interaction_ID__c;
                        casRec[0].GCM_ByPassValidation_Timestamp__c = system.now();
                        updateCaseList.add(casRec[0]);
                    }
                }
            }
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString()); BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+commMethod+'|'+startDate+'|'+caseNum+'|'+recType+'|'+createSR+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskEmailMessgaeforInboundEmail', taskIdList, 'GCM_Application_Administrator'); }
        
        try{           
            Id casId = null;
            if(cas != null){
                Database.SaveResult srCase =  Database.insert(cas);
                if(srCase.isSuccess()) {
                    task.WhatId = casId = srCase.getId();
                    system.debug('case Id'+casId);
                }
            }
            if(!casRec.isEmpty()) task.WhatId = casId = casRec[0].Id;
 
            Database.SaveResult sr =  Database.insert(task); 
            if(sr.isSuccess()) {
               // if(commMethod == 'Email'){
                    if(casId != null && emailMsg != null){
                        emailMsg.ParentId = casId;
                        emailMsg.RelatedToId = casId;
                        emailMsg.ActivityId = sr.getId();
                    }
                    Database.SaveResult srEmail =  Database.insert(emailMsg);
                    if(srEmail.isSuccess()){
                        task.GCM_Email_Message_Id__c = srEmail.getId();
                        Database.SaveResult srTaskUpdate =  Database.update(task);
                    }
                //} 
                if(!updateCaseList.isEmpty()) { update updateCaseList; }
                return task;
            }   
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+commMethod+'|'+startDate+'|'+caseNum+'|'+recType+'|'+createSR+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskEmailMessgaeforInboundEmailInsert', taskIdList, 'GCM_Application_Administrator');  system.debug('error message '+e.getMessage()); }
        return null;
    }
    
/****************************************************************************************************
  Create Task and EmailMessage for outbound email interactions.
 ****************************************************************************************************/    
    @RemoteAction
    global static Task createTaskforOutboundEmail(Task task, String accId, String conId, String matchType, String defAccId, String defConId, String startDate, String subject, String messageText, String createSR, Case cas, String commMethod, String caseNum, String interactionSubType, String bccAddress, String hasAttachment, String ccAddresses) {
        List<Id> taskIdList = new List<Id>();
        List<Case> updateCaseList = new List<Case>();
        EmailMessage emailMsg;
        List<Case> casRec = new List<Case>();
        List<Task> existingTaskList = [SELECT Id, softphone_it__IWS_Interaction_ID__c FROM Task WHERE softphone_it__IWS_Interaction_ID__c =: task.softphone_it__IWS_Interaction_ID__c and RecordType.DeveloperName =: 'GCM_Task'];
        if(!existingTaskList.isEmpty()){
            return null;
        }
        try{    
            //Recognition
            Id matchedAccountorDefId = (accId instanceOf Id) ? (Id)accId : (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id matchedContactorDefId = (conId instanceOf Id) ? (Id)conId : (defConId instanceOf Id) ? (Id)defConId : null;
            Id defaultAccountId = (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id defaultContactId = (defConId instanceOf Id) ? (Id)defConId : null;
            if(matchType != null){
                if(matchType == 'Single'){
                    task.GCM_Account__c = matchedAccountorDefId;
                    task.WhatId = matchedAccountorDefId;
                    task.WhoId = matchedContactorDefId;
                } else if(matchType == 'ContactMultiAccount'){
                    Id matchedContactId = (conId instanceOf Id) ? (Id)conId : null;
                    If(matchedContactId != null){
                        task.WhoId = matchedContactId;
                        List<Contact> conList = [Select Id, AccountId from Contact Where Id =: matchedContactId];
                        if(!conList.isEmpty() && conList.size() == 1){
                            task.GCM_Account__c = conList.get(0).AccountId;
                            task.WhatId = conList.get(0).AccountId;
                        }
                    }else {
                        task.GCM_Account__c = defaultAccountId;
                        task.WhatId = defaultAccountId;
                        task.WhoId = matchedContactorDefId;
                    } 
                }else if(matchType == 'MultiContact'){
                    //Check if it is Single or Multi Account
                    If(conId != null && conId != ''){
                        List<String> conIdList = conId.split('\\|');
                        set<Contact> contactSet = new set<Contact>([select id, Name, AccountId from Contact Where Id IN: conIdList]);
                        set<Id> accIdSet = new set<Id>();
                        for (Contact cons : contactSet) {
                            accIdSet.add(cons.AccountId);
                        }
                        //Single Account
                        if(accIdSet.size() == 1) {
                            task.GCM_Account__c = (new List<Id>(accIdSet))[0];
                            task.WhatId = (new List<Id>(accIdSet))[0];
                        } 
                        //Multi Account
                        else {
                            task.GCM_Account__c = defaultAccountId;
                            task.WhatId = defaultAccountId;
                        }  
                    }
                    task.WhoId = defaultContactId;
                }else{
                    task.GCM_Account__c = defaultAccountId;
                    task.WhatId = defaultAccountId;
                    task.WhoId = defaultContactId;
                }
            } else {
                    task.GCM_Account__c = matchedAccountorDefId;
                    task.WhatId = matchedAccountorDefId;
                    task.WhoId = matchedContactorDefId;
            }
            //task.GCM_Default_Account__c = defaultAccountId;
            //task.GCM_Default_Contact__c = defaultContactId;
            
            //Get GCM Task RecordType
            Id recTypeId = getRecordTypeId('GCM_Task', 'Task');
            if(recTypeId != null){
                task.RecordTypeId = recTypeId;
            }
            
            task.GCM_Call_Start_Date__c = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
            task.Status = 'Completed';
            task.GCM_Interaction_Mark_Done__c = true;
            task.GCM_Call_End_Date__c = system.now();
            taskIdList.add(task.Id);
            
            //Create EmailMessage Record
            if(commMethod != null || (commMethod == null && interactionSubType == 'OutboundNew')){
                emailMsg = new EmailMessage();
                emailMsg.Subject = task.Subject;
                emailMsg.TextBody = messageText;
                if (task.Description.length() > 131072) {
                    emailMsg.HTMLBody = task.Description.substring(0, 131072);
                } else {
                    emailMsg.HTMLBody = task.Description;
                }
                emailMsg.FromAddress = task.GCM_Call_From__c;
                emailMsg.ToAddress = task.GCM_Call_To__c;
                emailMsg.CcAddress = ccAddresses;
                emailMsg.BccAddress = bccAddress;
                emailMsg.Status = '1';
                if(hasAttachment == 'true'){
                    emailMsg.GCM_Has_Attachment__c = true;
                } else {
                    emailMsg.GCM_Has_Attachment__c = false;
                } 
                emailMsg.MessageDate = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
                task.Type = 'Email-Outbound';
                if(commMethod == 'Fax'){
                    task.Type = 'Fax-Outbound';
                }
            } 
            task.Description = messageText;
            if(String.isNotBlank(caseNum)){
                casRec = [Select Id, GCM_Parent_Interaction_Id__c, Status, CaseNumber from Case Where CaseNumber =: caseNum];
                if(!casRec.isEmpty()){
                    if(casRec[0].Status != 'Closed' && casRec[0].Status != 'Cancelled'){
                        casRec[0].GCM_Parent_Interaction_Id__c = task.softphone_it__IWS_Interaction_ID__c;
                        casRec[0].GCM_ByPassValidation_Timestamp__c = system.now();
                        updateCaseList.add(casRec[0]);
                    }
                }
            }
            
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+commMethod+'|'+startDate+'|'+caseNum+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskEmailMessgaeforOutboundEmail', taskIdList, 'GCM_Application_Administrator');    }
        
        try{           
            Id casId = null;
            if(!casRec.isEmpty()) task.WhatId = casId = casRec[0].Id;
 
            Database.SaveResult sr =  Database.insert(task); 
            if(sr.isSuccess()) {
                if(commMethod != null || emailMsg != null){
                    if(casId != null && emailMsg != null){
                        emailMsg.ParentId = casId;
                        emailMsg.RelatedToId = casId;
                        emailMsg.ActivityId = sr.getId();
                    }
                    Database.SaveResult srEmail =  Database.insert(emailMsg);
                    if(srEmail.isSuccess()){
                        task.GCM_Email_Message_Id__c = srEmail.getId();
                        task.GCM_ByPassValidation_Timestamp__c = system.now().addHours(1);
                        Database.SaveResult srTaskUpdate =  Database.update(task);
                    }
                } 
                if(!updateCaseList.isEmpty()) { update updateCaseList; }
                return task;
            }   
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+commMethod+'|'+startDate+'|'+caseNum+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskEmailMessgaeforOutboundEmailInsert', taskIdList, 'GCM_Application_Administrator');  }
        return null;
    }
    
/*************************************************************************************************************************************
  Checks if the Interaction is already associated to a case. If Associated do not send it to WDE and do not override the case on Task.
 *************************************************************************************************************************************/    
    public static void checkInteractionCase(){
        List<Task> tasList = [Select Id, softphone_it__IWS_Interaction_ID__c, WhatId, softphone_it__IWS_Media_Name__c from Task WHERE softphone_it__IWS_Interaction_ID__c =: interactionId and GCM_Interaction_Mark_Done__c = false];
        if(!tasList.isEmpty()){
            if(tasList[0].WhatId != null && String.valueof(tasList[0].WhatId).StartsWith('500') && tasList[0].WhatId != apexpages.currentpage().getparameters().get('id')){
                List<Case> casRecList = [Select Id, CaseNumber, GCM_Case_Number__c, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email, GCM_Parent_Interaction_Id__c, Type, Area__c, Sub_Area__c, Priority, Status, Sub_Status__c, Owner.Name, isClosed From Case Where Id =: tasList[0].WhatId and IsClosed =: false];
                system.debug('checkInteractionCase casRecList'+ casRecList);
                if(!casRecList.isEmpty()){
                caseRec = casRecList[0];
                caseNum = casRecList[0].CaseNumber;
                accName = casRecList[0].AccountId != null? casRecList[0].Account.Name : null;
                conName = casRecList[0].ContactId != null? casRecList[0].Contact.Name : null;
                if(casRecList[0].GCM_Parent_Interaction_Id__c == tasList[0].softphone_it__IWS_Interaction_ID__c && tasList[0].softphone_it__IWS_Media_Name__c == 'email' && casRecList[0].isClosed == false){
                    caseAssociated = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'A case is already associated to this interaction'));
                }
                }else {
                    List<Case> newCasRecList = [Select Id, CaseNumber, GCM_Case_Number__c, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email, GCM_Parent_Interaction_Id__c, Type, Area__c, Sub_Area__c, Priority, Status, Sub_Status__c, Owner.Name From Case Where Id =: apexpages.currentpage().getparameters().get('id')];
                    if(!newCasRecList.isEmpty()){
                        caseRec = newCasRecList[0];
                        caseNum = newCasRecList[0].CaseNumber;
                        accName = newCasRecList[0].AccountId != null? newCasRecList[0].Account.Name : null;
                        conName = newCasRecList[0].ContactId != null? newCasRecList[0].Contact.Name : null;
                    }
                }
            }else {
                List<Case> casRecList = [Select Id, CaseNumber, GCM_Case_Number__c, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email, GCM_Parent_Interaction_Id__c, Type, Area__c, Sub_Area__c, Priority, Status, Sub_Status__c, Owner.Name From Case Where Id =: apexpages.currentpage().getparameters().get('id')];
                caseRec = casRecList[0];
                caseNum = casRecList[0].CaseNumber;
                accName = casRecList[0].AccountId != null? casRecList[0].Account.Name : null;
                conName = casRecList[0].ContactId != null? casRecList[0].Contact.Name : null;
            }
        }
    }

/****************************************************************************************************
  Create Task and EmailMessage for new inbound email interactions with Case #
 ****************************************************************************************************/    
    @RemoteAction
    global static Task createTaskforNewInboundEmailwithCaseNo(Task task, String accId, String conId, String matchType, String defAccId, String defConId, String startDate, String subject, String messageText, String createSR, Case cas, String commMethod, String caseNum, String hasAttachment, String ccAddresses, String recType) {
        List<Id> taskIdList = new List<Id>();
        List<Case> updateCaseList = new List<Case>();
        EmailMessage emailMsg;
        Case childCase;
        Id caseId;
        List<Task> existingTaskList = [SELECT Id, softphone_it__IWS_Interaction_ID__c FROM Task WHERE softphone_it__IWS_Interaction_ID__c =: task.softphone_it__IWS_Interaction_ID__c and RecordType.DeveloperName =: 'GCM_Task'];
        if(!existingTaskList.isEmpty()){
            return null;
        }
        try{    
            //Recognition
            Id matchedAccountorDefId = (accId instanceOf Id) ? (Id)accId : (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id matchedContactorDefId = (conId instanceOf Id) ? (Id)conId : (defConId instanceOf Id) ? (Id)defConId : null;
            Id defaultAccountId = (defAccId instanceOf Id) ? (Id)defAccId : null;
            Id defaultContactId = (defConId instanceOf Id) ? (Id)defConId : null;
            
            if(matchType != null){
                if(matchType == 'Single'){
                    task.GCM_Account__c = matchedAccountorDefId;
                    task.WhatId = matchedAccountorDefId;
                    task.WhoId = matchedContactorDefId;
                } else if(matchType == 'ContactMultiAccount'){
                    Id matchedContactId = (conId instanceOf Id) ? (Id)conId : null;
                    If(matchedContactId != null){
                        task.WhoId = matchedContactId;
                        List<Contact> conList = [Select Id, AccountId from Contact Where Id =: matchedContactId];
                        if(!conList.isEmpty() && conList.size() == 1){
                            task.GCM_Account__c = conList.get(0).AccountId;
                            task.WhatId = conList.get(0).AccountId;
                        }
                    } else {
                        task.GCM_Account__c = defaultAccountId;
                        task.WhatId = defaultAccountId;
                        task.WhoId = matchedContactorDefId;
                    }
                }else if(matchType == 'MultiContact'){
                    //Check if it is Single or Multi Account
                    If(conId != null && conId != ''){
                        List<String> conIdList = conId.split('\\|');
                        set<Contact> contactSet = new set<Contact>([select id, Name, AccountId from Contact Where Id IN: conIdList]);
                        set<Id> accIdSet = new set<Id>();
                        for (Contact cons : contactSet) {
                            accIdSet.add(cons.AccountId);
                        }
                        //Single Account
                        if(accIdSet.size() == 1) {
                            task.GCM_Account__c = (new List<Id>(accIdSet))[0];
                            task.WhatId = (new List<Id>(accIdSet))[0];
                        } 
                        //Multi Account
                        else {
                            task.GCM_Account__c = defaultAccountId;
                            task.WhatId = defaultAccountId;
                        }
                    }
                    task.WhoId = defaultContactId;
                }else{
                    task.GCM_Account__c = defaultAccountId;
                    task.WhatId = defaultAccountId;
                    task.WhoId = defaultContactId;
                }
            }
            //task.GCM_Default_Account__c = defaultAccountId;
            //task.GCM_Default_Contact__c = defaultContactId;
            
            //Get GCM Task RecordType
            Id recTypeId = getRecordTypeId('GCM_Task', 'Task');
            if(recTypeId != null){
                task.RecordTypeId = recTypeId;
            }
            
            task.GCM_Call_Start_Date__c = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
            task.Status = 'In Progress';
            taskIdList.add(task.Id);
            
            //Create EmailMessage Record
            if(commMethod == 'Email'){
                emailMsg = new EmailMessage();
                emailMsg.Subject = task.Subject;
                emailMsg.TextBody = messageText;
                if (task.Description.length() > 131072) {
                    emailMsg.HTMLBody = task.Description.substring(0, 131072);
                } else {
                    emailMsg.HTMLBody = task.Description;
                }
                emailMsg.FromAddress = task.GCM_Call_From__c;
                emailMsg.ToAddress = task.GCM_Call_To__c;
                emailMsg.CcAddress = ccAddresses;
                emailMsg.Status = '1';
                emailMsg.Incoming = true;
                if(hasAttachment == 'true'){
                    emailMsg.GCM_Has_Attachment__c = true;
                } else {
                    emailMsg.GCM_Has_Attachment__c = false;
                } 
                emailMsg.MessageDate = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
                task.Type = 'Email-Inbound';
            }
            task.Description = messageText;
            List<Case> casRec = [Select Id, GCM_Case_Number__c, CaseNumber, GCM_Parent_Interaction_Id__c, Status from Case Where CaseNumber =: caseNum LIMIT 1];
            
            if(!casRec.isEmpty()){
                //Create Case Record when createSR = 'Y' and case is closed/cancelled
                if(createSR == 'Y' && casRec[0].Status != 'Open' && casRec[0].Status != 'In Progress' && cas != null){
                    cas.AccountId = task.GCM_Account__c;
                    cas.ContactId = task.WhoId;
                    cas.Subject = Subject;
                    cas.Origin = task.softphone_it__IWS_Media_Name__c;
                    cas.GCM_Parent_Interaction_Id__c = task.softphone_it__IWS_Interaction_ID__c;
                    cas.Description = task.Description;
                    cas.GCM_ByPassValidation_Timestamp__c = system.now();
                    cas.GCM_Received_Date__c = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
                    cas.ParentId = casRec[0].Id;
                    if(String.isNotBlank(recType)){
                        Id caseRecTypeId = getRecordTypeId(recType, 'Case');
                        if(caseRecTypeId != null){
                            cas.RecordTypeId = caseRecTypeId;
                        }
                    }
                    childCase = cas;
                }else if(createSR == 'Y' || (createSR == 'N' && (casRec[0].Status == 'Open' || casRec[0].Status == 'In Progress'))){
                    caseId = casRec[0].Id;
                    casRec[0].GCM_Parent_Interaction_Id__c = task.softphone_it__IWS_Interaction_ID__c;
                    casRec[0].GCM_ByPassValidation_Timestamp__c = system.now();
                    updateCaseList.add(casRec[0]);
                }
            }else if(createSR == 'Y'){
                    cas.AccountId = task.GCM_Account__c;
                    cas.ContactId = task.WhoId;
                    cas.Subject = Subject;
                    cas.Origin = task.softphone_it__IWS_Media_Name__c;
                    cas.GCM_Parent_Interaction_Id__c = task.softphone_it__IWS_Interaction_ID__c;
                    cas.Description = task.Description;
                    cas.GCM_ByPassValidation_Timestamp__c = system.now();
                    cas.GCM_Received_Date__c = (DateTime)Json.deserialize('"'+startDate+'"', DateTime.class);
                    if(String.isNotBlank(recType)){
                        Id caseRecTypeId = getRecordTypeId(recType, 'Case');
                        if(caseRecTypeId != null){
                            cas.RecordTypeId = caseRecTypeId;
                        }
                    }
                    childCase = cas;
            }
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+commMethod+'|'+startDate+'|'+caseNum+'|'+recType+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskforNewInboundEmailwithCase', taskIdList, 'GCM_Application_Administrator');  }
        
        try{           
            Id casId = null;
            if(childCase != null){
                Database.SaveResult srCase =  Database.insert(childCase);
                if(srCase.isSuccess()) {
                    task.WhatId = casId = srCase.getId();
                }
            }
            if(caseId != null){
                task.WhatId = casId = Id.valueof(caseId);
            }
 
            Database.SaveResult sr =  Database.insert(task);
            if(sr.isSuccess()) {
                if(!updateCaseList.isEmpty()) { update updateCaseList; }
                if(commMethod == 'Email'){
                    if(casId != null && emailMsg != null){
                        emailMsg.ParentId = casId;
                        emailMsg.RelatedToId = casId;
                        emailMsg.ActivityId = sr.getId();
                    }
                    Database.SaveResult srEmail =  Database.insert(emailMsg);
                    if(srEmail.isSuccess()){
                        task.GCM_Email_Message_Id__c = srEmail.getId();
                        Database.SaveResult srTaskUpdate =  Database.update(task);
                    }
                } 
                return task;
            }   
        } catch(Exception e){ System.debug('Exception***'+e.getStackTraceString());  BPG_Error_Logger errorLogger = new BPG_Error_Logger(new CTIControllerException(task.softphone_it__IWS_Interaction_ID__c+'|'+matchType+'|'+task.GCM_Call_From__c+'|'+task.GCM_Call_To__c+'|'+accId+'|'+conId+'|'+commMethod+'|'+startDate+'|'+caseNum+'|'+recType+'|'+e.getMessage(),e), 'Class', 'GCM_CTIController', 'createTaskforNewInboundEmailwithCaseInsert', taskIdList, 'GCM_Application_Administrator');    }
        return null;
    }
    
/**************************************************************************************************************************************************
  Associate existing case details (Account and Contact names) to task on 'Link Interaction' button click on case detail page for Email Interactions
 ***************************************************************************************************************************************************/    
    public void associateExistingCaseDetailstoTask(){
        List<Task> updateTaskList = new List<Task>();
        List<EmailMessage> insertEmailList = new List<EmailMessage>();
        List<EmailMessage> deleteEmailList = new List<EmailMessage>();
        List<Task> taskList = new List<Task>();
        List<Id> taskIdList = new List<Id>();
        List<Id> delEmailIdList = new List<Id>();
        List<Case> updateExistingCaseList = new List<Case>();
        try{
        if(interactionId != null && interactionId != '')
        taskList = [Select Id, WhoId, GCM_Account__c, softphone_it__IWS_Interaction_ID__c, WhatId, status, GCM_Interaction_Mark_Done__c, GCM_Email_Message_Id__c, GCM_Call_Start_Date__c from Task Where softphone_it__IWS_Interaction_ID__c =: interactionId and GCM_Interaction_Mark_Done__c = false];
        List<Case> caseList = [Select Id, CaseNumber, GCM_Case_Number__c, AccountId, ContactId, GCM_Parent_Interaction_Id__c from Case WHERE Id =: apexpages.currentpage().getparameters().get('id')];   
        if(!taskList.isEmpty()){
            for(Task tsk : taskList){
                if(tsk.WhatId == apexpages.currentpage().getparameters().get('id') && !caseList.isEmpty()){
                    if( tsk.GCM_Account__c != caseList.get(0).AccountId &&  tsk.WhoId != caseList.get(0).ContactId){
                        tsk.GCM_Account__c = caseList.get(0).AccountId;
                        tsk.WhoId = caseList.get(0).ContactId;
                        tsk.GCM_ByPassValidation_Timestamp__c = system.now();
                        taskIdList.add(tsk.Id);
                        updateTaskList.add(tsk);
                        break;
                    }
                    if( tsk.GCM_Account__c != caseList.get(0).AccountId){
                        tsk.GCM_Account__c = caseList.get(0).AccountId;
                        taskIdList.add(tsk.Id);
                        tsk.GCM_ByPassValidation_Timestamp__c = system.now();
                        updateTaskList.add(tsk);
                        break;
                    }
                    if( tsk.WhoId != caseList.get(0).ContactId){
                        tsk.WhoId = caseList.get(0).ContactId;
                        tsk.GCM_ByPassValidation_Timestamp__c = system.now();
                        taskIdList.add(tsk.Id);
                        updateTaskList.add(tsk);
                        break;
                    }
                }
                if(tsk.WhatId != apexpages.currentpage().getparameters().get('id')){
                    tsk.WhatId = apexpages.currentpage().getparameters().get('id');
                    if(!caseList.isEmpty()){
                        tsk.GCM_Account__c = caseList.get(0).AccountId;
                        tsk.WhoId = caseList.get(0).ContactId;
                    }
                    tsk.GCM_ByPassValidation_Timestamp__c = system.now();
                    taskIdList.add(tsk.Id);
                    updateTaskList.add(tsk);
                    //Update Case Parent Interaction Id with the latest interaction.
                    caseList.get(0).GCM_Parent_Interaction_Id__c = tsk.softphone_it__IWS_Interaction_ID__c;
                    caseList.get(0).GCM_ByPassValidation_Timestamp__c = system.now();
                    updateExistingCaseList.add(caseList.get(0));
                    //Create a email message copy and associate it to the case. Delete the original one.
                    if(String.isNotBlank(tsk.GCM_Email_Message_Id__c)){
                        List<EmailMessage> emailMsgList = [Select Id, ParentId, RelatedToId, ActivityId, Subject, CcAddress, TextBody, HTMLBody, MessageDate, FromAddress, ToAddress, Status, Headers, CreatedById from EmailMessage Where Id =: tsk.GCM_Email_Message_Id__c];
                        if(!emailMsgList.isEmpty()){
                            EmailMessage emg = new EmailMessage();
                            emg.ParentId = caseList.get(0).Id;
                            emg.RelatedToId = caseList.get(0).Id;
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
            }
        }
        if(!insertEmailList.isEmpty() && !deleteEmailList.isEmpty()){
            insert insertEmailList;
            if(!updateTaskList.isEmpty()) updateTaskList.get(0).GCM_Email_Message_Id__c = insertEmailList.get(0).Id;
        }
        if(!updateTaskList.isEmpty()){
            update updateTaskList;
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
        
        }catch(Exception e){    BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'associateExistingCaseDetailstoTask', taskIdList, 'GCM_Application_Administrator');   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));}
    }
    
/****************************************************************************************************
  Custom Method for Page load
 ****************************************************************************************************/    
    public void pageLoad() {  } 

/****************************************************************************************************
  Get RecordType Id with DeveloperName and SobjectType
 ****************************************************************************************************/    
    @AuraEnabled
    public static Id getRecordTypeId(String devName, String sobj) { 
        try{
            if(String.isNotBlank(devName) && String.isNotBlank(sobj)){
                Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Schema.SObjectType sobjType = gd.get(sobj);
                Schema.DescribeSObjectResult R = sobjType.getDescribe();
                List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
                for( Schema.RecordTypeInfo recordType : RT ){
                    if(recordType.isAvailable()){ 
                        if(recordType.Name!='Master' ) {
                            if(recordType.DeveloperName == devName){
                                return recordType.recordTypeId;
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_CTIController', 'createTaskforNewInboundEmailwithCaseInsert', new List<Id>(), 'GCM_Application_Administrator'); 
        }
        return null;
    }
     
    //Custom Exception class
    public class CTIControllerException extends Exception {}
}