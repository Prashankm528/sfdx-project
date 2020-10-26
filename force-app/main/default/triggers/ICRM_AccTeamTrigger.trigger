/**
* @author Santosh Verma
* @date 19/11/2019
* @description triggers on Account Team member object
* 
*/

trigger ICRM_AccTeamTrigger on AccountTeamMember (before insert, after insert, before update, after update, before delete, after delete) { 
BPG_Trigger_Handler_Utilities.handleEvent('AccountTeamMember', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 

}