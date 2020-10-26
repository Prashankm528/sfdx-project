({
	goToTermsAndConditions : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/termsandconditions"
	    });
	    urlEvent.fire();
	},

	goToUserGuideline : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/userguideline"
	    });
	    urlEvent.fire();
	},

	goToPrivacyStatement : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/privacystatement"
	    });
	    urlEvent.fire();
	}
})