/* 
 * @author			Jan Majling
 * @date			27/09/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_PdfExportBUtton component
 *
 * history
 * 27/09/2018	Jan Majling			Created
*/
({
	/**
	 * Runs on component initialization
	 */
	doInit : function(component, event, helper) {
		helper.loadButtonUrl(component);
	},
	/**
	 * Closes modal window of quick action
	 */
	closeWindow : function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();
	}
})