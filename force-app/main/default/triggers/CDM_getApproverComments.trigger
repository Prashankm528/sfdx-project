/**
 * @author chandra kanchi
 * @date 25/07/2019
 * @description triggers on CDM_Credit_Debit_Note object
 * 
 */

trigger CDM_getApproverComments on CDM_Credit_Debit_Note__c (after update,before update,After insert, before insert) {

  CDM_EformTriggerHandler handler = new CDM_EformTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

  if(Trigger.isBefore && Trigger.isUpdate) {
    handler.handleBeforeUpdate();
  }
  
   if(Trigger.isBefore && Trigger.isInsert) {
    handler.handleBeforeInsert();
  }
  
  if(Trigger.isAfter && Trigger.isUpdate){
    handler.handleAfterUpdate();
  }
  
  if(Trigger.isAfter)
  if(Trigger.isUpdate || trigger.isInsert){
    handler.handleAfterUpdate_Insert();
  }
  
  
  
}