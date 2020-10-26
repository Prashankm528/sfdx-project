/***********************************************************************************************
 * @author           Chris
 * @date             2020/03/27
 * @group            CHCRM
 * @description      Event trigger handler to use the trigger handler framework

 * history
 * 2020/03/27  Chris  Created 
 ************************************************************************************************/
public with sharing class CHCRM_EventTriggerHandler extends BPG_Trigger_Handler_Utilities {

    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CHCRM_EventProcess process = new CHCRM_EventProcess();
        process.validation((List<Event>)newList);
        process.createRelatedDetails((List<Event>)newList);
        process.populateEventFields((List<Event>)newList,(Map<Id,Event>)oldMap);
    }

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CHCRM_EventProcess process = new CHCRM_EventProcess();
        process.pupulateVisitDetailFields((List<Event>)newList);
        for(Event e : (List<Event>)newList){
            process.syncDataToSurounding(e.Id);
        }
    }

    public override void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new CHCRM_EventProcess().deleteRelatedDetails((List<Event>)oldList);
        for(Event e : (List<Event>)oldList){
            new CHCRM_EventProcess().syncDelDataToSurounding(e.Id);
        }
    }

    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        CHCRM_EventProcess process = new CHCRM_EventProcess();
        process.populateEventFields((List<Event>)newList,(Map<Id,Event>)oldMap);
    }

    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        CHCRM_EventProcess process = new CHCRM_EventProcess();
        process.pupulateVisitDetailFields((List<Event>)newList);
    }
}