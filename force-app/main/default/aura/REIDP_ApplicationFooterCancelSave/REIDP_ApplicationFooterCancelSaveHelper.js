({
	toggleSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
	}

})