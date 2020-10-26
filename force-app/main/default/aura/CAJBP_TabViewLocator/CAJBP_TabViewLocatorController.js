({
    /*
    * Change the current JBP tab when used in the app builder.
    */
    handleTabView: function(component, event, helper) {
        if (window.location.href.indexOf('flexipageEditor') != -1) {
            $A.get('e.c:CAJBP_TabViewEvent')
                .setParams({
                    tabId: component.get('v.selectedTab')
                }).fire();
        }
    }
});