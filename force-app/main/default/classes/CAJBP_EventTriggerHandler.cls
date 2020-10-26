/**
 * @author 			Jan Majling
 * @date 			03/10/2018
 * @group			CAJBP
 * @description		handles Event triggers for CAJBP project
 * 
 * history
 * 03/10/2018	Jan Majling			Created
 */
public with sharing class CAJBP_EventTriggerHandler {
	private final List<Event> newRecords;
	private final List<Event> oldRecords;

	/**
	 * @description constructor
	 * @param newRecords of type List<Event>
	 * @param oldRecords of type List<Event>
	 * @param newMap of type Map<Id,Event>
	 * @param oldMap of type Map<Id,Event>
	 */
	public CAJBP_EventTriggerHandler(List<Event> newRecords, List<Event> oldRecords) {
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