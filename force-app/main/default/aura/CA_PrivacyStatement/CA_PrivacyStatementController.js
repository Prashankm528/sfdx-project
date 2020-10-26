({
	doInit : function(component, event, helper) {
        var getSalesOrg = component.get("c.getSalesOrg");

        // To set users Sales Org
        getSalesOrg.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.userSalesOrg", response.getReturnValue());
            } else {
                console.log('Problem getting user\'s Sales Org: ' + state);
            }
        });
        
        $A.enqueueAction(getSalesOrg);
        
        var getProfile = component.get("c.getProfile");

        // To set users Sales Org
        getProfile.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.userProfile", response.getReturnValue());
            } else {
                console.log('Problem getting user\'s Profile: ' + state);
            }
        });
        
        $A.enqueueAction(getProfile);
    }
})