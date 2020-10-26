({
    doInit : function(component, event, helper) {
        var showOpenComplaintsWarning = component.get("c.showOpenComplaintsWarning");
        
        showOpenComplaintsWarning.setParams({"accountId": component.get("v.recordId")});
        
        showOpenComplaintsWarning.setCallback(this, function(response) {
            var state = response.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                    component.set("v.showWarning", response.getReturnValue());
            } else {
                console.log('showWarning call failed: ' + state);
            }
        });
        
        $A.enqueueAction(showOpenComplaintsWarning);
    }
})