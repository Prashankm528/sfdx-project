({
	initialize: function (component, event, helper) {
		console.log('recordId: ' + component.get("v.recordId"));
        helper.getPermissions(component, event, helper);
        helper.getUserPermissionIds(component, event, helper);
        helper.getUserPermissions(component, event, helper);
        helper.getOrgURL(component, event, helper);
    },

    openModal : function(component, event, helper) {
        component.set("v.isOpen", true);
    },

    closeModal : function(component, event, helper) { 
      component.set("v.isOpen", false);
    },

    savePermissions : function(component, event, helper) {
    	console.log("Options selected: '" + component.get("v.selectedApps") + "'");
    	helper.saveUserPermissions(component, event, helper);
    	helper.getUserPermissions(component, event, helper);
    	component.set("v.isOpen", false);
    }
})