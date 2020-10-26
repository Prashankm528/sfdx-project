({
    init : function(component, event, helper) {
        
        var getPolicyRuleAction = component.get("c.getPolicyRule");
        getPolicyRuleAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                component.set("v.policyRule", rtnValue);
            }
        });
        $A.enqueueAction(getPolicyRuleAction);
        
    },
    
    handleSubmit : function(component, event, helper) {
        
        var oldPassword = component.get("v.oldPassword");
        var newPassword = component.get("v.newPassword");
        var newPasswordRepeat = component.get("v.newPasswordRepeat");
        
        if (oldPassword == null || newPassword == null || newPasswordRepeat == null) {
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                message: $A.get("$Label.c.IDPEmptyError") ,
                duration: '3000',
                type: 'warning'
            });
            toast.fire();
        } else {
            var changePasswordAction = component.get("c.changePassword");
            changePasswordAction.setParams({
                'newPassword' : newPassword,
                'verifyNewPassword' : newPasswordRepeat,
                'oldpassword' : oldPassword
            });
            
            changePasswordAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var siteURL = response.getReturnValue();
                    
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        message: $A.get("$Label.c.IDPPasswordChanged") ,
                        duration: '3000',
                        type: 'success'
                    });
                    toast.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else if (state === "ERROR") {
                        var str = response.getError()[0].message;
                    
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            message: $A.get("$Label.c.IDPSystemError") ,
                            duration: '3000',
                            type: 'error'
                        });
                        toast.fire();
                    }
            });
            $A.enqueueAction(changePasswordAction);
            
        }
    },
    
    checkFields : function(component, event, helper) {
    	var oldPasswordIsValid = component.find('oldPassword').get('v.validity').valid;
    	var newPasswordIsValid = component.find('newPassword').get('v.validity').valid;
    	var repeatPasswordIsValid = component.find('newPasswordRepeat').get('v.validity').valid;
        var button = component.find('submitId');
        
    	if (oldPasswordIsValid && newPasswordIsValid && repeatPasswordIsValid) {
            button.set('v.disabled', false);
    	} else {
            button.set('v.disabled', true);
    	}
    }
})