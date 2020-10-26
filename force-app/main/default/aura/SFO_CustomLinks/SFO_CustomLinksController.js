({
    /*
    * returns current active links and current user info.
    */
	init :function(component, event, helper) {
        var action = component.get("c.getCustomLinksData");
        var config = component.get("v.config");
        var names = component.get("v.names");

        //return a list of developer names and trim whitespaces.
        if (!$A.util.isEmpty(names)) {
            names = names.split(",").map(function(item) {
                return item.trim();
            });
        } else {
            names = null;
        }

        //call apex class to get custom links and current user info.
        action.setParams({
            config: config,
            names: names
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();

            if (state === "ERROR") {
                var message = "";

                if (errors) {
                    //Get first error only.
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    } else if (errors[0] && errors[0].pageErrors) {
                        message = errors[0].pageErrors[0].message;
                    } else {
                        message = "Unknown error."
                    }
                }

                //always show error in console.
                console.error(message);

                //only show toast error message if supported.
                var toastEvent = $A.get("e.force:showToast");

                if (!$A.util.isEmpty(toastEvent)) {
                    component.find("notifLib").showToast({
                        title: "Custom Links Error!",
                        message: message,
                        variant: "error",
                        mode: "sticky"
                    });
                }
            }
            else if ( state === "SUCCESS") {
                var data = response.getReturnValue();

                component.set("v.currentUser", data.currentUser);
                component.set("v.links", data.links);
            }
        });
        
        $A.enqueueAction(action);
    }
})