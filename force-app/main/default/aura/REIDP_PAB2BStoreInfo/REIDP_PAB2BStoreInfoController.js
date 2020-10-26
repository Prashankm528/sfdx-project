({  
    handleSave : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var acceptanceLocation = component.get('v.acceptanceLocation');
        var mobileEnabled = component.get('v.mobileEnabled');
        var newGoLiveDate = component.get('v.newGoLiveDate');
        if(newGoLiveDate != null)
            newGoLiveDate = $A.localizationService.formatDate(newGoLiveDate, "M/d/YY");
        
        if(acceptanceLocation != null) {
            
            var action = component.get("c.updateStoreAcceptanceLocationConfig");
            action.setParams({
                "aLocation": JSON.stringify(acceptanceLocation),
                "mobileEnabled": mobileEnabled,
                "goLiveDate": newGoLiveDate
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var toastEvent = $A.get("e.force:showToast");
                helper.toggleSpinner(component, event);
                if(component.isValid() && state == "SUCCESS") {
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Location Information was changed successfully!"
                    });
                } else if (state == "ERROR") {
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": a.getError()[0].message
                    });
                }
                helper.handleStoreInfoRefresh(component, event);
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Can't change Location Information, because Store Code is empty."
            });
            toastEvent.fire();
        }
    },
    
    handleEdit : function(component, event, helper) {
        component.set("v.editMode", true);
    },
    
    handleCancel : function(component, event, helper) {
        helper.handleStoreInfoRefresh(component, event);
    }
})