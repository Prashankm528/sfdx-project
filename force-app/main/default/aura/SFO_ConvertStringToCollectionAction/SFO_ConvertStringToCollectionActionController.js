({
    invoke: function(component, event, helper) {
        component.set('v.collection', component.get('v.targetValue').split(component.get('v.separator')));
    }
});