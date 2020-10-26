/* 
 * @author			Jan Majling
 * @date			19/09/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_JBPBridgeChart component
 *
 * history
 * 19/09/2018	Jan Majling			Created
*/
({
	/**
	 * Initializes data in component
	 */
	doInit: function(component, event, helper) {
		helper.setTypeOptions(component);
		helper.loadChartData(component);
	},
	/**
	 * Updates chart
	 */
	updateChart: function(component, event, helper) {
		helper.renderChart(component);
	},
})