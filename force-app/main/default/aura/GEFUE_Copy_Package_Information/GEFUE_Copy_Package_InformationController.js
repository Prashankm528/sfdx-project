({
    submitDetails: function(component, event, helper) {
        var action = component.get("c.updateSiteCloseDate");
        action.setParams({ "opportunityID" : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State value '+state);
            if (state === "SUCCESS") {
                helper.showSuccessToast();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: errors,
                    type : 'error'
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})