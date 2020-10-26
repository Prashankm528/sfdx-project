({
	sendHelper: function(component, getEmail, getFrom, getSubject, getBody) {	

        var action = component.get("c.sendMailToSupport");
        var successMessage = component.get("v.successLabel");
        var errorMessage = component.get("v.errorLabel");
  
        action.setParams({
            'toEmail': getEmail,
            'fromEmail': getFrom,
            'subject': getSubject,
            'body': getBody
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == null) {
                	component.set("v.mailStatus", true);
                	component.set("v.message", successMessage + " " + getEmail);
                	component.set("v.modalClass", "slds-theme--success");
                }
                else {
                	component.set("v.mailStatus", true);
                	component.set("v.message", errorMessage);
                	component.set("v.modalClass", "slds-theme--error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})