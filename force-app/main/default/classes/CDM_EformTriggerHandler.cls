/**
 * @Who     Chandra Mohan Kanchi
 * @when    19-03-2019
 * @what    The Generic Trigger Handler for the CDM_Credit_Debit_Note.
 **/

public with sharing class CDM_EformTriggerHandler {
    
    private final List<CDM_Credit_Debit_Note__c> newRecords;
    private final List<CDM_Credit_Debit_Note__c> oldRecords;
    private final Map<Id, CDM_Credit_Debit_Note__c> newMap;
    private final Map<Id, CDM_Credit_Debit_Note__c> oldMap;
    //Trigger execution check variable
    public static Boolean runOnce = true;
     /**
    *————————————————————————————————————————————————————
    * @Description
    * Trigger handler constructer.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public CDM_EformTriggerHandler(List<CDM_Credit_Debit_Note__c> newRecords, List<CDM_Credit_Debit_Note__c> oldRecords, Map<Id, CDM_Credit_Debit_Note__c> newMap, Map<Id, CDM_Credit_Debit_Note__c> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap     = newMap;
        this.oldMap     = oldMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Before update trigger handler method and get approver comments
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public void handleBeforeUpdate() {
        List<Id> cdmApproverIds = new List<Id>();
        if(CDM_EformTriggerHandler.runOnce) {
            CDM_updateApproverComments.getProcessInstanceComments(this.newMap,this.oldMap);
            CDM_updateApproverComments.updateCdmEformStatus(this.newMap,this.oldMap);
            for(CDM_Credit_Debit_Note__c cdm: this.newRecords) {
           		if(cdm.CDM_Approver__c != oldMap.get(cdm.id).CDM_Approver__c && cdm.CDM_Approver__c != NULL)
              		cdmApproverIds.add(cdm.CDM_Approver__c); 
       		}        
            if(!cdmApproverIds.isEmpty())
           		updateApproverId(cdmApproverIds); 
        }
         CDM_EformTriggerHandler.runOnce = false;
    }
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    * Before insert trigger handler method and update authorisation type if sales doc is ZNCR
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public void handleBeforeInsert() {
        List<Id> ApproverIds = new List<Id>();
        Map<Id,Id> approverIdtoUserIdmap = new map<Id,Id>();
        if(trigger.isInsert) 
        	for(CDM_Credit_Debit_Note__c cdm: this.newRecords) {
           
                   if(cdm.CDM_Country__c == 'New Zealand' || cdm.CDM_Country__c == 'Australia') {
                       if(cdm.CDM_Sales_Doc_Type__c == 'ZNCR') { // for ANZ
                           if(String.isNotBlank(cdm.CDM_Invoice_Number__c))
                               cdm.CDM_Authorisation_Type__c = 'IP';
                           else
                               cdm.CDM_Authorisation_Type__c = 'SG';
                        } 
                            
                        if(cdm.CDM_Sales_Doc_Type__c == 'ZCRR') { // for ANZ
                           cdm.CDM_Authorisation_Type__c = 'IN';
                        }  
                     } 
                if(cdm.CDM_Approver__c != NULL){
                    ApproverIds.add(cdm.CDM_Approver__c);
                }
           }
        if(!ApproverIds.isEmpty()){
            updateApproverId(ApproverIds);
        }
    }
      
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    * After update trigger handler method and create NL child records using csv file in that cdm parent.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
   public void handleAfterUpdate() {
       List<id> cdmIds = new List<Id>();
       List<id> cdmApprovalIds = new List<Id>();
       List<Id> cdmApproverIds = new List<Id>();
       for(CDM_Credit_Debit_Note__c cdm: this.newRecords) {
           if(cdm.CDM_Form_Status__c != oldMap.get(cdm.id).CDM_Form_Status__c && cdm.CDM_Form_Status__c == 'Approved' && cdm.CDM_Bulk_Upload__c == 'Yes')
               cdmIds.add(cdm.id); 
           if((cdm.CDM_Credit_Approval_Amount__c != oldMap.get(cdm.id).CDM_Credit_Approval_Amount__c || 
               cdm.CDM_Debit_Approval_Amount__c != oldMap.get(cdm.id).CDM_Debit_Approval_Amount__c || 
               cdm.CDM_Approval_Unlimited_Amount__c != oldMap.get(cdm.id).CDM_Approval_Unlimited_Amount__c ||
               (cdm.CDM_Luis_Failed__c != oldMap.get(cdm.id).CDM_Luis_Failed__c && cdm.CDM_Luis_Failed__c)) && 
               (cdm.CDM_Form_Status__c == 'Review' || cdm.CDM_Form_Status__c == 'Draft' || cdm.CDM_Form_Status__c == 'Rejected'))
              
                   cdmApprovalIds.add(cdm.id);     
       }        
               
       if(!cdmIds.isEmpty())
          CDM_EformsBulkUpload.createChildEformsData(cdmIds);
       if(!cdmApprovalIds.isEmpty())
          CDM_GetDollerValueFromRPA.cdmSubmitForApproval(cdmApprovalIds);      
   }
   
    /**
    *————————————————————————————————————————————————————
    * @Description
    * After update or Insert trigger handler method and check approver Authorisation type.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
   public void handleAfterUpdate_Insert() {
       List<Id> zncrAuthTypeIds = new List<Id>();
       List<id> zcrrAuthTypeIds = new List<Id>();
       List<id> cdmIds = new List<Id>();
       for(CDM_Credit_Debit_Note__c cdm: this.newRecords) {
           if(cdm.CDM_approver__c != null)
               if(trigger.isAfter) {
                   if(trigger.isUpdate) {
                       if(cdm.CDM_Country__c == 'New Zealand' || cdm.CDM_Country__c == 'Australia') {
                           if(cdm.CDM_Sales_Doc_Type__c != oldMap.get(cdm.id).CDM_Sales_Doc_Type__c || 
                               cdm.CDM_Invoice_Number__c != oldMap.get(cdm.id).CDM_Invoice_Number__c)
                               if(cdm.CDM_Sales_Doc_Type__c == 'ZNCR') {
                                   if(cdm.CDM_Invoice_Number__c == null || cdm.CDM_Invoice_Number__c == '') 
                                       zncrAuthTypeIds.add(cdm.id); // for ANZ
                               } 
                       } else {   
                            if(cdm.CDM_Approver__c != oldMap.get(cdm.id).CDM_Approver__c) 
                              
                                       cdmIds.add(cdm.id); // for Europe       
                               
                        } 
                    }       
                   if(trigger.isInsert) {
                        if(cdm.CDM_Country__c == 'New Zealand' || cdm.CDM_Country__c == 'Australia') {
                           if(cdm.CDM_Sales_Doc_Type__c == 'ZNCR') 
                               if(cdm.CDM_Invoice_Number__c == null || cdm.CDM_Invoice_Number__c == '') 
                                   zncrAuthTypeIds.add(cdm.id); // for ANZ
                         } else {   
                               if(cdm.CDM_Approver__c != null)
                                  cdmIds.add(cdm.id); // for Europe 
                            } 
                     }      
                 } 
         }           
      if(!zncrAuthTypeIds.isEmpty())
         CDM_GetValidate_Approvers_ZNCRFromDoFA.getValidateAuthType(zncrAuthTypeIds);
         
     // if(!cdmIds.isEmpty())
         //CDM_GetSupportingNotesFromDofa.getCDM_GetSupportingNotes(cdmIds);   
   }
   //Method to update Approver User Id on CDM record...
    public void updateApproverId(List<Id> cdmApproverIds){
    	Map<Id,Id> approverIdtoUserIdmap = new Map<Id,Id>();
        for(CDM_Credit_Debit_Note_Approvers__c cdmapp:[select id,CDM_Approver_User__c from CDM_Credit_Debit_Note_Approvers__c
                                                       where id in :cdmApproverIds])
        {
           	approverIdtoUserIdmap.put(cdmapp.Id,cdmapp.CDM_Approver_User__c);
        }
        for(CDM_Credit_Debit_Note__c cdm: this.newRecords)
        {
            if(approverIdtoUserIdmap.containskey(cdm.CDM_Approver__c))
        	   	cdm.CDM_Approver_Id__c = approverIdtoUserIdmap.get(cdm.CDM_Approver__c);
        }                                          
    } 
  
}