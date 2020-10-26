/***********************************************************************************************
 * @author           DK
 * @date             2020/08/20
 * @group            CHCRM
 * @description      CHCRM WSP Yearly Statsc trigger handler to use the trigger handler framework
 *
 * history
 * 2020/08/20  DK  Created 
 ************************************************************************************************/
public with sharing class CHCRM_WSPYearlyStatsTriggerHandler extends BPG_Trigger_Handler_Utilities {
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {   
        new CHCRM_WSPYearlyStatsProcess().syncDataToSurounding(newList);        
    }

    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {   
        new CHCRM_WSPYearlyStatsProcess().syncDataToSurounding(newList);        
    }
}