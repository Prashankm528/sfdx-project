/**
 * @author 			Jan Majling
 * @date 			25/07/2018
 * @group			CAJBP
 * @description     handles triggers of JBP object
 *
 * history
 * 25/07/2018	Jan Majling				Created
 * 25/08/2018	Jana Cechova			Added check to allow only one JBP In Progress or Draft
 * 18/09/2018	Jan Majling				Refactored handleBeforeUpsert, added docs
 * 03/10/2018	Jan Majling				Set records in constructor
 * 13/09/2019 	Venkatesh Muniyasamy	Added deletion logic
 * 27/01/2020   Abhinit Kohar			Added the afterUpdate logic
 * 06/02/2020   Abhinit Kohar			Updated the logic for allowOnlyOneJbpInDraftOrProgress to cater for year
 * 03/09/2020	Abhinit Kohar			Updated to share the Objectives, Risks and Customer Contact with the new JBP Owner and revoke access from the old JBP Owner.
 */
public with sharing class CAJBP_JbpTriggerHandler {
	private static final String STATE_IN_PROGRESS = 'In Progress';
	private static final String STATE_DRAFT = 'Draft';

	private final List<CAJBP_Joint_Business_Plan__c> newRecords;
	private final List<CAJBP_Joint_Business_Plan__c> oldRecords;
	private final Map<Id,CAJBP_Joint_Business_Plan__c> newMap;
	private final Map<Id,CAJBP_Joint_Business_Plan__c> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 * @param oldRecords of type List<CAJBP_Joint_Business_Plan__c>
	 * @param newMap of type Map<Id,CAJBP_Joint_Business_Plan__c>
	 * @param oldMap of type Map<Id,CAJBP_Joint_Business_Plan__c>
	 */
	public CAJBP_JbpTriggerHandler(List<CAJBP_Joint_Business_Plan__c> newRecords, List<CAJBP_Joint_Business_Plan__c> oldRecords, Map<Id,CAJBP_Joint_Business_Plan__c> newMap, Map<Id,CAJBP_Joint_Business_Plan__c> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}

	/**
	 * @description handles before insert and update trigger events
	 */
	public void handleBeforeUpsert() {
		this.setJbpName(this.newRecords);
		this.allowOnlyOneJbpInDraftOrProgress(this.newRecords);
	}
	/**
	 * @description handles after insert trigger event
	 */
	public void handleAfterInsert() {
		new CAJBP_JbpHelper().createScorecardRecord(this.newRecords);
	}
	public void handleBeforeDelete()
	{
		SObjectField jbpIdField =  Schema.CAJBP_Joint_Business_Plan__c.Fields.Id;
        CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(jbpIdField, (List<sObject>) this.oldRecords);
	}

	/**
	 * @description handles after update trigger event
	 */
	public void handleAfterUpdate() {
		CAJBP_UpdateRelatedJBPCurrency.updateRelatedJBPRecords(newRecords, oldRecords, newMap, oldMap);
		Set<Id> jbpIds = new Set<Id>();
		for(CAJBP_Joint_Business_Plan__c jbp : newMap.values()){
			if(jbp.OwnerId != oldMap.get(jbp.Id).OwnerId){
				jbpIds.add(jbp.Id);
			}
		}

		if(!jbpIds.isEmpty()){
			CAJBP_JbpSharing jbpSharing = new CAJBP_JbpSharing();
			jbpSharing.grantAccessAndRemoveAccessJBPOwner(jbpIds, oldMap);
			jbpSharing.grantAccessAndRemoveAccessJBPOwnerRisk(jbpIds, oldMap);
			jbpSharing.grantAccessAndRemoveAccessJBPOwnerCC(jbpIds, oldMap);
		}
	}

	/**
	 * @description allows only 1 JBP in progress or draft for the same year
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 */
	private void allowOnlyOneJbpInDraftOrProgress(List<CAJBP_Joint_Business_Plan__c> newRecords) {
		Set<Id> accountIds = new Set<Id>();
		Set<String> setYears = new set<String>();
		Set<Id> alreadyProcessed = new Set<Id>();

		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {

			 if (!alreadyProcessed.contains(jbp.id)) {
				alreadyProcessed.add(jbp.Id);

				setYears.add(jbp.CAJBP_Year__c);
				accountIds.add(jbp.CAJBP_Account__c);
			}
		}

		setYears.remove(null);
		accountIds.remove(null);

		if (setYears.isEmpty() || accountIds.isEmpty()) {
		    return ;
		}

        Map<String, Integer> accountToJbpsInSameYearMap = new Map<String, Integer>();

		for (AggregateResult ar  :[SELECT CAJBP_Account__c accID, count(Id) jbps, CAJBP_Year__c FROM CAJBP_Joint_Business_Plan__c
									   WHERE CAJBP_Account__c IN:accountIds
									   AND (CAJBP_State__c = :STATE_IN_PROGRESS OR CAJBP_State__c =: STATE_DRAFT)
									   AND CAJBP_Year__c IN: setYears AND ID NOT IN: alreadyProcessed
                                       GROUP by CAJBP_Account__c, CAJBP_Year__c
                                       HAVING count(Id) >= 1])
        {
            accountToJbpsInSameYearMap.put((Id)ar.get('accID') + String.valueOf(ar.get('CAJBP_Year__c')), integer.valueOf(ar.get('jbps')));
        }

        if (accountToJbpsInSameYearMap.isEmpty()) {
            return ;
        }

		for (CAJBP_Joint_Business_Plan__c jbp :newRecords) {

		    if (accountToJbpsInSameYearMap.containsKey(jbp.CAJBP_Account__c + jbp.CAJBP_Year__c)
		            && (jbp.CAJBP_State__c == STATE_IN_PROGRESS || jbp.CAJBP_State__c == STATE_DRAFT)) {

		        jbp.addError(Label.CAJBP_OnlyOneJbpInProgressOrDraftAllowed);
		    }
		}
	}
	/**
	 * @description sets name for JBPs
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 */
	private void setJbpName(List<CAJBP_Joint_Business_Plan__c> newRecords) {
		Set<Id> accountIds = new Set<Id>();
		Map<Id,Account> accounts;

		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {
			accountIds.add(jbp.CAJBP_Account__c);
		}
		accounts = new Map<Id,Account>(
			[SELECT Name, Type FROM Account WHERE Id IN :accountIds]
		);

		for (CAJBP_Joint_Business_Plan__c jbp : newRecords) {
			if(jbp.CAJBP_Account__c != null) {
				jbp.Name = CAJBP_JbpHelper.createName(
					jbp,
					accounts.get(jbp.CAJBP_Account__c)
				);
			}
		}
	}
}