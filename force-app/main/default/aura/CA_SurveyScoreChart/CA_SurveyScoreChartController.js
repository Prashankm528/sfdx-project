({
    afterScriptsLoaded : function(component, event, helper) {
        component.set("v.ready", true);
        helper.createChartCES(component);
        helper.createChartNPS(component);
    }
})