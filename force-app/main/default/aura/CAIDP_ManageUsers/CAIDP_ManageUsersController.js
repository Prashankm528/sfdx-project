({

	doInit: function(component, event, helper) {

		var newTable = component.get("c.createRows");
		var rows = component.get("v.rows");
		console.log('rows: ' + rows);

		newTable.setParams({size:rows});

	    newTable.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var result = response.getReturnValue();
	        	if (result != null) {
					var pageSize = component.get("v.pageSize");              	
		        	component.set("v.allMembers", result);
		        	component.set("v.memberCount", result.length);
		        	component.set("v.maxPage", Math.floor((result.length + pageSize - 1) / pageSize));
		        	var pageRecords = result.slice(0, pageSize);
			        component.set("v.members", pageRecords);
			        component.set("v.pageNumber", 1);
	        	}
	        	console.log('result ' + result); 
	        }
	        else {
	            console.log("Failed with state: " + state);
	        }
	    });

	    $A.enqueueAction(newTable);

	    var getCastrolApps = component.get("c.getApps");

	    getCastrolApps.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var apps = response.getReturnValue();
	        	component.set("v.castrolApps", apps);
	        	console.log('castrolApps ' + apps); 
	        }
	        else {
	            console.log("Failed with state: " + state);
	        }
	    });

	    $A.enqueueAction(getCastrolApps);

	     var languages = [
	        {value: "en_US", label: "English"}, 
	        {value: "ru", label: "Russian"},
	        {value: "uk", label: "Ukranian"}, 
	        {value: "vi", label: "Vietnamese"},  
	        {value: "tr", label: "Turkish"}];
	    component.set("v.languages", languages);

	    component.set("v.allMembers", []);
	    component.set("v.invited", false);
	},

	inviteUsers: function(component, event, helper) {

		helper.savePageMembers(component, event, helper);
		
		var currMembers = component.get("v.allMembers");	
		var hasEmails = false;
		for (var i = 0; i < currMembers.length; i++) {
			if (currMembers[i].email) {
				hasEmails = true;
				break;
			}
		}

		if (!hasEmails) {
			component.set("v.isSent", false);
    		component.set("v.modalMessage", "No emails specified.");
    		component.set("v.modalHeader", "ERROR");
    		component.set("v.isOpen", true);
		}
		else {
			var invite = component.get("c.inviteMembers");

			invite.setParams({jsonMembers:JSON.stringify(currMembers),isInvite:true});

		    invite.setCallback(this, function(response) {
		        var state = response.getState();
		        if (state === "SUCCESS") {
		        	var result = response.getReturnValue();
		        	if (result == null) {
		        		component.set("v.isSent", true);
		        		component.set("v.modalMessage", "Members were invited.");
		        		component.set("v.modalHeader", "SUCCESS");
		        		component.set("v.invited", true);
		        		component.set("v.invitedDate", new Date());
		        	}
		        	else {
		        		component.set("v.isSent", false);
		        		component.set("v.modalMessage", result);
		        		component.set("v.modalHeader", "ERROR");
		        	}
		        	console.log('result ' + result); 
		        }
		        else {
		        	component.set("v.isSent", false);
	        		component.set("v.modalMessage", "Unexpected errors occured.");
	        		component.set("v.modalHeader", state);
		            console.log("Failed with state: " + state);
		        }
		        component.set("v.isOpen", true);
		    });

		    $A.enqueueAction(invite);
		}
	},

	migrateUsers: function(component, event, helper) {

		helper.savePageMembers(component, event, helper);
		
		var currMembers = component.get("v.allMembers");	
		var hasEmails = false;
		for (var i = 0; i < currMembers.length; i++) {
			if (currMembers[i].email) {
				hasEmails = true;
				break;
			}
		}

		if (!hasEmails) {
			component.set("v.isSent", false);
    		component.set("v.modalMessage", "No emails specified.");
    		component.set("v.modalHeader", "ERROR");
    		component.set("v.isOpen", true);
		}
		else {
			var invite = component.get("c.inviteMembers");

			invite.setParams({jsonMembers:JSON.stringify(currMembers),isInvite:false});

		    invite.setCallback(this, function(response) {
		        var state = response.getState();
		        if (state === "SUCCESS") {
		        	var result = response.getReturnValue();
		        	if (result == null) {
		        		component.set("v.isSent", true);
		        		component.set("v.modalMessage", "Members were invited.");
		        		component.set("v.modalHeader", "SUCCESS");
		        		component.set("v.invited", true);
		        		component.set("v.invitedDate", new Date());
		        	}
		        	else {
		        		component.set("v.isSent", false);
		        		component.set("v.modalMessage", result);
		        		component.set("v.modalHeader", "ERROR");
		        	}
		        	console.log('result ' + result); 
		        }
		        else {
		        	component.set("v.isSent", false);
	        		component.set("v.modalMessage", "Unexpected errors occured.");
	        		component.set("v.modalHeader", state);
		            console.log("Failed with state: " + state);
		        }
		        component.set("v.isOpen", true);
		    });

		    $A.enqueueAction(invite);
		}
	},

	resizeTable: function(component, event, helper) {

		helper.savePageMembers(component, event, helper);
		
		var currMembers = component.get("v.allMembers");		
		var rows = parseInt(component.get("v.rows"));
		console.log('members ' + currMembers);
		console.log('rows ' + rows);

		if (rows <= currMembers.length) {
			currMembers.length = rows;
			console.log('members later' + currMembers);
        	var pageSize = component.get("v.pageSize");              	
        	component.set("v.allMembers", currMembers);
        	component.set("v.memberCount", rows);
        	component.set("v.maxPage", Math.floor((currMembers.length + pageSize - 1) / pageSize));
        	var pageRecords = currMembers.slice(0, pageSize);
	        component.set("v.members", pageRecords);
	        component.set("v.pageNumber", 1);
		}
		else {
			var size = rows - currMembers.length;
			var newTable = component.get("c.createRows");
			console.log('size ' + size);

			newTable.setParams({size:size.toString()});
		    newTable.setCallback(this, function(response) {
		        var state = response.getState();
		        if (state === "SUCCESS") {
		        	var result = response.getReturnValue();
		        	if (result != null) {
						var pageSize = component.get("v.pageSize");              	
			        	component.set("v.allMembers", currMembers.concat(result));
			        	component.set("v.memberCount", rows);
			        	component.set("v.maxPage", Math.floor((rows + pageSize - 1) / pageSize));
			        	var pageRecords = currMembers.concat(result).slice(0, pageSize);
				        component.set("v.members", pageRecords);
				        component.set("v.pageNumber", 1);
		        	}
		        }
		        else {
		            console.log("Failed with state: " + state);
		        }
		    });

		    $A.enqueueAction(newTable);
		}
		component.set("v.isResizing", false);
		component.set("v.invited", false);
		component.set("v.rows", "1");
	},

    openResize: function(component, event, helper) { 
      	component.set("v.isResizing", true);
    },

    closeResize: function(component, event, helper) { 
      	component.set("v.isResizing", false);
      	component.set("v.rows", "1");
    },

    openUpload: function(component, event, helper) { 
      	component.set("v.isUpload", true);  	
      	var label = event.getSource().get("v.label");
      	component.set("v.uploadLabel", label);
    },

    closeUpload: function(component, event, helper) { 
      	component.set("v.isUpload", false);
      	component.set("v.isFileSelected", false);
    },

    openPreview: function(component, event, helper) {
 		component.set("v.isPreview", true);

 		var jsonMembers = component.get("v.jsonMembers");
 		var action = component.get('c.getMembers');

 		action.setParams({jsonMembers:jsonMembers});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.membersPreview', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);

        component.set("v.isUpload", false);
    },

    closePreview: function(component, event, helper) {
    	component.set("v.isPreview", false);
    	component.set("v.membersPreview", []);
    	component.set("v.isUpload", true);
    },

    uploadUsers: function(component, event, helper) {
    	var jsonMembers = component.get("v.jsonMembers");
 		var action = component.get('c.getMembers');

 		action.setParams({jsonMembers:jsonMembers});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var members = response.getReturnValue();
            	if(members != null) {
                	var pageSize = component.get("v.pageSize");              	
	            	component.set("v.allMembers", members);
	            	component.set("v.memberCount", members.length);
	            	console.log("members.length: " + members.length);
	            	component.set("v.maxPage", Math.floor((members.length + pageSize - 1) / pageSize));
	            	var pageRecords = members.slice(0, pageSize);
			        component.set("v.members", pageRecords);
			        component.set("v.pageNumber", 1);
                } 
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);

        component.set("v.isUpload", false);
        component.set("v.isFileSelected", false);
        component.set("v.invited", false);
    },

    upload : function(component, event, helper) {
    	var files = component.get("v.fileToBeUploaded");
    	if (files && files.length > 0) {
            var file = files[0][0];
		    if (file) {
		        var reader = new FileReader();
		        reader.readAsText(file, "UTF-8");
		        reader.onload = function (evt) {
		            var result = helper.CSV2JSONMembers(component, evt.target.result);
		            component.set("v.jsonMembers", result);
		            component.set("v.isFileSelected", true);
		            component.set("v.fileTitle", file.name);
		            console.log(JSON.parse(result));
		        }
		        reader.onerror = function (evt) {
		            console.log("error reading file");
		        }
		    }
		}
	},
 
    closeModal: function(component, event, helper) { 
      	component.set("v.isOpen", false);
      	component.set("v.modalMessage", null);
		component.set("v.modalHeader", null);
    },

    closeAlert: function(component, event, helper) { 
      	component.set("v.invited", false);
    },

	renderPage : function(component, event, helper) {

		var userList = component.get("v.allMembers"),
        pageNumber = component.get("v.pageNumber"),
        pageSize = component.get("v.pageSize"),
        pageRecords = userList.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        console.log("pageRecords: " + pageRecords);
        component.set("v.members", pageRecords);
	},

	firstPage: function(component, event, helper) {
		helper.savePageMembers(component, event, helper);
        component.set("v.pageNumber", 1);
    },

    prevPage: function(component, event, helper) {
    	helper.savePageMembers(component, event, helper);
        component.set("v.pageNumber", Math.max(component.get("v.pageNumber") - 1, 1));
    },

    nextPage: function(component, event, helper) {
    	helper.savePageMembers(component, event, helper);
        component.set("v.pageNumber", Math.min(component.get("v.pageNumber") + 1, component.get("v.maxPage")));
    },

    lastPage: function(component, event, helper) {
    	helper.savePageMembers(component, event, helper);
        component.set("v.pageNumber", component.get("v.maxPage"));
    },

    toggleSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})