/**
 * @author			Jan Majling
 * @date			27/08/2018
 * @group			CAJBP
 * @description		calculates total estimated and actual cost
 *
 * history
 * 27/08/2018	Jan Majling			Created 
 */
public with sharing class CAJBP_CalculateEstimateAndActualCost {

	private static final Schema.SObjectType JBP_ACTIVITY_OBJECT_TYPE = CAJBP_JBP_Activity__c.SObjectType;
	private static final Set<Id> ALLOWED_RECORD_TYPE_IDS = new Set<Id> {
		Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Event').getRecordTypeId(),
		Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CAJBP_JBP_Task').getRecordTypeId()
	};

	/**
	 * @description calculates total costs for affected activities from the provided records
	 * @param newRecords of type List<SObject>
	 */
	public void calculateActivityTotalCosts(List<SObject> records) {
		Map<Id, CAJBP_JBP_Activity__c> jbpActivitiesById = new Map<Id, CAJBP_JBP_Activity__c>();
		this.addJbpActivities(jbpActivitiesById, this.filterRecords(records));
		this.calculateActivityTotalCosts(jbpActivitiesById);
	}

	/**
	 * @description calculates total costs for activities from the provided records, new and old records must be
	 * processed in order to catch all affected activities
	 * @param newRecords of type List<SObject>
	 * @param oldRecords of type List<SObject>
	 */
	public void calculateActivityTotalCosts(List<SObject> newRecords, List<SObject> oldRecords) {
		Map<Id, CAJBP_JBP_Activity__c> jbpActivitiesById = new Map<Id, CAJBP_JBP_Activity__c>();
		this.addJbpActivities(jbpActivitiesById, this.filterRecords(newRecords));
		this.addJbpActivities(jbpActivitiesById, this.filterRecords(oldRecords));
		this.calculateActivityTotalCosts(jbpActivitiesById);
	}

	/**
	 * @description filters records to use only JBP Event and JBP Task
	 * @param records of type List<SObject>
	 * @return List<SObject>
	 */
	private List<SObject> filterRecords(List<SObject> records) {
		List<SObject> filteredRecords = new List<SObject>();
		for(SObject record : records) {
			if(ALLOWED_RECORD_TYPE_IDS.contains((Id)record.get('RecordTypeId'))) {
				filteredRecords.add(record);
			}
		}
		return filteredRecords;
	}

	/**
	 * @description gets JBP activities from the records and add them to the provided map
	 * @param jbpActivitiesById of type Map<Id, CAJBP_JBP_Activity__c>
	 * @param records of type List<SObject>
	 */
	private void addJbpActivities(Map<Id, CAJBP_JBP_Activity__c> jbpActivitiesById, List<SObject> records) {
		for(SObject record : records) {
			Id whatId = (Id)record.get('WhatId');
			if(this.isNotRelatedToJbpActivity(whatId) || jbpActivitiesById.get(whatId) != null) {
				continue;
			}
			CAJBP_JBP_Activity__c jbpActivity = new CAJBP_JBP_Activity__c(
				Id = whatId,
				CAJBP_Estimated_Cost__c = 0,
				CAJBP_Actual_Cost__c = 0
			);
			jbpActivitiesById.put(whatId, jbpActivity);
		}
	}

	/**
	 * @description calculates total estimate and actual costs for JBP activities from Tasks and Events
	 * @param jbpActivitiesById of type List<Map<Id, CAJBP_JBP_Activity__c>>
	 */
	private void calculateActivityTotalCosts(Map<Id, CAJBP_JBP_Activity__c> jbpActivitiesById) {
		if(jbpActivitiesById.isEmpty()) {
			return;
		}

		this.addTotalCostsToActivities(jbpActivitiesById, 'Task');
		this.addTotalCostsToActivities(jbpActivitiesById, 'Event');

		try {
			update jbpActivitiesById.values();
		} catch(DMLException dmlException) {
			System.debug(Label.CAJBP_Exception_occured + dmlException.getMessage());
		}
	}

	/**
	 * @description adds total costs of the provided object name to JBP activities
	 * @param jbpActivitiesById of type Map<Id, CAJBP_JBP_Activity__c>
	 * @param realatedObjectName of type String
	 */
	private void addTotalCostsToActivities(Map<Id, CAJBP_JBP_Activity__c> jbpActivitiesById, String realatedObjectName) {
		Set<Id> jbpAcitivityIds = jbpActivitiesById.keySet();
		String query = 
			'SELECT WhatId, SUM(CAJBP_Estimated_Cost__c) totalEstimateCost, SUM(CAJBP_Actual_Cost__c) totalActualCost ' +
			'FROM ' + realatedObjectName + ' ' +
			'WHERE What.Type = \'CAJBP_JBP_Activity__c\' AND WhatId IN :jbpAcitivityIds ' +
			'GROUP BY WhatId';
		List<AggregateResult> groupedResults;

		try {
			groupedResults = Database.query(query);
		} catch(DMLException dmlException) {
			System.debug(Label.CAJBP_Exception_occured + dmlException.getMessage());
			return;
		}

		for (AggregateResult result : groupedResults)  {
			CAJBP_JBP_Activity__c activity = jbpActivitiesById.get((Id)result.get('WhatId'));
			activity.CAJBP_Estimated_Cost__c = activity.CAJBP_Estimated_Cost__c
				+ this.resultValueToDecimal(result.get('totalEstimateCost'));
			activity.CAJBP_Actual_Cost__c = activity.CAJBP_Actual_Cost__c
				+ this.resultValueToDecimal(result.get('totalActualCost'));
		}
	}

	/**
	 * @description checks whether the provided Id is of CAJBP_JBP_Activity__c type
	 * @param whatId of type Id
	 * @return Boolean
	 */
	private Boolean isNotRelatedToJbpActivity(Id whatId) {
		return whatId == null || whatId.getSObjectType() != JBP_ACTIVITY_OBJECT_TYPE;
	}

	/**
	 * @description transforms result value to decimal
	 * @param resultValue of type Object
	 * @return Decimal
	 */
	private Decimal resultValueToDecimal(Object resultValue) {
		if(resultValue == null) {
			return 0;
		}
		return (Decimal)resultValue;
	}
}