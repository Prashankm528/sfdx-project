({
	init : function(component, event, helper) {
        helper.initHelper(component);
	},
    handleRowAction : function(component, event, helper) {
        //var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.editRecordId", row.id);
        component.set("v.isEdit", true);
	},
    onSubmit : function(component, event, helper) {
        component.set('v.isloading',true);
	},
    closeEditForm : function(component, event, helper) {
        helper.initHelper(component);
        component.set("v.isEdit", false);
	}
})