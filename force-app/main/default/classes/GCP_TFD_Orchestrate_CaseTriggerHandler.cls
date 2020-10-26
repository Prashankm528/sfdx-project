/**
* @author       Sid
* @date      	11/12/2019
* @description  Handles Orchestrate trigger events on Case object       
*/
public with sharing class GCP_TFD_Orchestrate_CaseTriggerHandler extends BPG_Trigger_Handler_Utilities 
{ 
	//After Insert method...
	public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
		FSTR.COTriggerHandler.handleBothTrigger();
	}
	//Before Insert method...
	public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
		FSTR.COTriggerHandler.handleBothTrigger();
	}
	//Before Update method...
	public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
		FSTR.COTriggerHandler.handleBothTrigger();
	}
	//After update Method...
	public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
		FSTR.COTriggerHandler.handleBothTrigger();
	}
	//Before Delete Method...
	public override void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
		FSTR.COTriggerHandler.handleBothTrigger();
	}
	//After Undelete menthod...
	public override void afterUndelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
		FSTR.COTriggerHandler.handleBothTrigger();
	}
}