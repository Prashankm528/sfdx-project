/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @group: BPG
* @description: BPCM service class for EmailMessage object
* @name BPCM_EmailMessageService.cls
*/

public inherited sharing class BPCM_EmailMessageService {

    /** 
     * @description: method to run after insert and centralise all logics
     * 1. Identify all EmailMessage related with a BPCM Case && it's outbound by BPCM Base Profile (advisor), 
     * then sum an interaction to the case (case touch)
     * @author Gabriela Matos | 18/06/2020
     * @param: Map of new EmailMessage records
     * @return void
     * */
    public void runAfterInsert(Map<Id, EmailMessage> newMap){

        //querying to capture record type dev name and created by name.
        List<EmailMessage> emCompleteInfoList = [SELECT Incoming, 
                                                      ParentId,
                                                      Parent.RecordType.DeveloperName
                                                 FROM EmailMessage WHERE Id IN: newMap.KeySet()];

        Map<Id, List<String>> emOutListMap = new Map<Id, List<String>>();
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        for(EmailMessage em : emCompleteInfoList){
            if(em.ParentId != null){
                String sObjName = em.ParentId.getSObjectType().getDescribe().getName();
                if(!em.Incoming && sObjName == BPCM_GlobalConstants.CASE_SOBJECT_TYPE
                   && em.Parent.RecordType.DeveloperName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)
                   && userProfile.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){
                    //add interaction to the Case (if already exist add to the list, else instance a new list for the case)   
                    emOutListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(emOutListMap, em.ParentId, BPCM_GlobalConstants.CHT_OUT_EMAILS_FIELD_APINAME);
                }
            }
        }

        //invoke the method to capture and create/update Case Touch History
        if(!emOutListMap.isEmpty()){
            BPCM_CaseTouchHistoryService.captureCaseTouches(emOutListMap);
        }
    }
}