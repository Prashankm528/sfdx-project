/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @description: BP Social Post Trigger
*/

trigger BPG_SocialPost_Trigger on SocialPost (before insert, before update, before delete, after insert, after update, after delete, after undelete){ 

    BPG_Trigger_Handler_Utilities.handleEvent('SocialPost', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}