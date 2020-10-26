({
	onPageReferenceChange: function(component, event, helper) {
        component.get("v.pageReference");
    },
    doInit : function(component, event, helper) {
		helper.CaseRecords(component, event, helper);
	},
    
})