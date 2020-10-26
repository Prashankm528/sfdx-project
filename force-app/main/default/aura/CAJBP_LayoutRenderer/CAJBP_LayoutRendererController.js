({
    doInit: function(component, event, helper) {
        if (window.location.href.indexOf('flexipageEditor') != -1) {
            component.set('v.isConfig', true);
        }
    }
});