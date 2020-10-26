({
    init: function(component, event, helper) {
        var getUrl = component.get("c.getUserType");
        var currentUrl = window.location.href;

        getUrl.setParams({ urlPath: currentUrl });
        getUrl.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tabName = response.getReturnValue();
                component.set('v.tabId', tabName);
            }
        });
    
        $A.enqueueAction(getUrl);
    },
})