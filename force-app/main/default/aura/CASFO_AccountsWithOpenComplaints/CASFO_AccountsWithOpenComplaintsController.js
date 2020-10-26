({
	doInit : function(component, event, helper) {
		var getAccounts = component.get("c.getAccounts");
        
        getAccounts.setCallback(this, function(response) {
            var state = response.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                
                console.log(result);
                
                if(result !== null && result.length > 0) {
                    component.set("v.accounts", result);
                    component.set("v.show", true);
            	} else {
                    component.set("v.show", false);
                }
            }
        });
        
        $A.enqueueAction(getAccounts);
	}
})