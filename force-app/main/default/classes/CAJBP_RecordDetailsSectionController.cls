/**
 * @author			Jan Majling
 * @date			10/09/2018
 * @group			CAJBP
 * @description		controller for lightning component CAJBP_RecordDetailsSection
 *
 * history
 * 10/09/2018	Jan Majling			Created 
 */
public with sharing class CAJBP_RecordDetailsSectionController {
	/**
	 * @description Record Data inner class
	 */
	public class RecordData {
		@AuraEnabled
		public Id recordId;
		@AuraEnabled
		public String recordObjectName;
	}

	/**
	 * @description gets data for lightning component
	 * @param recordId of type Id
	 * @param relationshipName of type String
	 * @return RecordData
	 */
	@AuraEnabled
	public static RecordData getRecordData(Id recordId, String relationshipName) {
		RecordData recordData = CAJBP_RecordDetailsSectionController.getRecordDataFromId(recordId);
		if(relationshipName == null) {
			return recordData;
		}

		List<SObject> records;
		try{
			records = Database.query(
				'SELECT Id, (SELECT Id FROM ' + relationshipName + ') FROM ' + recordData.recordObjectName + ' WHERE Id = :recordId'
			);	
		} catch(QueryException e) {
			throw new AuraHandledException(e.getMessage());
		}

		List<SObject> children = records.get(0).getSObjects(relationshipName);
		if(children == null) {
			throw new AuraHandledException(
				String.format(Label.CAJBP_MissingChild,
					new List<String>{
						recordData.recordObjectName,
						relationshipName
					}
				)
			);
		}

		return CAJBP_RecordDetailsSectionController.getRecordDataFromId((Id)children.get(0).get('Id'));
	}

	private static RecordData getRecordDataFromId(Id recordId) {
		RecordData recordData = new RecordData();
		recordData.recordId = recordId;
		recordData.recordObjectName = recordId.getSobjectType().getDescribe().getName();

		return recordData;
	}
}