({
	init : function(component, event, helper) {
		var action = component.get("c.initStatus");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set('v.isDraft',response.getReturnValue().isDraftFlag); 
            }
        });
        $A.enqueueAction(action);
	}
})