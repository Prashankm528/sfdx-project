/***********************************************************************************************
* @author           Jessica
* @date             2020/06/30
* @group            CHCRM
* @description      handle Lead related business logic
* @Test Class       CHCRM_LeadTriggerHandlerTest
* history
* 2020/06/30  Jessica  Created
************************************************************************************************/
public with sharing class CHCRM_LeadProcess {

	public void leadAssignmentRule(List<Lead> newLeads) {

		Set<Id> geoIds = new Set<Id>();
        
		for (Lead leadObj : newLeads) {
			/*if (leadObj.CHCRM_City__c != null) {
				geoIds.add(leadObj.CHCRM_City__c);
			} else */
            if (leadObj.CHCRM_Province__c != null) {
				geoIds.add(leadObj.CHCRM_Province__c);
			}
		}

		List<CHCRM_Geography__c> geoList = [select Id, CHCRM_ILS_Lead_Owner__c from CHCRM_Geography__c where Id in :geoIds];
		Map<Id, CHCRM_Geography__c> geoMap = new Map<Id, CHCRM_Geography__c>(geoList);

		for (Lead leadObj : newLeads) {
			/*if (leadObj.CHCRM_City__c != null) {
				CHCRM_Geography__c geoObj = geoMap.get(leadObj.CHCRM_City__c);
				if (geoObj != null && geoObj.CHCRM_ILS_Lead_Owner__c != null) {
					leadObj.OwnerId = geoObj.CHCRM_ILS_Lead_Owner__c;
				}
			} else */
            if (leadObj.CHCRM_Province__c != null) {
				CHCRM_Geography__c geoObj = geoMap.get(leadObj.CHCRM_Province__c);
				if (geoObj != null && geoObj.CHCRM_ILS_Lead_Owner__c != null) {
					leadObj.OwnerId = geoObj.CHCRM_ILS_Lead_Owner__c;
				}
			}
		}
	}

	/*public void shareCreatorReadAccess(List<Lead> newLeads, Map<Id, Lead> oldMap, String operFlag) {

		List<LeadShare> leadSList = new List<LeadShare>();
		LeadShare leadSObj = new LeadShare();

		for (Lead leadObj : newLeads) {

			if (operFlag == 'afterUpdate') {
				Lead oldObj = oldMap.get(leadObj.Id);

				if (leadObj.OwnerId != oldObj.OwnerId) {
					leadSObj.LeadId = leadObj.Id;
					leadSObj.UserOrGroupId = oldObj.OwnerId;
					leadSObj.LeadAccessLevel = 'Read';
					leadSObj.RowCause = Schema.LeadShare.RowCause.Manual;
					leadSList.add(leadSObj);
				}
			} else if (operFlag == 'afterInsert') {
				if (leadObj.OwnerId != leadObj.CreatedById) {
					leadSObj.LeadId = leadObj.Id;
					leadSObj.UserOrGroupId = leadObj.CreatedById;
					leadSObj.LeadAccessLevel = 'Read';
					leadSObj.RowCause = Schema.LeadShare.RowCause.Manual;
					leadSList.add(leadSObj);
				}
			}
		}

		if (!leadSList.isEmpty()) {
			insert leadSList;
		}
	}*/

	public void createAddressInformation(List<Lead> newLeads) {
		List<CHCRM_Address_Information__c> addressInfoList = new List<CHCRM_Address_Information__c>();
		for (Lead l : newLeads) {
			if (String.isNotBlank(l.convertedAccountId)) {
				CHCRM_Address_Information__c addr = new CHCRM_Address_Information__c();
				addr.Name = 'Business Address';
				addr.CHCRM_Account__c = l.convertedAccountId;
				addr.CHCRM_City__c = l.CHCRM_City__c;
				addr.CHCRM_Province__c = l.CHCRM_Province__c;
				addr.RecordTypeId = Schema.SObjectType.CHCRM_Address_Information__c.getRecordTypeInfosByDeveloperName().get('CHCRM_Business_Address').getRecordTypeId();
				addressInfoList.add(addr);
			}
		}
		if (!addressInfoList.isEmpty()) {
			insert addressInfoList;
		}
	}
}