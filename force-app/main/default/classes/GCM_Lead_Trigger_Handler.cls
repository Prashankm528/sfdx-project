/****************************************************************************************************
 *  Date          : 25-AUG-2020
 *  Author        : Sunny Yap
 *  Description   : Code that saves User Team.
 * Modifications  : 25-AUG-2020 SYAP - Initial
 ****************************************************************************************************/

public with sharing class GCM_Lead_Trigger_Handler extends BPG_Trigger_Handler_Utilities { 

/****************************************************************************************************
 * beforeUpdate Event
 ****************************************************************************************************/
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
        GCM_Lead_Trigger_Helper.setTeamName((Map<Id, Lead>) oMap, (Map<Id, Lead>) nMap, (List<Lead>) n); 
    }

/****************************************************************************************************
 * beforeInsert Event
 ****************************************************************************************************/   
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        GCM_Lead_Trigger_Helper.setTeamName((Map<Id, Lead>) oMap, (Map<Id, Lead>) nMap, (List<Lead>) n);
    }
}