/*****************************************************************************************
*	    Date:		    10APR2018
*       Author:         Platform Team - Customer Org <adam.walker1@bp.com>
*       Description:    The Generic Trigger Handler for the Event. Please add your product specific handler this class
*                       If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
*       Modifications:  25NOV2019 Rahma Belghouti - Refactor the trigger handler to use the trigger handler framework
*       				27APR2020 Rahma Belghouti - Remove reference of JBP code
****************************************************************************************/

public with sharing class SFO_EventTriggerHandler extends BPG_Trigger_Handler_Utilities {
	
    /*
    * Updates last meeting activity date
    */
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new CASFO_AccountLastMeetingActivity().startUpdate((List<Event>) newList, (Map<Id, Event>)oldMap);
    }
    
   /*
    * Updates last meeting activity date
    */
    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {        
        new CASFO_AccountLastMeetingActivity().startUpdate((List<Event>) newList, (Map<Id, Event>)oldMap);
    }
    
   /*
    * Updates Account when QBR is deleted
    */
    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {        
        new CASFO_QBREventDeleted().updateAccountWhenQBRDeleted((List<Event>)oldList);
    }
       
}