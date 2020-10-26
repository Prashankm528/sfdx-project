/**
 * @author			Jan Majling
 * @date 			21/08/2018
 * @group			CAJBP
 * @description		provides functions for sharing and permission sets handling, class must be used 
 * without sharing because 'Modify All' permission is required for the object when being shared via apex
 *
 * history
 * 21/08/2018	Jan Majling			Created 
 */
public without sharing class CAJBP_SharingService {
	/**
	 * @description grants access to the list of the provided sharing items
	 * @param sharedItems of type List<CAJBP_SharedItem>
	 * @return List<CAJBP_SharedItem>
	 */
	public List<CAJBP_SharedItem> grantAccess(List<CAJBP_SharedItem> sharedItems) {
		if(sharedItems.isEmpty()) {
			return sharedItems;
		}

		List<SObject> sharedObjectsToInsert = this.sharedItemsToSharedObjects(sharedItems);
		List<CAJBP_SharedItem> sharedItemsWithErrors = new List<CAJBP_SharedItem>();
		Database.SaveResult[] saveResults = Database.insert(sharedObjectsToInsert, false);
		Integer index = 0;
		for(Database.SaveResult saveResult : saveResults){
			if(saveResult.isSuccess()){
				index++;
				continue;
			}

			Database.Error error = saveResult.getErrors()[0];
			// Add an error when the error is not related to trivial access level.
			if(!(error.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && error.getMessage().contains('AccessLevel'))){
				system.debug(index);
				CAJBP_SharedItem sharedItemWithError = sharedItems.get(index);
				sharedItemWithError.errorMessage = Label.CAJBP_GrantAccessError + error.getMessage();
				sharedItemsWithErrors.add(sharedItemWithError);
			}
			index++;
		}

		return sharedItemsWithErrors;
	}

	/**
	 * @description revokes access to the provided list of shared items
	 * @param sharedItems of type List<CAJBP_SharedItem>
	 * @return List<CAJBP_SharedItem>
	 */
	public List<CAJBP_SharedItem> revokeAccess(List<CAJBP_SharedItem> sharedItems) {
		if(sharedItems.isEmpty()) {
			return sharedItems;
		}

		List<SObject> sharedObjectsToDelete = this.getShareObjectsToDelete(sharedItems);
		List<CAJBP_SharedItem> sharedItemsWithErrors = new List<CAJBP_SharedItem>();
		Database.DeleteResult[] deleteResults = Database.delete(sharedObjectsToDelete, false);
		Integer index = 0;
		for(Database.DeleteResult deleteResult : deleteResults){
			if(deleteResult.isSuccess()){
				index++;
				continue;
			}

			Database.Error error = deleteResult.getErrors()[0];
			CAJBP_SharedItem sharedItemWithError = sharedItems.get(index);
			sharedItemWithError.errorMessage = Label.CAJBP_RevokeAccessError + error.getMessage();
			sharedItemsWithErrors.add(sharedItemWithError);
			index++;
		}

		return sharedItemsWithErrors;
	}

	/**
	 * @description transforms shared items to shared objects
	 * @param shareTypeName of type String
	 * @param sharedItems of type List<CAJBP_SharedItem>
	 * @return List<SObject>
	 */
	private List<SObject> sharedItemsToSharedObjects(List<CAJBP_SharedItem> sharedItems) {
		List<SObject> sharedObjects = new List<SObject>();
		for(CAJBP_SharedItem sharedItem : sharedItems) {
			sharedObjects.add(sharedItem.getSharedObject());
		}
		return sharedObjects;
	}

	/**
	 * @description gets SOQL to get shares objects with Ids to be deleted
	 * @return String
	 */
	private List<SObject> getShareObjectsToDelete(List<CAJBP_SharedItem> sharedItems) {
		String conditionTemplate = '(ParentId = \'\'{0}\'\' AND UserOrGroupId = \'\'{1}\'\' AND AccessLevel = \'\'{2}\'\' AND RowCause = \'\'{3}\'\')';
		List<String> conditions = new List<String>();
		String shareTypeName;

		for(SObject shareObject : this.sharedItemsToSharedObjects(sharedItems)) {
			if(shareTypeName == null) {
				shareTypeName = shareObject.getSObjectType().getDescribe().getName();
			}
			List<String> arguments = new String[] {
				(String)shareObject.get('ParentId'),
				(String)shareObject.get('UserOrGroupId'),
				(String)shareObject.get('AccessLevel'),
				(String)shareObject.get('RowCause')
			};
			conditions.add(String.format(conditionTemplate, arguments));
		}

		return Database.query('SELECT Id FROM ' + shareTypeName + ' WHERE ' + String.join(conditions, ' OR '));
	}

	/**
	 * @description assigns the provided permission set to the provided user
	 * @param permissionSetId of type Id
	 * @param userStringIds of type String[]
	 */
	@future
	public static void assignPermissionSetToUsers(Id permissionSetId, String[] userStringIds) {
		List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
		for(String userStringId : userStringIds) {
			PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
				PermissionSetId = permissionSetId,
				AssigneeId = (ID)userStringId
			);
			permissionAssignments.add(permissionSetAssignment);
		}

		try {
			insert permissionAssignments;
		} catch(DMLException dmlException) {
			System.debug(dmlException.getMessage());
		}
	}

	/**
	 * @description revokes the provided permission set from the provided user
	 * @param permissionSetId of type Id
	 * @param userStringIds of type String[]
	 */
	@future
	public static void removePermissionSetFromUsers(Id permissionSetId, String[] userStringIds) {
		List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
		Set<Id> userIds = new Set<Id>();

		for(String userStringId : userStringIds) {
			userIds.add((ID)userStringId);
		}

		permissionAssignments = [
			SELECT Id FROM PermissionSetAssignment
			WHERE AssigneeId IN :userIds AND PermissionSetId = :permissionSetId
		];
		if(permissionAssignments.isEmpty()) {
			return;
		}

		try {
			delete permissionAssignments;
		} catch(DMLException dmlException) {
			System.debug(dmlException.getMessage());
		}
	}
}