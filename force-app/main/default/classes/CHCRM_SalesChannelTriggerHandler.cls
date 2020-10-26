/***********************************************************************************************
 * @author           Xc
 * @date             2020/06/19
 * @group            CHCRM
 * @description      CHCRM Sales Channel handler to use the trigger handler framework

 * history
 * 2020/06/19  Xc  Created 
 ************************************************************************************************/
public with sharing class CHCRM_SalesChannelTriggerHandler extends BPG_Trigger_Handler_Utilities {
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CHCRM_SalesChannelProcess process = new CHCRM_SalesChannelProcess();
        process.populateDirectCustomer((List<CHCRM_Sales_Channel__c>)newList);
    }

    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        CHCRM_SalesChannelProcess process = new CHCRM_SalesChannelProcess();
        process.populateDirectCustomer((List<CHCRM_Sales_Channel__c>)newList);
    }
}