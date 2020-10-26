/****************************************************************************************************
 *  Date          : 02-MAR-2020
 *  Author        : Roselin Hephzibah
 *  Description   : To delete duplicate emails created by current users for Genesys Interactions.
 * Modifications  : 24-JUN-2020 Roselin Optimized the code.
 ****************************************************************************************************/

global with sharing class GCM_GSYS_DuplicateEmailHandler {

/****************************************************************************************************
  GCM_GSYS_DuplicateEmailHandler parameterized constructor with GCM_CTIController.
 ****************************************************************************************************/    
    public GCM_GSYS_DuplicateEmailHandler(GCM_CTIController duplicateEmailHandlerCust){ }

/****************************************************************************************************
  Delete duplicate email messages created by current user during email transfer
 ****************************************************************************************************/ 
  @future
  global static void deleteDuplicateEmails() {
      Set<Id> emailIdSet = new Set<Id>();
      List<BPG_Error_Log__c> updateBPGErrorLog = new List<BPG_Error_Log__c>();
      List<EmailMessage> emailMessageList = new List<EmailMessage>();
      try {
          //Get the duplicate emails
          List<BPG_Error_Log__c> bpgRecords = [Select Id, BPG_Method__c, BPG_Object_Name__c, BPG_Object_Type__c, BPG_Record_ID__c, BPG_Stack_Trace__c, BPG_User__c, BPG_Error_Message__c from BPG_Error_Log__c WHERE BPG_Method__c =: 'DeleteEmailDuplicatesGenesys' AND BPG_Object_Name__c =: 'GCM_CTIController' AND BPG_User__c =: UserInfo.getUserId()];
          for(BPG_Error_Log__c bpg : bpgRecords){
              if(String.isBlank(bpg.BPG_Error_Message__c)){
                  bpg.BPG_Error_Message__c = 'Update:Deleted';
                  emailIdSet.add(bpg.BPG_Record_ID__c);
                  updateBPGErrorLog.add(bpg);
              }
          }
          if(emailIdSet.size() > 0){
              emailMessageList = [Select Id from Emailmessage WHERE Id IN: emailIdSet];
              if(!emailMessageList.isEmpty()){
                  delete emailMessageList;
                  if(!updateBPGErrorLog.isEmpty()){
                      update updateBPGErrorLog;
                  }
              }
          }
      }
      catch (Exception exceptionObject) { BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_GSYS_DuplicateEmailHandler', 'deleteDuplicateEmails', emailIdset, 'GCM_Application_Administrator');
      }
   }
   
/****************************************************************************************************
  Clone attachments before deleting email message duplicates
 ****************************************************************************************************/ 
  @InvocableMethod
  public static void cloneAttachment(List<FlowInputs> flowInputList) {
      List<Attachment> attachList = new List<Attachment>();
      List<EmailMessage> deleteEmailList = new List<EmailMessage>();
	  List<BPG_Error_Log__c> bpgErrorLogList = new List<BPG_Error_Log__c>();      
      try{
          if(!flowInputList.isEmpty()){
              Map<Id,EmailMessage> flowDataMap = new Map<Id,EmailMessage>();
              for(FlowInputs fi : flowInputList){
                  flowDataMap.put(fi.newEmailMsgId, fi.originalEmailMsg);
              }
              
              if(!flowDataMap.isEmpty()){
                  for(Id newEmailMsgId : flowDataMap.keyset()){
                      List<Attachment> existingAttachList = [Select Id, Body, Name, Description, ParentId, ContentType From Attachment Where ParentId =: flowDataMap.get(newEmailMsgId).Id];
                      if(!existingAttachList.isEmpty()){
                          for(Attachment at : existingAttachList) {
                              Attachment newFile = at.clone();
                              newFile.ParentId = newEmailMsgId;
                              newFile.ContentType = at.ContentType;
                              attachList.add(newFile);
                          }
                      }
                      //Delete Orphan duplicate email if the owner and email createdby user is same. Else log in BPG_Error_Log__c
                      if(flowDataMap.get(newEmailMsgId).CreatedById == UserInfo.getUserId()){
                          deleteEmailList.add(flowDataMap.get(newEmailMsgId));
                      } else {
                          BPG_Error_Log__c bel = new BPG_Error_Log__c();
                          bel.BPG_Object_Type__c = 'Class';
                          bel.BPG_Object_Name__c = 'GCM_CTIController';
                          bel.BPG_Method__c = 'DeleteEmailDuplicatesGenesys';
                          bel.BPG_User__c = flowDataMap.get(newEmailMsgId).CreatedById;
                          bel.BPG_Record_ID__c = flowDataMap.get(newEmailMsgId).Id;
                          bpgErrorLogList.add(bel);
                      }
                  }
              }
              
              
              //Insert cloned attachments with new parent Id
              if(!attachList.isEmpty()){
                  insert attachList;
              }
              //Delete duplicate emails.
              if(!deleteEmailList.isEmpty()){
                  delete deleteEmailList;
              }
              //Insert Error Log
              if(!bpgErrorLogList.isEmpty()){
                  insert bpgErrorLogList;
              }
          }
      }
      catch (Exception exceptionObject) { BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_GSYS_DuplicateEmailHandler', 'cloneAttachment', (List<Id>)null, 'GCM_Application_Administrator');
      }
   }
   
   //Input details that comes to apex from flow
    public class FlowInputs{
    
        @InvocableVariable
        public EmailMessage originalEmailMsg;
        
        @InvocableVariable
        public Id newEmailMsgId;
        
    }
    
    //Custom Exception class
    public class DeleteEmailException extends Exception {}
}