/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @group: BPG
* @description: BPCM Hander class for FeedItem trigger
* @name BPCM_FeedItemTriggerHandler.cls
*/

public with sharing class BPCM_FeedItemTriggerHandler extends BPG_Trigger_Handler_Utilities {
    
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug){
        new BPCM_FeedService().runAfterInsert( (Map<Id, FeedItem>) newMap);
    }
}