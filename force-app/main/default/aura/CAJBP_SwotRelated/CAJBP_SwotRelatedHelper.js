/**
 * @author			Venkatesh Muniyasamy
 * @date			20/12/2019
 * @group			CAJBP
 * @description		Renders SWOT's New Matrix.
 *
 * history
 * 20/12/2019 	Venkatesh Muniyasamy	Created
 */
({
    loadSWOT :function(component) {
        var apexProvider = component.find('apexProvider');
        var action = component.get('c.getSwots');

        apexProvider.execute(action, {jbpId: component.get('v.recordId')}, function(error, result)
        {
            if (error) {
                console.error(error.message);
            } else {
                if(result) {
                    component.set("v.data", result);
                    component.set("v.listOfSwotOpportunity", result.Opportunity);
                    component.set("v.listOfSwotStrength", result.Strength);
                    component.set("v.listOfSwotThreat", result.Threat);
                    component.set("v.listOfSwotWeakness", result.Weakness);
                }
            }

            component.set("v.isLoading", false);
        });
    },

    updateSwots: function(component, event) {
        component.set('v.isLoading', true);

        const apexProvider = component.find('apexProvider');
        const action = component.get('c.updateSwots');

        apexProvider.execute(action, {json: JSON.stringify(event.getParam('swots'))}, function(error, result) {
            if (error) {
                console.error(error.message);
            } else {
                console.log('Updated swots ....');
            }

            component.set('v.isLoading', false);
        });
    }
})