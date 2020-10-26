/**
* @author Irfan Ahmed
* @date 03/02/2020
* @description triggers on Project Team Member custom object
* 
*/

trigger ICRM_ProjectTeamTrigger on ICRM_Project_Team__c (before insert, after insert, before update, after update, before delete, after delete) { 
  // To handle DML on Project Team
    BPG_Trigger_Handler_Utilities.handleEvent('ICRM_Project_Team__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap); 
}