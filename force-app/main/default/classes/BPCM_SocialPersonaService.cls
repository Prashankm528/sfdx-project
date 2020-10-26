/**
* @Author:       Sushant Sethi
* @Date  :       18 June 2020
* @Description : This class handles trigger activities related to BPCM SocialPersona object
**/
public with sharing class BPCM_SocialPersonaService{
    
    public static map<id,id> oldNewParentMap;
    
    /*  Method Name: runAfterUpdate(List<SocialPersona> socialPersonaNewRec,Map<id,SocialPersona> socialPersonaOldMap)
Method Desription:  This method will handle the logic for BPCM Cases
This method will accept list<case> to be processed and will set the fields on BPCM Cases with business defined rules
*/
    public static void runAfterUpdate(List<SocialPersona> socialPersonaNewRec,Map<id,SocialPersona> socialPersonaOldMap){
        set<id> oldParentId = new set<id>();
        set<id> newParentId = new set<id>();
        oldNewParentMap = new map<id,id>();
        for(SocialPersona spRec : socialPersonaNewRec){
            if(spRec.ParentId != socialPersonaOldMap.get(spRec.id).ParentId && socialPersonaOldMap.get(spRec.id).ParentId.getSObjectType()==Contact.sObjectType){
                oldParentId.add(socialPersonaOldMap.get(spRec.id).ParentId);
                newParentId.add(spRec.ParentId);
                oldNewParentMap.put(spRec.ParentId,socialPersonaOldMap.get(spRec.id).ParentId);
            }
        }
        reparentSocialPersona(oldParentId,newParentId);
    }
    
    private static void reparentSocialPersona(set<id> OldparentIdSet, set<id> newParentIdSet){
        set<id> oldContactIdSet = new set<id>();
        set<id> newContactIdSet = new set<id>();
        set<id> newAccountIdSet = new set<id>();
        set<id> newLeadIdSet = new set<id>();
        set<id> newSocialPostIdSet = new set<id>();
        map<id,Contact> newContactMap = new map<id,Contact>();
        map<id,Account> newAccountMap = new map<id,Account>();
        map<id,string> recordIdRecordTypeMap = new map<id,string>();
        map<id,id> oldParentIdAccountMap = new map<id,id>();
        map<id,List<Case>> OldcontactRelatedCase = new map<id,List<Case>>();
        map<id,List<Task>> OldcontactRelatedTask = new map<id,List<Task>>();
        List<case> casesToUpdate = new List<case>();
        List<Task> tasksToUpdate = new List<Task>();
        List<contact> conToDelete = new List<contact>();
        for(contact parentId : [SELECT id,recordType.DeveloperName,Account.RecordType.DeveloperName,AccountId FROM Contact WHERE ID IN:OldparentIdSet]){
            recordIdRecordTypeMap.put(parentId.id,parentId.recordType.DeveloperName);
            recordIdRecordTypeMap.put(parentId.AccountId,parentId.Account.RecordType.DeveloperName);
            oldParentIdAccountMap.put(parentId.id,parentId.AccountId);
        }
        for(id parentId : OldparentIdSet){
            if(recordIdRecordTypeMap.containsKey(parentId) && oldParentIdAccountMap.containsKey(parentId) && recordIdRecordTypeMap.containsKey(oldParentIdAccountMap.get(parentId)) &&
               recordIdRecordTypeMap.get(parentId) != null && recordIdRecordTypeMap.get(parentId).equalsIgnoreCase(BPCM_GlobalConstants.BPCM_CONTACT_RECORDTYPE) &&
               recordIdRecordTypeMap.get(oldParentIdAccountMap.get(parentId)).equalsIgnoreCase(BPCM_GlobalConstants.BPCM_LOCATION_RECORDTYPE)){
                   oldContactIdSet.add(parentId);
               }
        }
        for(id parentId : newParentIdSet){
            if(parentId.getSObjectType()==Contact.sObjectType){
                newContactIdSet.add(parentId);
            }
            else  if(parentId.getSObjectType()==Account.sObjectType){
                newAccountIdSet.add(parentId);
            }
        }
        if(newContactIdSet != null && newContactIdSet.size()>0 || newAccountIdSet != null && newAccountIdSet.size()>0){
            for(Contact newConRec : [SELECT id,AccountId,Account.PersonContactId FROM Contact WHERE ID IN:newContactIdSet]){
                newContactMap.put(newConRec.id,newConRec);
            }
            for(Account newAccRec : [SELECT id,PersonContactId FROM Account WHERE ID IN:newAccountIdSet]){
                newAccountMap.put(newAccRec.id,newAccRec);
            }
            List<case> caseList = [Select id,ContactId from Case WHERE ContactId IN:oldContactIdSet];
            List<Task> taskList = [Select id,WhoId from Task WHERE WhoId IN:oldContactIdSet];
            for(case caseRec : caseList){
                if(!OldcontactRelatedCase.containsKey(caseRec.ContactId)){
                    OldcontactRelatedCase.put(caseRec.ContactId, new List<Case>{caseRec});
                }
                else{
                    OldcontactRelatedCase.get(caseRec.ContactId).add(caseRec);
                }
            }
            for(Task taskRec : taskList){
                if(!OldcontactRelatedTask.containsKey(taskRec.WhoId)){
                    OldcontactRelatedTask.put(taskRec.WhoId, new List<Task>{taskRec});
                }
                else{
                    OldcontactRelatedTask.get(taskRec.WhoId).add(taskRec);
                }
            }
            for(id parentId : newParentIdSet){
                if(parentId.getSObjectType()==Contact.sObjectType && oldNewParentMap.containsKey(parentId) && OldcontactRelatedCase.containsKey(oldNewParentMap.get(parentId))){
                    for(Case caseRec:OldcontactRelatedCase.get(oldNewParentMap.get(parentId))){
                        if(newContactMap.containsKey(parentId)){
                            caseRec.AccountId = newContactMap.get(parentId).AccountId;
                            caseRec.ContactId = newContactMap.get(parentId).Account.PersonContactId;
                            casesToUpdate.add(caseRec);
                        }
                    }
                    if(oldNewParentMap.containsKey(parentId) && OldcontactRelatedTask.containsKey(oldNewParentMap.get(parentId))){
                        for(Task taskRec : OldcontactRelatedTask.get(oldNewParentMap.get(parentId))){
                            if(newContactMap.containsKey(parentId)){
                                taskRec.WhoId = newContactMap.get(parentId).Account.PersonContactId;
                                tasksToUpdate.add(taskRec);
                            }
                        }
                    }
                }
                else  if(parentId.getSObjectType()==Account.sObjectType && oldNewParentMap.containsKey(parentId) && OldcontactRelatedCase.containsKey(oldNewParentMap.get(parentId))){
                    for(Case caseRec:OldcontactRelatedCase.get(oldNewParentMap.get(parentId))){
                        if(newAccountMap.containsKey(parentId)){
                            caseRec.AccountId = newAccountMap.get(parentId).Id;
                            caseRec.ContactId = newAccountMap.get(parentId).PersonContactId;
                            casesToUpdate.add(caseRec);
                        }
                    }
                    if(oldNewParentMap.containsKey(parentId) && OldcontactRelatedTask.containsKey(oldNewParentMap.get(parentId))){
                        for(Task taskRec : OldcontactRelatedTask.get(oldNewParentMap.get(parentId))){
                            if(newAccountMap.containsKey(parentId)){
                                taskRec.WhoId = newAccountMap.get(parentId).PersonContactId;
                                tasksToUpdate.add(taskRec);
                            }
                        }
                    }
                } 
            }
            if(tasksToUpdate.size()>0){
                Database.update(tasksToUpdate);
            }
            if(casesToUpdate.size()>0){
                Database.update(casesToUpdate);
            }
            if(oldContactIdSet.size()>0){
                conToDelete = [SELECT id from Contact WHERE ID IN:oldContactIdSet];
                Database.delete(conToDelete);
            }
        }
    }      
    
}