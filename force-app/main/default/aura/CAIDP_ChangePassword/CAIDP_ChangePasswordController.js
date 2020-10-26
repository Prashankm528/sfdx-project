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

		var policyAction = component.get("c.getPasswordPolicyStatement");

		policyAction.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.policyStatement", response.getReturnValue());
			}
		});

	},

    openModal : function(component, event, helper) {
        component.set("v.isOpen", true);

        component.set("v.oldPassword", '');
        component.set("v.newPassword", '');
        component.set("v.newPasswordRepeat", '');

        component.set("v.isFieldsEmpty", false);
        component.set("v.isChanged", false);
        component.set("v.isShowChangePasswordButton", false);

    },
 
    closeModel : function(component, event, helper) { 
      component.set("v.isOpen", false);
    },
 
    changeOldPassword : function(component, event, helper) {
        var oldPassword = component.get("v.oldPassword");
        var newPassword = component.get("v.newPassword");
        var newPasswordRepeat = component.get("v.newPasswordRepeat");
        var emptyErrorMessage = $A.get("$Label.c.CastrolEmptyError");
        var systemErrorMessage = $A.get("$Label.c.CastrolSystemError");

        if (oldPassword == null || newPassword == null || newPasswordRepeat == null) {
        	component.set("v.isFieldsEmpty", true);
        	component.set("v.errorMessage", emptyErrorMessage);
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

	            	var siteURL = response.getReturnValue();
	            	
	                component.set("v.isChanged", true);
	                component.set("v.isFieldsEmpty", false); 
	                component.set("v.isShowChangePasswordButton", false);

	                component.set("v.pageURL", siteURL);
	            } else 
	            if (state == "ERROR"){

	                var str = response.getError()[0].message;
	                console.log("errors: " + str);
	                                    
	                component.set("v.errorMessage", systemErrorMessage);
	            	component.set("v.isFieldsEmpty", true); 
	            }
	        });
	        $A.enqueueAction(action);
        }
        
    },

    checkFields : function(component, event, helper) {

    	var oldPasswordIsValid = component.find('oldPassword').get('v.validity').valid;
    	var newPasswordIsValid = component.find('newPassword').get('v.validity').valid;
    	var repeatPasswordIsValid = component.find('newPasswordRepeat').get('v.validity').valid;

    	if (oldPasswordIsValid && newPasswordIsValid && repeatPasswordIsValid) {
    		document.getElementById("submitId").removeAttribute("disabled");
    	}
    	else {
    		document.getElementById("submitId").setAttribute("disabled", "disabled");
    	}
    }
})