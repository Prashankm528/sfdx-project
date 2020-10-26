/***********************************************************************************************
 * @author           Xc
 * @date             2020/08/12
 * @group            CHCRM
 * @description      HQ Monthly Assignment Objective trigger handler to use the trigger handler framework
 *
 * history
 * 2020/08/12  Xc  Created 
 ************************************************************************************************/
public with sharing class CHCRM_HQMonthlyAssgmntObjTriggerHandler extends BPG_Trigger_Handler_Utilities {
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {   
        new CHCRM_HQMonthlyAssignmentObjProcess().syncDataToSurounding(newList);        
    }

    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {   
        new CHCRM_HQMonthlyAssignmentObjProcess().syncDataToSurounding(newList);        
    }
}