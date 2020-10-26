/***********************************************************************************************
* @author           WuTong
* @date             2020/08/25
* @group            CHCRM
* @description      create this class for CHCRM_Key_Account_Plan_Trigger
* @test class       CHCRM_Key_Account_Plan_TriggerHandlerTest
* history
* 2020/08/25  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_Key_Account_Plan_TriggerHandler extends BPG_Trigger_Handler_Utilities{
    
   public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug){
        System.debug('CHCRM_Key_Account_Plan_TriggerHandler beforeInsert start!');
        CHCRM_Key_Account_PlanProcess.checkKAPIsUniquene(newList);
    }
    
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        System.debug('CHCRM_Key_Account_Plan_TriggerHandler afterInsert start!');
        CHCRM_Key_Account_PlanProcess.bindleSalesTarget(newList);
    }
    
}