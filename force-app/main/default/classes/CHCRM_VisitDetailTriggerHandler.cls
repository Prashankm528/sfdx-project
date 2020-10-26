/***********************************************************************************************
 * @author           Xc
 * @date             2020/05/22
 * @group            CHCRM
 * @description      CHCRM Event(Visit Detail) trigger handler to use the trigger handler framework
 * @Test Class       CHCRM_VisitDetailTriggerHandlerTest
 * history
 * 2020/05/22  Xc  Created 
 ************************************************************************************************/
public with sharing class CHCRM_VisitDetailTriggerHandler extends BPG_Trigger_Handler_Utilities {

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        new CHCRM_VisitDetailProcess().poupulateRegion((List<CHCRM_Event__c>) newList);
    }

    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        new CHCRM_VisitDetailProcess().poupulateRegion((List<CHCRM_Event__c>) newList);
    }

}