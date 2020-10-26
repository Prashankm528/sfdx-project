/**
* @author Santosh Verma
* @date 04/08/2019
* @description Triggers on Committee meeting object
* 
*/

trigger ICRM_ComMeetTrigger on ICRM_Committee_Meetings__c (before insert, after insert, before update, after update, before delete, after delete) { 

BPG_Trigger_Handler_Utilities.handleEvent('ICRM_Committee_Meetings__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
}