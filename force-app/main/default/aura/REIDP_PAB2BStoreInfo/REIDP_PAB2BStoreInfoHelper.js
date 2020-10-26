({
	toggleSpinner : function(component, event) {
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    handleStoreInfoRefresh : function(component, event) {
        this.toggleSpinner(component, event);
        var acceptanceLocation = component.get("v.acceptanceLocation");
        if(acceptanceLocation != null) {
            var storeCode = acceptanceLocation.storeCode;
            var action = component.get("c.getStoreAcceptanceLocationConfig");
            action.setParams({
                "storeCode": storeCode
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.acceptanceLocation", a.getReturnValue().acceptanceLocation);
                    component.set("v.mobileEnabled", a.getReturnValue().mobileEnabled);
                    component.set("v.goLiveDate", a.getReturnValue().goLiveDate);
                }
                this.toggleSpinner(component, event);
                component.set("v.editMode", false);
            });
            $A.enqueueAction(action);
        }
    }
})