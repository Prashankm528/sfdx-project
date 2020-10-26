/************************************************************************************************************
* Description : 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-Jan-29   1.0                 Frantisek Kolacny   Initial version 
* 2018-Aug-24   1.0                 Jana Cechova        Updated to include CAJBP_CalculateEstimateAndActualCost
* 2018-Oct-03   2.0                 Jan Majling	        Refactored to use Task Trigger Handler
*
*************************************************************************************************************/
trigger TaskTrigger on Task (after insert, before delete) {

	TaskTriggerHandler handler = new TaskTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

	if(Trigger.isBefore && Trigger.isDelete) {
		handler.handleBeforeDelete();
	}

	if(Trigger.isAfter && Trigger.isInsert) {
		handler.handleAfterInsert();
	}

	if(Trigger.isAfter && Trigger.isUpdate) {
		handler.handleAfterUpdate();
	}

	if(Trigger.isAfter && Trigger.isDelete) {
		handler.handleAfterDelete();
	}
}