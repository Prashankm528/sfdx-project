({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchUserLanguage");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var language = response.getReturnValue();

                switch (language) {
                    case 'en_US':
                        component.set("v.documentURL", $A.get('$Resource.CAPL_Resources') + '/CAPL_Resources/documents/UserGuideline-en_US.pdf');
                        break; 
                    case 'tr':
                        component.set("v.documentURL", $A.get('$Resource.CAPL_Resources') + '/CAPL_Resources/documents/UserGuideline-en_US.pdf');
                        break; 
                    default: 
                        component.set("v.documentURL", $A.get('$Resource.CAPL_Resources') + '/CAPL_Resources/documents/UserGuideline-en_US.pdf');
                }

            }
        });
        $A.enqueueAction(action);
	},

	agreeGuideline : function(component, event, helper) {
		var checkCmp = component.find("isAgreeCheckbox");
		var isAgree = checkCmp.get("v.value");

		console.log('qwe');

		var action = component.get("c.agreeWithGuideline");
		action.setParams({"isAgree": isAgree});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	
    //         	var homeEvent = $A.get("e.force:navigateToObjectHome");
				// homeEvent.setParams({
				//         "scope": "CollaborationGroup"
				//     });
				// homeEvent.fire();

                var url = window.location.href; 
                var value = url.substr(0,url.lastIndexOf('/') + 1);
                window.history.back();
                return false;
                
            } 
        });
        $A.enqueueAction(action);
	}
})