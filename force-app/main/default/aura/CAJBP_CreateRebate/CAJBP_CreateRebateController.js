/* 
 * @author			Jan Majling
 * @date			09/08/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_CreateRebate component
 *
 * history
 * 09/08/2018	Jan Majling			Created
 * 24/07/2019	Venkatesh Muniyasamy	Modified to use the component as New Override Button
 * 04/10/2019 	Venkatesh Muniyasamy	Modified for new rebate wizard
*/
({
	/**
	 * Initalizes component
	 */
	doInit : function(component, event, helper) {
		helper.loadRecordTypes(component);
		helper.getScorecadId(component);
	},
	/**
	 * Closes modal window
	 */
	closeModal: function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	backRebate: function(component,event,helper)
	{
		component.set("v.showRebateWizard",false);
		component.set("v.selectRecordType",true);
		helper.calculationTypeChange(component);
	},
	/**
	 * Opens next step window
	 */
	nextStep: function(component, event, helper) {
		helper.createRecord(component);
	},
	rebateCreated: function (component,event)
	{
		$A.get("e.force:closeQuickAction").fire();
		$A.get('e.force:refreshView').fire();
	},
	targetTypeChanged: function(component,event,helper)
	{
		helper.calculationTypeChange(component);
	}
})