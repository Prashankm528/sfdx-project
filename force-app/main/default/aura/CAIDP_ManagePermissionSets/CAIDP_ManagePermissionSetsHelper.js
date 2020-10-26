({

	getOrgURL : function (component, event, helper) {
		var getUrl = component.get("c.getOrgUrl");
	    getUrl.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var orgUrl = response.getReturnValue();
	        	component.set("v.orgUrl", orgUrl);
	        	console.log('url ' + orgUrl); 
	        }
	    });

	    $A.enqueueAction(getUrl);
	},

	getPermissions : function (component, event, helper) {
        var getApps = component.get("c.getAppPermissions");
        getApps.setParams({accId: component.get("v.recordId")});

	    getApps.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var apps = response.getReturnValue();
	        	component.set("v.allApps", apps);
	        	console.log('allApps ' + apps); 
	        }
	    });

	    $A.enqueueAction(getApps);
    },

    getUserPermissionIds : function (component, event, helper) {
        var getApps = component.get("c.getAssignedPermissionIds");
        getApps.setParams({accId: component.get("v.recordId")});

	    getApps.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var apps = response.getReturnValue();
	        	component.set("v.selectedApps", apps);
	        	console.log('selectedApps ' + apps); 
	        }
	    });

	    $A.enqueueAction(getApps);
    },

    getUserPermissions : function (component, event, helper) {
        var getApps = component.get("c.getAssignedPermissions");
        getApps.setParams({accId: component.get("v.recordId")});

	    getApps.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var apps = response.getReturnValue();
	        	component.set("v.selectedPermissions", apps);
	        	component.set("v.selectedAppsSize", apps.length);
	        }
	    });

	    $A.enqueueAction(getApps);
    },

    saveUserPermissions : function (component, event, helper) {
    	var manageApps = component.get("c.managePermissions");

    	var accId = component.get("v.recordId");
    	var currPermissions = component.get("v.selectedApps");
    	var prevPermissions = component.get("v.selectedPermissions");
    	console.log('currPermissions ' + currPermissions); 
    	console.log('prevPermissions ' + prevPermissions); 
        manageApps.setParams({accId: accId, currPermissions: currPermissions, prevPermissions: prevPermissions});

	    manageApps.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var apps = response.getReturnValue();
	        	console.log('new permissions ' + apps); 
	        }
	        else {
	        	console.log('state ' + state); 
	        }
	    });

	    $A.enqueueAction(manageApps);
    }
})