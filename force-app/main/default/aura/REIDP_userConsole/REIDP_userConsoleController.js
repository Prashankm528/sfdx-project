({
	initialize : function(component, event, helper) {
        var action = component.get("c.getUserInformation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var usrInfo = response.getReturnValue();
                if(usrInfo != null)
                    component.set('v.usr', usrInfo);
            }
        });
        $A.enqueueAction(action);
    }
})