/****************************************************************************************
 *  Date          : 18-JUN-2020
 *  Author        : Sushant Sethi
 *  Description   : Calls platform trigger handler.
 ******************************************************************************************/
trigger BPG_SocialPersona_Trigger on SocialPersona (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    BPG_Trigger_Handler_Utilities.handleEvent('SocialPersona', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);

}