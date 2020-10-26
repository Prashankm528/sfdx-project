({
	doInit: function(component, event, helper) {

		var action = component.get("c.getUserEmail");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var email = response.getReturnValue();
                component.set("v.userEmail", email);
            }
 
        });
        $A.enqueueAction(action);

        //for tests
        //component.set("v.supportEmail", "k_potapovich@twistellar.com");
	},

	showSection : function(component, event, helper) {
		var element = event.target.closest(".slds-docked-composer");
		element.classList.toggle("slds-is-open");
	},

	sendMail: function(component, event, helper) {	
        var getEmail = component.get("v.supportEmail");
        var getFrom = component.get("v.userEmail");
        var getSubject = component.get("v.subject");
        var getBody = component.get("v.body");

        var inputSubject = component.find("subject");

        if (getSubject) {
        	inputSubject.set("v.errors", null);   
        } else {
            inputSubject.set("v.errors", [{message: component.get("v.subjectError")}]);
        }
        if (getBody) {
        	component.set("v.validity", true);   
        } else {
            component.set("v.validity", false);
        } 

        if (getSubject && getBody && getEmail) {
            helper.sendHelper(component, getEmail, getFrom, getSubject, getBody);
            var element = event.target.closest(".slds-docked-composer");
			element.classList.toggle("slds-is-open");
        }
    },

    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
})