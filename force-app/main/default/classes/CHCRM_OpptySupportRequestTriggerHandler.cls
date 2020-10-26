/***********************************************************************************************
 * @author           FX
 * @date             2020/07/14
 * @group            CHCRM
 * @description      CHCRM Opportunity Support Request trigger handler to use the trigger handler framework
 * @Test Class       CHCRM_OpptySupportRequestTriggerHandlerTest
 * history
 * 2020/07/14  FX  Created
 ************************************************************************************************/
public with sharing class CHCRM_OpptySupportRequestTriggerHandler extends BPG_Trigger_Handler_Utilities {
	public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        new CHCRM_OpptySupportRequestProcess().syncHasCommnetsField((List<CHCRM_Opportunity_Support_Request__c>)newList);
    }
    
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        new CHCRM_OpptySupportRequestProcess().syncHasCommnetsField((List<CHCRM_Opportunity_Support_Request__c>)newList);
    }
}