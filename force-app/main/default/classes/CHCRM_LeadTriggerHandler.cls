/***********************************************************************************************
 * @author           Jessica
 * @date             2020/06/30
 * @group            CHCRM
 * @description      Lead trigger handler to use the trigger handler framework
 * @Test Class       CHCRM_LeadTriggerHandlerTest
 * history
 * 2020/06/30  Jessica  Created
 ************************************************************************************************/
public with sharing class CHCRM_LeadTriggerHandler extends BPG_Trigger_Handler_Utilities {

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        new CHCRM_LeadProcess().leadAssignmentRule((List<Lead>) newList);
    }

    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        //new CHCRM_LeadProcess().shareCreatorReadAccess((List<Lead>) newList, (Map<Id, Lead>) oldMap, 'afterUpdate');
        new CHCRM_LeadProcess().createAddressInformation((List<Lead>) newList);
    }

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        //new CHCRM_LeadProcess().shareCreatorReadAccess((List<Lead>) newList, (Map<Id, Lead>) oldMap, 'afterInsert');
        //new CHCRM_LeadProcess().createAddressInformation((List<Lead>) newList);
    }

}