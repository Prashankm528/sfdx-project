({
    updateStatus : function(component, event, helper) {
        var action = component.get("c.getExeStatus");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                               
                //response.getReturnValue());
                component.set('v.isloading', false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})