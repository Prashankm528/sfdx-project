({
    onPageReferenceChange: function(component, evt, helper) {
        component.set('v.recordId', component.get('v.pageReference.state.c__recordId'));
        component.set('v.year', component.get('v.pageReference.state.c__year'));
        component.set('v.clt', component.get('v.pageReference.state.c__clt'));
    }
});