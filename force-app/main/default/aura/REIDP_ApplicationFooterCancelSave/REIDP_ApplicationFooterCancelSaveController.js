({
    handleCancel: function(component) {
        // close pop-up window
        component.find("overlayLib").notifyClose();
    },
    
    handleSubmit : function(component, event, helper) {
        var successMessageLabel = $A.get("$Label.c.REIDP_RequestSuccessLabel");
        var errorMessageLabel = $A.get("$Label.c.REIDP_ErrorLabel");
        helper.toggleSpinner(component);
        var action = component.get("c.createNewAccessRequest");
        action.setParams({ appId : component.get("v.applicationId") });
        
        action.setCallback(this, function(response) {
            component.find("overlayLib").notifyClose();
            
            var toast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // prepare toast
                toast.setParams({
                    message: successMessageLabel,
                    duration: '5000',
                    type: 'success'
                });
                
                // refresh component
                var evt = $A.get("e.c:REIDP_ReInitEvent");
                evt.fire();
            }
            else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            toast.setParams({
                                message: errorMessageLabel + ' ' + errors[0].message,
                                duration: '5000',
                                type: 'error'
                            });
                        }
                    }
                }
            helper.toggleSpinner(component);
            toast.fire();
        });
        
        $A.enqueueAction(action);
    },
})