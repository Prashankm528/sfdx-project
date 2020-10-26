/* 
 * @author			Jan Majling
 * @date			11/09/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_RecordDetailsSection component
 *
 * history
 * 11/09/2018	Jan Majling			Created
 * 24/04/2020   Venkatesh Muniyasamy    Updated for the Scorecard Month update
*/
({
	/**
	 * Initializes data in component
	 */
	doInit : function(component, event, helper) {
		helper.loadRecordData(component);
		helper.setFields(component);
    },

    refreshRecordData: function(component,event,helper)
    {
        component.set('v.fieldsToRender','CAJBP_YTD_Month__c');

        component.set('v.showForm', false);
        setTimeout($A.getCallback(function() {
            helper.loadRecordData(component);
            helper.setFields(component);
        }),100);

        component.set('v.showForm', true);
    }
})