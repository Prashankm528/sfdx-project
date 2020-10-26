({
	doInit : function(component, event, helper) {
	},
	
	showSection : function(component, event, helper) {
		var element = event.target.closest(".slds-accordion__section");
		element.classList.toggle("slds-is-open");
	}
})