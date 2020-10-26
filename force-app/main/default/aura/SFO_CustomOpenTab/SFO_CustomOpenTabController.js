({
    init: function(component, event, helper) {
        var action = component.get("c.getCustomLinksData");
        var configName = component.get("v.configName");
        var linkName = component.get("v.linkName");

        if ($A.util.isEmpty(linkName)) {
            return;
        }

        var names = [linkName];

        action.setParams({
            config: configName,
            names: names
        });

        action.setCallback(this, function (response) {
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

            } else if (state === "SUCCESS") {
                var data = response.getReturnValue();

                if (!$A.util.isEmpty(data.links)) {
                    var link = data.links[0];
                    window.open(link.SFO_URL__c, link.SFO_Target__c);
                }
            }
        });

        $A.enqueueAction(action);
    }
});