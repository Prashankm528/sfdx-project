/* 
 * @author			Jan Majling
 * @date			09/09/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_CollapsibleSection component
 *
 * history
 * 09/09/2018	Jan Majling			Created
*/
({
	/**
	 * Handles click on section header
	 */
	handleSectionHeaderClick : function(component, event, helper) {
		var button = event.getSource();
		button.set('v.state', !button.get('v.state'));

		var sectionContainer = component.find('collapsibleSectionContainer');
		$A.util.toggleClass(sectionContainer, "slds-is-open");
	}
})