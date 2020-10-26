/* 
 * @author			Jan Majling
 * @date			09/08/2018
 * @group			CAJBP
 * @description		Helper functions for CAJBP_RebateList component
 *
 * history
 * 09/08/2018	Jan Majling			Created
*/
({
	loadRebates: function(component) {
		var apexProvider = component.find('apexProvider');
        var action = component.get('c.getData');

        apexProvider.execute(action, {jbpId: component.get('v.recordId')}, function(error, result) {
            if (error) {
                console.log(error.message);
            } else {
                component.set('v.rebates', result.rebates);
                component.set('v.describeInfo', result.rebateDescribeInfo);
            }

            component.set('v.isLoading', false);
            component.set('v.bodyClass', '');
        });
	}
})