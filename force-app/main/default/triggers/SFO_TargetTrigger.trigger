/*****************************************************************************************
*	Date:		    15-Jul-2019
*   Author:         Jit Patel - SFO 
*   Description:    Target object trigger 
****************************************************************************************/
trigger SFO_TargetTrigger on SFO_Target__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    BPG_Trigger_Handler_Utilities.handleEvent('SFO_Target__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);

}