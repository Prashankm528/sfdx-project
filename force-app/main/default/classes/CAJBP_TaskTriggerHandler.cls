/**
 * @author 			Jan Majling
 * @date 			03/10/2018
 * @group			CAJBP
 * @description		handles Task triggers for CAJBP project
 * 
 * history
 * 03/10/2018	Jan Majling			Created
 */
public with sharing class CAJBP_TaskTriggerHandler {
	private final List<Task> newRecords;
	private final List<Task> oldRecords;

	/**
	 * @description constructor
	 * @param newRecords of type List<Task>
	 * @param oldRecords of type List<Task>
	 * @param newMap of type Map<Id,Task>
	 * @param oldMap of type Map<Id,Task>
	 */
	public CAJBP_TaskTriggerHandler(List<Task> newRecords, List<Task> oldRecords) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
	}
	/**
	 * @description handles after insert trigger
	 */
	public void handleAfterInsert() {
		new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(this.newRecords);
	}
	/**
	 * @description handles after update trigger
	 */
	public void handleAfterUpdate() {
		new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(this.newRecords, this.oldRecords);
	}
	/**
	 * @description handles after delete trigger
	 */
	public void handleAfterDelete() {
		new CAJBP_CalculateEstimateAndActualCost().calculateActivityTotalCosts(this.oldRecords); 
	}
}