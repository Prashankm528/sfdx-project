/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @group: BPG
* @description: BPCM service class for FeedItem and FeedComment objects
* @name BPCM_FeedService.cls
*/

public inherited sharing class BPCM_FeedService {
    
    /** 
     * @description: method to run after insert and centralise all logics
     * 1. Identify all Post (FeedItem) related with a BPCM Case and then sum an interaction to the case (case touch) for BPCM Profile only
     * @author Gabriela Matos | 19/06/2020
     * @param: Map of new FeedItem records
     * @return void
     * */
    public void runAfterInsert(Map<Id, FeedItem> newMap){

        //querying to capture record type dev name and created by name.
        List<FeedItem> fiCompleteInfoList = [SELECT ParentId, 
                                                      Parent.RecordType.DeveloperName
                                                 FROM FeedItem WHERE Id IN: newMap.KeySet()];

        Map<Id, List<String>> fiListMap = new Map<Id, List<String>>();
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        for(FeedItem fi : fiCompleteInfoList){
            if(fi.ParentId != null){
                String sObjName = fi.ParentId.getSObjectType().getDescribe().getName();
                if(sObjName != null && sObjName == BPCM_GlobalConstants.CASE_SOBJECT_TYPE
                   && fi.Parent.RecordType.DeveloperName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)
                   && userProfile.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){
                    //count to number of comments made on the Case (interaction)   
                    fiListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(fiListMap, fi.ParentId, BPCM_GlobalConstants.CHT_COMMENTS_FIELD_APINAME);
                }
            }
        }

        if(!fiListMap.isEmpty()){
            BPCM_CaseTouchHistoryService.captureCaseTouches(fiListMap);
        }
    }

    /** 
     * @description: method to run after insert and centralise all logics
     * 1. Identify all Post (FeedComment) related with a BPCM Case and then sum an interaction to the case (case touch) for BPCM Profile only
     * @author Gabriela Matos | 19/06/2020
     * @param: Map of new FeedComment records
     * @return void
     * */
    public void runAfterInsert(List<FeedComment> newRecords){

        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        Map<Id, List<String>> fcListMap = new Map<Id, List<String>>();

        for(FeedComment fc : newRecords){
            if(fc.ParentId != null){
                String sObjName = fc.ParentId.getSObjectType().getDescribe().getName();
                if(sObjName != null && sObjName == BPCM_GlobalConstants.CASE_SOBJECT_TYPE
                   && userProfile.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){
                    //count to number of comments made on the Case (interaction)   
                    fcListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(fcListMap, fc.ParentId, BPCM_GlobalConstants.CHT_COMMENTS_FIELD_APINAME);
                }
            }
        }

        if(!fcListMap.isEmpty()){
            BPCM_CaseTouchHistoryService.captureCaseTouches(fcListMap);
        }
    }
}