/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @group: BPG
* @description: BPCM service class for SocialPost object
* @name BPCM_SocialPostService.cls
*/

public inherited sharing class BPCM_SocialPostService {

    /** 
     * @description: method to run after insert and centralise all logics
     * 1. Identify all SocialPost related with a BPCM Case && it's outbound, then sum an interaction to the case (case touch)
     * @author Gabriela Matos | 18/06/2020
     * @param: Map of new SocialPost records
     * @return void
     * */
    public void runAfterInsert(Map<Id, SocialPost> newMap){

        //querying to capture record type dev name.
        List<SocialPost> spCompleteInfoList = [SELECT ParentId, IsOutbound,
                                                  Parent.RecordType.DeveloperName
                                                 FROM SocialPost WHERE Id IN: newMap.KeySet()];

        Map<Id, List<String>> spListMap = new Map<Id, List<String>>();

        for(SocialPost sp : spCompleteInfoList){
            if(sp.ParentId != null){
                String sObjName = sp.ParentId.getSObjectType().getDescribe().getName();
                if(sObjName != null && sObjName == BPCM_GlobalConstants.CASE_SOBJECT_TYPE 
                   && sp.Parent.RecordType.DeveloperName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){

                    if(sp.IsOutbound){
                        //count number of outbound social post made on the Case (interaction)   
                        spListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(spListMap, sp.ParentId, BPCM_GlobalConstants.CHT_OUT_SOCIAL_FIELD_APINAME);
                    }
                }
            }
        }

        if(!spListMap.isEmpty()){
            BPCM_CaseTouchHistoryService.captureCaseTouches(spListMap);
        }
    }
}