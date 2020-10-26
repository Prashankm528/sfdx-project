({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchUserLanguage");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var language = response.getReturnValue();

                switch (language) {
                    case 'en_US':
                        component.set("v.documentURL", $A.get('$Resource.CAPL_Resources') + '/CAPL_Resources/documents/TermsAndConditions-en_US.pdf');
                        break; 
                    case 'tr':
                        component.set("v.documentURL", $A.get('$Resource.CAPL_Resources') + '/CAPL_Resources/documents/TermsAndConditions-tr.pdf');
                        break; 
                    default: 
                        component.set("v.documentURL", $A.get('$Resource.CAPL_Resources') + '/CAPL_Resources/documents/TermsAndConditions-en_US.pdf');
                }

            }
        });
        $A.enqueueAction(action);
    }
})