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
    doInit :function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.loadSWOT(component);
        component.set("v.value","all");
    },

    statusFilterChange: function(component){
        var swotStatus = component.get("v.value");
        var data = component.get("v.data");

        if (swotStatus != 'all') {
            let status = swotStatus ==='true'? true : false;
            if(data.Strength)component.set("v.listOfSwotStrength", data.Strength.filter(strength =>{return strength.active===status}));
            if(data.Opportunity)component.set("v.listOfSwotOpportunity", data.Opportunity.filter(opportunity =>{return opportunity.active===status}));
            if(data.Threat)component.set("v.listOfSwotThreat", data.Threat.filter(threat =>{return threat.active===status}));
            if(data.Weakness)component.set("v.listOfSwotWeakness", data.Weakness.filter(weakness =>{return weakness.active===status}));
        } else {
            component.set("v.listOfSwotOpportunity", data.Opportunity);
            component.set("v.listOfSwotStrength", data.Strength);
            component.set("v.listOfSwotThreat", data.Threat);
            component.set("v.listOfSwotWeakness", data.Weakness);
        }
    },

    displayFilter: function(component) {
        component.set("v.showFilter", !component.get("v.showFilter"));
    },

    updateRelatedSwots: function(component, event, helper) {
        helper.updateSwots(component, event);
    }
})