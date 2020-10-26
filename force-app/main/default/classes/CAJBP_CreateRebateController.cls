/**
 * @author			Jan Majling
 * @date			07/09/2018
 * @group			CAJBP
 * @description		controller for lightning component CAJBP_CreateRebate
 *
 * history
 * 07/09/2018	Jan Majling				Created 
 * 24/07/2019	Venkatesh Muniyasamy	Modified to retrieve ScorecardId
 * 06/02/2019   Venkatesh Muniyasamy    Modified the component for JBP Currency Assigment and reformating
 */
public with sharing class CAJBP_CreateRebateController {
	/**
	 * @description gets map of CAJBP_Rebate__c record types except master record type
	 * @return Map<Id,String>
	 */
	@AuraEnabled
	public static Map<Id,String> getRecordTypesWithoutMaster() {
		Map<Id,String> recordTypesById = new Map<Id,String>();
		Map<Id,Schema.RecordTypeInfo> recordTypeInfosById = CAJBP_Rebate__c.SObjectType.getDescribe().getRecordTypeInfosById(); 
		for(Id recordTypeId : recordTypeInfosById.keySet()) {
			RecordTypeInfo recordTypeInfo = recordTypeInfosById.get(recordTypeId);
			if(recordTypeInfo.isMaster()) {
				continue;
			}
			recordTypesById.put(recordTypeId, recordTypeInfo.getDeveloperName());
		}
		return recordTypesById;
	}
	@AuraEnabled
	public static CAJBP_Joint_Business_Plan__c getScorecardId(Id recordId) {
		ID Id;
		CAJBP_Joint_Business_Plan__c jbp = [SELECT Id, CurrencyIsoCode, (SELECT Id from CAJBP_Scorecards__r) from CAJBP_Joint_Business_Plan__c WHERE id=:recordId limit 1];
		for(CAJBP_Scorecard__c scoreCard : jbp.CAJBP_Scorecards__r)
		{
			Id=scoreCard.Id;
		}
		return jbp;
	}
}