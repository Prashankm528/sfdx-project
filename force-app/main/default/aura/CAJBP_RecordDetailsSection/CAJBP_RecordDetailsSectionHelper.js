/* 
 * @author			Jan Majling
 * @date			11/09/2018
 * @group			CAJBP
 * @description		Helper functions for CAJBP_RecordDetailsSection component
 *
 * history
 * 11/09/2018	Jan Majling			Created
*/
({
	/**
	 * Loads data of the record
	 */
	loadRecordData: function(component) {
		component.find('LEX_Utils_Apex').callApex(
			component,
			'c.getRecordData',
			{
				'recordId': component.get('v.recordId'),
				'relationshipName': component.get('v.relationshipName')
			},
			this.setRecordData
		);
	},
	/**
	 * Sets record data attributes
	 */
	setRecordData: function(component, returnValue, params) {
		component.set('v.recordDataId', returnValue.recordId);
		component.set('v.recordDataObjectName', returnValue.recordObjectName);
	},
	/**
	 * Splits fields attribute into array of single fields for rendering
	 */
	setFields: function(component) {
		var fields = component.get('v.fields');
		if(fields) { 
			component.set('v.fieldsToRender', fields.trim().replace(' ','').split(','));
		}
	}
})