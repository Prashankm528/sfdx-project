({
	handleSearch : function(component, event, helper) {
        component.set('v.buttonstate', !component.get('v.buttonstate'));
        component.set('v.storeConfig', null);
        var storeCode = component.get("v.storeCode");
        if(storeCode !=null && storeCode!=undefined) {
            var action = component.get("c.getStoreAcceptanceLocationConfig");
            action.setParams({
                "storeCode": storeCode
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.storeConfig", a.getReturnValue());
                } else if (state == "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": a.getError()[0].message
                    });
                    toastEvent.fire();
                }
                component.set('v.buttonstate', !component.get('v.buttonstate'));
            });
            $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Please enter Store Code."
            });
            toastEvent.fire();
            component.set('v.buttonstate', !component.get('v.buttonstate'));
        }    
	}
})