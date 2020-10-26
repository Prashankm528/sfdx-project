/**
 * @author			Jan Majling
 * @date			03/10/2018
 * @description		handles trigger events on Task object
 *
 * history
 * 03/10/2018	Jan Majling			Created 
 */
public with sharing class TaskTriggerHandler {
	private final List<Task> newRecords;
	private final List<Task> oldRecords;
	private final Map<Id,Task> newMap;
	private final Map<Id,Task> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<Task>
	 * @param oldRecords of type List<Task>
	 * @param newMap of type Map<Id,Task>
	 * @param oldMap of type Map<Id,Task>
	 */
	public TaskTriggerHandler(List<Task> newRecords, List<Task> oldRecords, Map<Id,Task> newMap, Map<Id,Task> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}
	/**
	 * @description handles before delete trigger
	 */
	public void handleBeforeDelete() {
		CALCF_CalculateTasksPerSurvey.calculateCountOfTasksAndUpdateSurvey(this.oldRecords, true);
	}
	/**
	 * @description handles after insert trigger
	 */
	public void handleAfterInsert() {
		CALCF_CalculateTasksPerSurvey.calculateCountOfTasksAndUpdateSurvey(this.newRecords, false);
		//new CAJBP_TaskTriggerHandler(this.newRecords, this.oldRecords).handleAfterInsert();
	}
	/**
	 * @description handles after update trigger
	 */
	public void handleAfterUpdate() {
		new CAJBP_TaskTriggerHandler(this.newRecords, this.oldRecords).handleAfterUpdate();
	}
	/**
	 * @description handles after delete trigger
	 */
	public void handleAfterDelete() {
		new CAJBP_TaskTriggerHandler(this.newRecords, this.oldRecords).handleAfterDelete();
	}
}