/**
 * @author			Jan Majling
 * @date			30/08/2018
 * @group			CAJBP
 * @description		acts as a proxy object for sharing
 *
 * history
 * 30/08/2018	Jan Majling			Created 
 */
public with sharing class CAJBP_SharedItem {
	public Id sharedRecordId;
	public Id userOrGroupId;
	public String sharingReason;
	public String accessLevel;
	public String triggerKey;
	public String errorMessage;

	/**
	 * @description gets share object with set attributes
	 * @return SObject
	 */
	public SObject getSharedObject() {
		String shareTypeName = this.getNameOfShareObject();
		SObject shareObject = Schema.getGlobalDescribe().get(shareTypeName).newSObject();
		shareObject.put('ParentId', this.sharedRecordId);
		shareObject.put('UserOrGroupId', this.userOrGroupId);
		shareObject.put('RowCause', this.sharingReason);
		shareObject.put('AccessLevel', this.accessLevel == 'Read/Write'? 'Edit' : 'Read');
		return shareObject;
	}

	/**
	 * @description gets name of the share object from Id
	 * @return String
	 */
	private String getNameOfShareObject() {
		String objectName = this.sharedRecordId.getSobjectType().getDescribe().getName();
		if(objectName.endsWith('__c')) {
			return objectName.replace('__c', '__Share');
		} else {
			return objectName + '__Share';
		}
	}
}