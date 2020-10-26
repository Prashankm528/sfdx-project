/***********************************************************************************************
 * @author           Xc
 * @date             2020/06/23
 * @group            CHCRM
 * @description      Account trigger handler to use the trigger handler framework

 * history
 * 2020/06/23  Xc  Created 
 * 2020/07/10  WuTong  add Account assign Territory
 ************************************************************************************************/
public with sharing class CHCRM_AccountTriggerHandler extends BPG_Trigger_Handler_Utilities {

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {   
        new CHCRM_AccountProcess().assignAccountToTerritory2(newList);        
    }
/*
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {   
        CHCRM_AccountProcess process = new CHCRM_AccountProcess();
        process.populateFields((List<Account>)newList,(Map<Id,Account>)oldMap);
    }
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) {
        CHCRM_AccountProcess process = new CHCRM_AccountProcess();
        process.populateFields((List<Account>)newList,(Map<Id,Account>)oldMap);
    }
*/
}