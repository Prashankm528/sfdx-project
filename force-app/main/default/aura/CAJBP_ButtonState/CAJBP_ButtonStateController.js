({
    onAction: function(component, event, helper) {
        $A.enqueueAction(component.get('v.onclick'));
    }
});