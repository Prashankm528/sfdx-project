({
	init : function(component, event, helper) {
		component.set('v.loading', true);
        helper.updateStatus(component, event, helper);
	}
})