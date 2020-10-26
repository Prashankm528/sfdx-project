/**
* @author Santosh Verma
* @date 30/07/2019
* @description triggers on Project object
* 
*/
trigger ICRM_ProjectTrigger on ICRM_Project__c (before insert, after insert, before update, after update, before delete, after delete) { 
BPG_Trigger_Handler_Utilities.handleEvent('ICRM_Project__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 

}