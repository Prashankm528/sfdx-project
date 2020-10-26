({
    init : function(component, event, helper) {
        var getApplicationList = component.get("c.getAppList");
        
        getApplicationList.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.appsList", response.getReturnValue());
            }
        });
       
        $A.enqueueAction(getApplicationList);
    }
})