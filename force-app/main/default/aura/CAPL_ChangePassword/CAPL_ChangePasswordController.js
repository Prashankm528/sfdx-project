({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchUserId");

	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	            	var currentUserId = response.getReturnValue();
	            	var userId = component.get("v.userId");

	            	console.log('currentUserId -> ' +currentUserId);
	            	console.log('userId -> ' + userId);


	            	if (currentUserId.includes(userId)) {
	            		component.set("v.isShowSection", true);
	            	}
	            } 
	        });
	        $A.enqueueAction(action);
	},

    openModal : function(component, event, helper) {
        component.set("v.isOpen", true);

        component.set("v.oldPassword", '');
        component.set("v.newPassword", '');
        component.set("v.newPasswordRepeat", '');

        component.set("v.isFieldsEmpty", false);
        component.set("v.isChanged", false);
        component.set("v.isShowChangePasswordButton", true);

    },
 
    closeModel : function(component, event, helper) { 
      component.set("v.isOpen", false);
    },
 
    changeOldPassword : function(component, event, helper) {
        var oldPassword = component.get("v.oldPassword");
        var newPassword = component.get("v.newPassword");
        var newPasswordRepeat = component.get("v.newPasswordRepeat");

        if (oldPassword == null || newPassword == null || newPasswordRepeat == null) {
        	component.set("v.isFieldsEmpty", true);
        	component.set("v.errorMessage", "Please fill required fields ");
        } else {

        	var action = component.get("c.changePassword");

        	action.setParams({
	            'newPassword' : newPassword,
	            'verifyNewPassword' : newPasswordRepeat,
	            'oldpassword' : oldPassword
	        });

	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	            	console.log('success');
	            	console.log(response.getReturnValue());

	            	var siteURL = response.getReturnValue();
	            	
	                component.set("v.isChanged", true);
	                component.set("v.isFieldsEmpty", false); 
	                component.set("v.isShowChangePasswordButton", false);

	                component.set("v.pageURL", siteURL);
	            } else 
	            if (state == "ERROR"){
	            	console.log('failure');

	                var str = response.getError()[0].message;

	                var n = str.search(",");
	                var res = str.slice(n + 1, str.length - 4);
	                                    
	                component.set("v.errorMessage",' ' + res);
	            	component.set("v.isFieldsEmpty", true); 
	            }
	        });
	        $A.enqueueAction(action);
        }
        
    }
})