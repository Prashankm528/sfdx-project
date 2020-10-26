/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @description: BP Task Trigger
*/

trigger BPG_Task_Trigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete){ 

      BPG_Trigger_Handler_Utilities.handleEvent('Task', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}