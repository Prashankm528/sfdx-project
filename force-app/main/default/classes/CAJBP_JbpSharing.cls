/**
 * @author 			Jan Majling
 * @date 			17/08/2018
 * @group			CAJBP
 * @description		handles sharing for CAJBP_Joint_Business_Plan__c object and its related objects
 * 
 * history
 * 17/08/2018	Jan Majling			    Created 
 * 18/06/2020	Venkatesh Muniyasamy	Updated for Risk Sharing
 * 03/09/2020	Abhinit Kohar			Updated to share the Objectives, Risks and Customer Contact with the new JBP Owner and revoke access from the old JBP Owner.
 */
public with sharing class CAJBP_JbpSharing {
    private final String SHARING_REASON = 'Sharing_To_JBP_Team_Member__c';//Schema.CAJBP_Joint_Business_Plan__Share.RowCause.Sharing_To_JBP_Team_Member__c;
    private final String SHARING_OWNER_OBJECTIVE_REASON = 'Sharing_To_JBP_Owner__c';//Schema.CAJBP_Objective__Share.RowCause.Sharing_To_JBP_Owner__c;
    private final String SHARING_OWNER_RISK_REASON = 'Sharing_To_JBP_Owner__c';//Schema.CAJBP_Risk__Share.RowCause.Sharing_To_JBP_Owner__c;
    private final String SHARING_OWNER_CUSTOMER_CONTACT_REASON = 'Sharing_To_JBP_Owner__c';//Schema.CAJBP_Customer_Contact__Share.RowCause.Sharing_To_JBP_Owner__c;
	private final String PERMISSION_SET_CAJBP_USER_NAME = 'CAJBP_Standard_User';
	private String actionType;
	private String permissionSetId;
	private List<CAJBP_JBP_Team_Member__c> teamMembers;
	private Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp;
	private Boolean isTriggeredByRelatedRecords;
	/**
	 * @description adds access to JBPs for the provided team members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void grantAccess(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		this.actionType = 'Grant';
		this.isTriggeredByRelatedRecords = false;
		this.teamMembers = teamMembers;
		processRecords();
		//this.addPermissionSet();
	}

	/**
	 * @description revokes access to JBPs from the provided team members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void revokeAccess(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		this.actionType = 'Revoke';
		this.isTriggeredByRelatedRecords = false;
		this.teamMembers = teamMembers;
		processRecords();
		//this.removePermissionSet();
	}

	/**
	 * @description processes JBP records and related records
	 */
	private void processRecords() {
		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp = this.getTeamMembersByJbp();

		this.setAccessToRecords(this.teamMembersByJbp, this.teamMembers);

		List<CAJBP_Objective__c> objectives = [
			SELECT CAJBP_Joint_Business_Plan__c
			FROM CAJBP_Objective__c
			WHERE CAJBP_Joint_Business_Plan__c IN :teamMembersByJbp.keySet()
        ];

        List<CAJBP_Risk__c> risks = [
			SELECT CAJBP_Joint_Business_Plan__c
			FROM CAJBP_Risk__c
			WHERE CAJBP_Joint_Business_Plan__c IN :teamMembersByJbp.keySet()
        ];

        List<CAJBP_Customer_Contact__c> customerContact = [
			SELECT CAJBP_Joint_Business_Plan__c
			FROM CAJBP_Customer_Contact__c
			WHERE CAJBP_Joint_Business_Plan__c IN :teamMembersByJbp.keySet()
        ];

        this.processRelatedRecords(risks);

        this.processRelatedRecords(objectives);

        this.processRelatedRecords(customerContact);
	}

	/**
	 * @description grant access to related records
	 * @param relatedRecords of type List<SObject>
	 */
	public void grantAccessToRelatedRecords(List<SObject> relatedRecords) {
		this.actionType = 'Grant';
		this.isTriggeredByRelatedRecords = true;
		processRelatedRecords(relatedRecords);
	}

	/**
	 * @description revoke access to related records
	 * @param relatedRecords of type List<SObject>
	 */
	public void revokeAccessToRelatedRecords(List<SObject> relatedRecords) {
		this.actionType = 'Revoke';
		this.isTriggeredByRelatedRecords = true;
		processRelatedRecords(relatedRecords);
	}

	/**
	 * @description adds CAJBP standard user permission set to the provided team members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>>
	 */
/*	public void addPermissionSet() {
		Id permissionSetId = this.getPermissionSetId();
		List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
		Set<Id> userIds = new Set<Id>();
		List<User> usersWithoutPermission;
		List<String> userStringIds;

		for(CAJBP_JBP_Team_Member__c teamMember : this.teamMembers) {
			userIds.add(teamMember.CAJBP_User__c);
		}

		usersWithoutPermission = [
			SELECT Id
			FROM User
			WHERE Id IN :userIds AND Id NOT IN (
				SELECT AssigneeId
				FROM PermissionSetAssignment
				WHERE PermissionSetId = :permissionSetId
			)
		];
		if(usersWithoutPermission.isEmpty()) {
			return;
		}

		userStringIds = new List<String>();
		for(User user : usersWithoutPermission) {
			userStringIds.add(user.Id);
		}
		CAJBP_SharingService.assignPermissionSetToUsers(permissionSetId, userStringIds);
	}*/

	/**
	 * @description revokes CAJBP standard user permission set from the provided team members
	 */
/*	public void removePermissionSet() {
		Set<Id> userIds = new Set<Id>();

		for(CAJBP_JBP_Team_Member__c teamMember : this.teamMembers) {
			userIds.add(teamMember.CAJBP_User__c);
		}
		List<User> usersToRemove = [
			SELECT Id
			FROM User
			WHERE Id IN :userIds AND Id NOT IN (
				SELECT CAJBP_User__c
				FROM CAJBP_JBP_Team_Member__c
			)
		];
		if(usersToRemove.isEmpty()) {
			return;
		}

		Id permissionSetId = this.getPermissionSetId();
		List<String> userToRemoveStringIds = new List<String>();
		for(User user : usersToRemove ) {
			userToRemoveStringIds.add(user.Id);
		}
		CAJBP_SharingService.removePermissionSetFromUsers(permissionSetId, userToRemoveStringIds);
	}*/

	/**
	 * @description gets Id of CAJBP standard permission set
	 * @return Id
	 */
/*	public Id getPermissionSetId() {
		if(this.permissionSetId != null ) {
			return this.permissionSetId;
		}
		List<PermissionSet> permissionSets = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = :PERMISSION_SET_CAJBP_USER_NAME
			LIMIT 1
		];
		this.permissionSetId = permissionSets.get(0).Id;
		return this.permissionSetId;
	}*/

	/**
	 * @description processes related records
	 * @param relatedRecords of type List<SObject>
	 */
	private void processRelatedRecords(List<SObject> relatedRecords) {
		if(relatedRecords.isEmpty()) {
			return;
		}

		String objectName = relatedRecords.get(0).getSObjectType().getDescribe().getName();
		String relationshipFieldName = this.getNameOfRelationshipField(objectName);

		List<CAJBP_JBP_Team_Member__c> teamMembers = this.getTeamMembersFromRelatedRecords(relatedRecords, relationshipFieldName);
		if(teamMembers.isEmpty()) {
			return;
		}
		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp = this.getTeamMembersByJbp();
		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByRelatedRecord = new Map<Id,List<CAJBP_JBP_Team_Member__c>>();
		for(SObject record : relatedRecords) {
			teamMembersByRelatedRecord.put(
				record.Id,
				teamMembersByJbp.get((Id)record.get(relationshipFieldName))
			);
		}
		List<SObject> triggerRecords = this.isTriggeredByRelatedRecords ? relatedRecords : teamMembers;
		this.setAccessToRecords(teamMembersByRelatedRecord,	triggerRecords);
	}

	/**
	 * @description gets a list of team members from related records
	 * @param relatedRecords of type List<SObject>
	 * @param relationshipFieldName of type String
	 * @return List<CAJBP_JBP_Team_Member__c>
	 */
	private List<CAJBP_JBP_Team_Member__c> getTeamMembersFromRelatedRecords(List<SObject> relatedRecords, String relationshipFieldName) {
		if(this.teamMembers != null) {
			return this.teamMembers;
		}
		Set<Id> jbpIds = new Set<Id>();
		for(SObject record : relatedRecords) {
			jbpIds.add((Id)record.get(relationshipFieldName));
		}
		List<CAJBP_JBP_Team_Member__c> teamMembers = [
			SELECT CAJBP_Joint_Business_Plan__c, CAJBP_User__c, CAJBP_Access__c
			FROM CAJBP_JBP_Team_Member__c
			WHERE CAJBP_Joint_Business_Plan__c IN :jbpIds
		];
		this.teamMembers = teamMembers;
		return teamMembers;
	}

	/**
	 * @description gets name of the field referencing to CAJBP_Joint_Business_Plan__c
	 * @param objectName of type String
	 * @return String
	 */
	private String getNameOfRelationshipField(String objectName) {
		SObjectType SObjectType = Schema.getGlobalDescribe().get(objectName);
		Schema.SObjectType jbpType = CAJBP_Joint_Business_Plan__c.SObjectType;

		for(Schema.SObjectField field : SObjectType.getDescribe().fields.getMap().values()) {
			Schema.DescribeFieldResult fieldResult = field.getDescribe();
			List<Schema.SObjectType> referencedToList = fieldResult.getReferenceTo();
			if(!referencedToList.isEmpty() && referencedToList.get(0) == jbpType) {
				return fieldResult.getName();
			}
		}

		return '';
	}

	/**
	 * @description sets access to the provided records
	 * @param teamMembersBySharedRecord of type Map<Id,List<CAJBP_JBP_Team_Member__c>>
	 * @param triggerRecords of type List<SObject>
	 */
	private void setAccessToRecords(Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersBySharedRecord, List<SObject> triggerRecords) {
		List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();
		for(Id sharedRecordId : teamMembersBySharedRecord.keySet()) {
			for(CAJBP_JBP_Team_Member__c teamMember : teamMembersBySharedRecord.get(sharedRecordId)){
				CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
				sharedItem.sharedRecordId = sharedRecordId;
				sharedItem.userOrGroupId = teamMember.CAJBP_User__c;
				sharedItem.sharingReason = SHARING_REASON;
				sharedItem.accessLevel = teamMember.CAJBP_Access__c;
				sharedItem.triggerKey = this.isTriggeredByRelatedRecords ? (String)sharedRecordId : teamMember.CAJBP_Unique_Key__c;
				sharedItems.add(sharedItem);
			}
		}
		CAJBP_SharingService sharingService = new CAJBP_SharingService();
		List<CAJBP_SharedItem> sharedItemsWithErrors;

		if(this.actionType == 'Grant') {
			sharedItemsWithErrors = sharingService.grantAccess(sharedItems);
		} else if(this.actionType == 'Revoke') {
			sharedItemsWithErrors = sharingService.revokeAccess(sharedItems);
		}

		this.processErrors(sharedItemsWithErrors, triggerRecords);
	}

	/**
	 * @description creates a map of team members grouped by Joint Business Plan Id
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 * @return Map<Id,List<CAJBP_JBP_Team_Member__c>>
	 */
	public Map<Id,List<CAJBP_JBP_Team_Member__c>> getTeamMembersByJbp() {
		if(this.teamMembersByJbp != null) {
			return this.teamMembersByJbp;
		}

		Map<Id,List<CAJBP_JBP_Team_Member__c>> teamMembersByJbp = new Map<Id,List<CAJBP_JBP_Team_Member__c>>();
		for(CAJBP_JBP_Team_Member__c teamMember : this.teamMembers) {
			List<CAJBP_JBP_Team_Member__c> subList = teamMembersByJbp.get(teamMember.CAJBP_Joint_Business_Plan__c);
			if (subList == null) {
				subList = new List<CAJBP_JBP_Team_Member__c>();
				teamMembersByJbp.put(teamMember.CAJBP_Joint_Business_Plan__c, subList);
			}
			subList.add(teamMember);
		}

		this.teamMembersByJbp = teamMembersByJbp;
		return teamMembersByJbp;
	}

	/**
	 * @description processes errors
	 * @param sharedItemsWithErrors of type List<CAJBP_SharedItem>
	 * @param triggerRecords of type List<SObject>
	 */
	private void processErrors(List<CAJBP_SharedItem> sharedItemsWithErrors, List<SObject> triggerRecords) {
		if(sharedItemsWithErrors.isEmpty()) {
			return;
		}

		Map<String,SObject> triggerRecordsByKey = new Map<String,SObject>();
		for(SObject triggerRecord : triggerRecords) {
			if(this.isTriggeredByRelatedRecords) {
				triggerRecordsByKey.put(
					(String)triggerRecord.get('Id'),
					triggerRecord
				);
			} else {
				triggerRecordsByKey.put(
					(String)triggerRecord.get('CAJBP_Unique_Key__c'),
					triggerRecord
				);
			}	
		}

		for(CAJBP_SharedItem sharedItemWithError : sharedItemsWithErrors) {
			SObject failedRecord = triggerRecordsByKey.get(sharedItemWithError.triggerKey);
			failedRecord.addError(sharedItemWithError.errorMessage);
		}
	}
    //Share objective records to JBP Owner
    public void shareObjectivesToJBPOwner(List<CAJBP_Objective__c> objectiveList){

        List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();
        for(CAJBP_Objective__c objective : [Select CAJBP_Joint_Business_Plan__r.OwnerId, CreatedById 
                                         From CAJBP_Objective__c Where Id IN :objectiveList]){

            if(objective.CAJBP_Joint_Business_Plan__r.OwnerId != objective.CreatedById){
                CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
				sharedItem.sharedRecordId = objective.Id;  
				sharedItem.userOrGroupId = objective.CAJBP_Joint_Business_Plan__r.OwnerId;
				sharedItem.sharingReason = SHARING_OWNER_OBJECTIVE_REASON;
				sharedItem.accessLevel = 'Read/Write';
				sharedItem.triggerKey = (String)objective.Id;
				sharedItems.add(sharedItem);
            }
        }

        if(!sharedItems.isEmpty()){
            CAJBP_SharingService sharingService = new CAJBP_SharingService();
            sharingService.grantAccess(sharedItems);
        }
    }

     //Share Risk records to JBP Owner
    public void shareRisksToJBPOwner(List<CAJBP_Risk__c> riskList){

        List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();

        for(CAJBP_Risk__c risk : [Select CAJBP_Joint_Business_Plan__r.OwnerId, CreatedById 
                                         From CAJBP_Risk__c Where Id IN :riskList]){

            if(risk.CAJBP_Joint_Business_Plan__r.OwnerId != risk.CreatedById){
                CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
				sharedItem.sharedRecordId = risk.Id;
				sharedItem.userOrGroupId = risk.CAJBP_Joint_Business_Plan__r.OwnerId;
				sharedItem.sharingReason = SHARING_OWNER_RISK_REASON;
				sharedItem.accessLevel = 'Read/Write';
				sharedItem.triggerKey = (String)risk.Id;
				sharedItems.add(sharedItem);
            }
        }

        if(!sharedItems.isEmpty()){
            CAJBP_SharingService sharingService = new CAJBP_SharingService();
            sharingService.grantAccess(sharedItems);
        }
    }

    public void shareCustomerContactToJBPOwner(List<CAJBP_Customer_Contact__c> customers)
    {
        List<CAJBP_SharedItem> sharedItems = new List<CAJBP_SharedItem>();

        for(CAJBP_Customer_Contact__c customer : [Select CAJBP_Joint_Business_Plan__r.OwnerId, CreatedById
                                         From CAJBP_Customer_Contact__c Where Id IN :customers]){
            if(customer.CAJBP_Joint_Business_Plan__r.OwnerId != customer.CreatedById){
                CAJBP_SharedItem sharedItem = new CAJBP_SharedItem();
				sharedItem.sharedRecordId = customer.Id;
				sharedItem.userOrGroupId = customer.CAJBP_Joint_Business_Plan__r.OwnerId;
				sharedItem.sharingReason = SHARING_OWNER_CUSTOMER_CONTACT_REASON;
				sharedItem.accessLevel = 'Read/Write';
				sharedItem.triggerKey = (String)customer.Id;
				sharedItems.add(sharedItem);
            }
        }

        if(!sharedItems.isEmpty()){
            CAJBP_SharingService sharingService = new CAJBP_SharingService();
            sharingService.grantAccess(sharedItems);
        }
    }

	//This method grants access to new Owner of JBP to Objectives and removes the access of the old Owner of JBP.
	public void grantAccessAndRemoveAccessJBPOwner(Set<Id> jbpIds, Map<Id, CAJBP_Joint_Business_Plan__c> oldMap){
		List<CAJBP_SharedItem> sharedItemsGrantAccess = new List<CAJBP_SharedItem>();
		List<CAJBP_SharedItem> sharedItemsRevokeAccess = new List<CAJBP_SharedItem>();

		for(CAJBP_Objective__c objective : [Select CAJBP_Joint_Business_Plan__c, CAJBP_Joint_Business_Plan__r.OwnerId, CreatedById From CAJBP_Objective__c Where CAJBP_Joint_Business_Plan__c in :jbpIds]){
			if(objective.CAJBP_Joint_Business_Plan__r.OwnerId != objective.CreatedById){
				CAJBP_SharedItem sharedItemObj = new CAJBP_SharedItem();
				sharedItemObj = populateSharedItem(sharedItemObj, objective);
				sharedItemObj.userOrGroupId = objective.CAJBP_Joint_Business_Plan__r.OwnerId;
				sharedItemsGrantAccess.add(sharedItemObj);

				CAJBP_SharedItem sharedItemObjRevoke = new CAJBP_SharedItem();
				sharedItemObjRevoke = populateSharedItem(sharedItemObjRevoke, objective);
				sharedItemObjRevoke.userOrGroupId = oldMap.get(objective.CAJBP_Joint_Business_Plan__c).OwnerId;
				sharedItemsRevokeAccess.add(sharedItemObjRevoke);
			}
		}

		if(!sharedItemsGrantAccess.isEmpty()) {
			CAJBP_SharingService sharingService = new CAJBP_SharingService();
			sharingService.grantAccess(sharedItemsGrantAccess);
		}
		if(!sharedItemsRevokeAccess.isEmpty()) {
			CAJBP_SharingService sharingServiceRevoke = new CAJBP_SharingService();
			sharingServiceRevoke.revokeAccess(sharedItemsRevokeAccess);
		}
	}

	//This method grants access to new Owner of JBP to Risks and removes the access of the old Owner of JBP.
	public void grantAccessAndRemoveAccessJBPOwnerRisk(Set<Id> jbpIds, Map<Id, CAJBP_Joint_Business_Plan__c> oldMap){
		List<CAJBP_SharedItem> sharedItemsGrantAccess = new List<CAJBP_SharedItem>();
		List<CAJBP_SharedItem> sharedItemsRevokeAccess = new List<CAJBP_SharedItem>();

		for(CAJBP_Risk__c risk : [Select CAJBP_Joint_Business_Plan__r.OwnerId, CreatedById From CAJBP_Risk__c Where CAJBP_Joint_Business_Plan__c in :jbpIds]) {

			if (risk.CAJBP_Joint_Business_Plan__r.OwnerId != risk.CreatedById) {
				CAJBP_SharedItem sharedItemRisk = new CAJBP_SharedItem();
				sharedItemRisk = populateSharedItem(sharedItemRisk, risk);
				sharedItemRisk.userOrGroupId = risk.CAJBP_Joint_Business_Plan__r.OwnerId;
				sharedItemsGrantAccess.add(sharedItemRisk);

				CAJBP_SharedItem sharedItemRiskRevoke = new CAJBP_SharedItem();
				sharedItemRiskRevoke = populateSharedItem(sharedItemRiskRevoke, risk);
				sharedItemRiskRevoke.userOrGroupId = oldMap.get(risk.CAJBP_Joint_Business_Plan__c).OwnerId;
				sharedItemsRevokeAccess.add(sharedItemRiskRevoke);
			}
		}

		if(!sharedItemsGrantAccess.isEmpty()) {
			CAJBP_SharingService sharingService = new CAJBP_SharingService();
			sharingService.grantAccess(sharedItemsGrantAccess);
		}
		if(!sharedItemsRevokeAccess.isEmpty()) {
			CAJBP_SharingService sharingServiceRevoke = new CAJBP_SharingService();
			sharingServiceRevoke.revokeAccess(sharedItemsRevokeAccess);
		}
	}

	//This method grants access to new Owner of JBP to Customer Contacts and removes the access of the old Owner of JBP.
	public void grantAccessAndRemoveAccessJBPOwnerCC(Set<Id> jbpIds, Map<Id, CAJBP_Joint_Business_Plan__c> oldMap){
		List<CAJBP_SharedItem> sharedItemsGrantAccess = new List<CAJBP_SharedItem>();
		List<CAJBP_SharedItem> sharedItemsRevokeAccess = new List<CAJBP_SharedItem>();

		for(CAJBP_Customer_Contact__c customer : [Select CAJBP_Joint_Business_Plan__r.OwnerId, CreatedById From CAJBP_Customer_Contact__c Where CAJBP_Joint_Business_Plan__c in :jbpIds]){

			if(customer.CAJBP_Joint_Business_Plan__r.OwnerId != customer.CreatedById){
				CAJBP_SharedItem sharedItemCC = new CAJBP_SharedItem();
				sharedItemCC = populateSharedItem(sharedItemCC, customer);
				sharedItemCC.userOrGroupId = customer.CAJBP_Joint_Business_Plan__r.OwnerId;
				sharedItemsGrantAccess.add(sharedItemCC);

				CAJBP_SharedItem sharedItemCCRevoke = new CAJBP_SharedItem();
				sharedItemCCRevoke = populateSharedItem(sharedItemCCRevoke, customer);
				sharedItemCCRevoke.userOrGroupId = oldMap.get(customer.CAJBP_Joint_Business_Plan__c).OwnerId;
				sharedItemsRevokeAccess.add(sharedItemCCRevoke);
			}
		}

		if(!sharedItemsGrantAccess.isEmpty()) {
			CAJBP_SharingService sharingService = new CAJBP_SharingService();
			sharingService.grantAccess(sharedItemsGrantAccess);
		}
		if(!sharedItemsRevokeAccess.isEmpty()) {
			CAJBP_SharingService sharingServiceRevoke = new CAJBP_SharingService();
			sharingServiceRevoke.revokeAccess(sharedItemsRevokeAccess);
		}
	}

	private CAJBP_SharedItem populateSharedItem(CAJBP_SharedItem sharedItem, sObject obj){
		String objectName = obj.getSObjectType().getDescribe().getName();
		sharedItem.sharedRecordId = obj.Id;
		sharedItem.sharingReason = SHARING_OWNER_OBJECTIVE_REASON;
		sharedItem.accessLevel = 'Read/Write';
		sharedItem.triggerKey = (String)obj.Id;
		return sharedItem;
	}
}