/* 
 * @author			Jan Majling
 * @date			27/09/2018
 * @group			CAJBP
 * @description		Helper functions for CAJBP_PdfExportBUtton component
 *
 * history
 * 27/09/2018	Jan Majling			Created
*/
({
	/**
	 * Loads conga button url
	 */
	loadButtonUrl: function(component) {
		component.find('LEX_Utils_Apex').callApex(
			component,
			'c.getButtonUrl',
			{
				'recordId': component.get('v.recordId'),
			},
			this.redirect
		);
	},
	/**
	 * Redirects user to the provided url (return value)
	 */
	redirect: function(component, returnValue, params) {
		$A.get('e.force:navigateToURL')
			.setParams({'url': returnValue})
			.fire();
	}
})