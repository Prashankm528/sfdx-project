/**
*___________________________________________________
*@Name:     CDM_updateApproverComments
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get approval comments.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_updateApproverComments {
    
    /**
*————————————————————————————————————————————————————
* @Description
*  Approval Process instance comments get updating.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    public static void getProcessInstanceComments(Map<Id, CDM_Credit_Debit_Note__c> newMap, Map<Id, CDM_Credit_Debit_Note__c> oldMap) {
        
        List<CDM_Credit_Debit_Note__c> cdmUpdateLst = new List<CDM_Credit_Debit_Note__c>();
        
        set<String> cdmIds = new set<String>();
        
        for(CDM_Credit_Debit_Note__c cdm: newMap.values()) 
            if(cdm.CDM_Form_Status__c != oldMap.get(cdm.id).CDM_Form_Status__c) 
            cdmIds.add(cdm.id);
        
        if(cdmIds.size()>0) {
            
            Map<String,list<ProcessInstance>> piMap = new Map<String,list<ProcessInstance>>();
            for(ProcessInstance pi :[SELECT TargetObjectId,LastActorId,LastActor.Name,(SELECT Id, ActorId,OriginalActor.Name,Comments,StepStatus, ProcessInstanceId FROM StepsAndWorkitems), (SELECT Id, StepStatus, Comments  FROM Steps)
                                     FROM ProcessInstance WHERE TargetObjectid IN : cdmIds ORDER BY CreatedDate DESC]) {
                                         
                                         if(piMap.containsKey(pi.TargetObjectid)) 
                                             piMap.get(pi.TargetObjectid).add(pi);
                                         else 
                                             piMap.put(pi.TargetObjectid, new list<ProcessInstance>{pi});
                                     }
            
            
            
            
            system.debug(piMap);
            
            for(CDM_Credit_Debit_Note__c cdm: newMap.values()) {
                if(cdm.CDM_Form_Status__c != oldMap.get(cdm.id).CDM_Form_Status__c) 
                    if(piMap.containsKey(cdm.id)) {
                       
                        for(ProcessInstance pis: piMap.get(cdm.id))
                            for(ProcessInstanceHistory ps : pis.StepsAndWorkitems) {
                                if(ps.StepStatus == 'Approved') {
                                    if(ps.OriginalActor.name == 'CDM DOFA Reviewer')
                                        cdm.CDM_Reviewer_Comments__c = ps.Comments;
                                    else    
                                        cdm.CDM_Approver_Comments__c = ps.Comments;
                                }
                                if(ps.StepStatus == 'Rejected') {
                                    if(ps.OriginalActor.name == 'CDM DOFA Reviewer')
                                        cdm.CDM_Reviewer_Rejected_Comments__c = ps.Comments;
                                    else    
                                        cdm.CDM_Approver_Rejected_Comments__c = ps.Comments;
                                }
                                
                               
                            }  
                    }
            }
            
            
            
        }  
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  update cdm eform status when status is rejected.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    
    public static void updateCdmEformStatus(Map<Id, CDM_Credit_Debit_Note__c> newMap, Map<Id, CDM_Credit_Debit_Note__c> oldMap) {
         for(CDM_Credit_Debit_Note__c cdm: newMap.values()) 
            if(!(cdm.CDM_Form_Status__c != oldMap.get(cdm.id).CDM_Form_Status__c))
                if(cdm.CDM_Form_Status__c== 'Rejected' || cdm.CDM_Form_Status__c== 'Failed')  {
                    cdm.CDM_Form_Status__c = 'Draft';
                    cdm.CDM_Dofa_Review_Status__c = '';
                    cdm.CDM_Credit_Approval_Amount__c  = 0;
                    cdm.CDM_Debit_Approval_Amount__c = 0;
                    cdm.CDM_Approval_Unlimited_Amount__c= false;
                    
                }    
   
   }
    
    
}