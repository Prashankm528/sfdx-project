({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    onFilterChange : function(component, event, helper) {
        helper.onFilterChange(component);
    },

    search : function(component, event, helper) {
        helper.search(component);
    },

    resetFilterOption : function(component, event, helper) {
    	helper.resetFilterOption(component);
    },

    showTLLI : function(component, event, helper) {
        component.set("v.showTLLI", true);
        component.set("v.showLocations", false);
        component.set("v.showSummaryCountry", false);
        component.set("v.showPackages", false);
    },

    showLocations : function(component, event, helper) {
        component.set("v.showLocations", true);
        component.set("v.showTLLI", false);
        component.set("v.showSummaryCountry", false);
        component.set("v.showPackages", false);
    },

    showSummaryCountry : function(component, event, helper) {
        component.set("v.showSummaryCountry", true);
        component.set("v.showLocations", false);
        component.set("v.showTLLI", false);
        component.set("v.showPackages", false);
    },
    
    showPackages : function(component, event, helper) {
        component.set("v.showPackages", true);
        component.set("v.showSummaryCountry", false);
        component.set("v.showLocations", false);
        component.set("v.showTLLI", false);
    },
    
    deleteRound :function(component, event, helper){
        helper.deleteRound(component);
    }
})