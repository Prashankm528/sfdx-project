/* 
 * @author			Jan Majling
 * @date			09/09/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_RebateList component
 *
 * history
 * 09/09/2018	Jan Majling			Created
*/
({
	/**
	 * Initalizes component
	 */
	doInit: function(component, event, helper) {
		helper.loadRebates(component);
	}
})