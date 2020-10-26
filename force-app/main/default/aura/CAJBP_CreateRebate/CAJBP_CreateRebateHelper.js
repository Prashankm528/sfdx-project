/* 
 * @author			Jan Majling
 * @date			09/08/2018
 * @group			CAJBP
 * @description		Helper functions for CAJBP_CreateRebate component
 *
 * history
 * 09/08/2018	Jan Majling			Created
 * 24/07/2019	Venkatesh Muniyasamy	Modified to use the component as New Override Button
 * 02/09/2019	Venkatesh Muniyasamy	Modified as part of Record Type changes
*/
({
	/**
	 * Loads record type
	 */
	loadRecordTypes: function(component) {
		component.find('LEX_Utils_Apex').callApex(component, 'c.getRecordTypesWithoutMaster', {}, this.setRecordTypes);
	},
	/**
	 * Saves record types into the component attribute
	 */
	setRecordTypes: function(component, returnValue, params) {
		component.set('v.rebateRecordTypesById', returnValue);
	},

	getScorecadId: function(component)
	{
		component.find('LEX_Utils_Apex').callApex(component, 'c.getScorecardId', {recordId:component.get('v.recordId')}, this.setScorecardId);
	},
	/**To get the ScoreCard Id for the Rebate record */
	setScorecardId: function(component, returnValue, params) {
        component.set('v.scoreCardId', returnValue.CAJBP_Scorecards__r[0].Id);
        component.set('v.currencyId', returnValue.CurrencyIsoCode);
	},
	/**
	 * Fires up force event create record and redirects users back to the current page after saving the form
	 */
	createRecord: function(component) {
		component.set("v.recordTypeId", this.getRecordTypeId(component));
		/**var location = window.location.href;
		$A.get("e.force:closeQuickAction").fire();
		var createRecordEvent = $A.get('e.force:createRecord');
		createRecordEvent.setParams({
			'entityApiName': 'CAJBP_Rebate__c',
            'recordTypeId': this.getRecordTypeId(component),
			'defaultFieldValues': {
				'CAJBP_Scorecard__c': component.get('v.scoreCardId')
			},
			'navigationLocation': 'LOOKUP',
			'panelOnDestroyCallback': function(event) {
				$A.get("e.force:closeQuickAction").fire();
			}
		});
		createRecordEvent.fire();*/
		component.set("v.showRebateWizard",true);
		component.set("v.selectRecordType",false);
	},
	navigateToJBPHome: function()
	{
		console.log('NavigateToJBPHome');
		var jbpHome = $A.get("e.force:navigateToSObject");
		jbpHome.setParams({recordId:component.get("v.recordId"),slideDevName: "Scorecard"});
		jbpHome.fire();
	},
	/**
	 * Gets record type Id
	 */
	getRecordTypeId: function(component) {
		//var targetCalculationValue = component.get('v.targetCalculationType');
		//var targetCalculation = targetCalculationValue.split('_');
		var searchValues = [
			component.get('v.targetType'),
			component.get('v.calculationType'),
			component.get('v.sellType').replace('-','_'),
			component.get('v.rebateType')
		];
		component.set('v.recordTypeValues', component.get('v.targetType') +','+ component.get('v.calculationType') +','+component.get('v.rebateType') );
		console.log('searchValues ' + component.get('v.recordTypeValues'));
		var searchValuesCount = searchValues.length;
		var regExpression = new RegExp('(' + searchValues.join('|') + ')', 'gi');
		var recordTypesById = component.get('v.rebateRecordTypesById');
		var recordTypeIds = Object.keys(recordTypesById);
		var recordTypeIdsCount = recordTypeIds.length;

		for (var i = 0; i < recordTypeIdsCount; ++i) {
			var recordTypeId = recordTypeIds[i];
			var matches = recordTypesById[recordTypeId].match(regExpression);
			if(matches && matches.length == searchValuesCount) {
				return recordTypeId;
			}
		}
		return;
	},
	calculationTypeChange: function(component)
	{
		var targetTypeSelected = component.get("v.targetType");
		var calculationType = component.find("radioGroupCalculationTypeId");
		if(targetTypeSelected == 'Turnover')
		{
			calculationType.set("v.value","Percentage");
			calculationType.set("v.disabled",true);
		}
		else
		{
			calculationType.set("v.disabled",false);
		}
	}
})