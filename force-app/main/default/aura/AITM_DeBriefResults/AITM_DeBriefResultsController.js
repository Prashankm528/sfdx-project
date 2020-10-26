({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    handleFilterEvent : function(component, event, helper) {
        helper.handleFilterEvent(component, event);
    },

    handleSearchEvent : function(component, event, helper) {
        helper.handleSearchEvent(component, event);
    },

    handleSave : function(component, event, helper) {
        helper.handleSave(component);
    },

    navigateToSObject : function(component, event, helper) {
        helper.preventDefault(event);
        helper.handleViewSObject(component, event);
    },
    
    selectChange : function(component, event, helper) {
		helper.onSelectChange(component);
	},
    
    first : function(component, event, helper) {
        helper.firstPageRecords(component);
    },
    
    last : function(component, event, helper) {
        helper.lastPageRecords(component);
    },
    
    next : function(component, event, helper) {
        helper.nextPageRecords(component);
    },
    
    previous : function(component, event, helper) {
       helper.previousPageRecords(component);
    }
})