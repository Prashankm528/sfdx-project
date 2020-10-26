({
	 toggleSpinner : function(component, event) {
        var spinner = component.find("consumerDetailsSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})