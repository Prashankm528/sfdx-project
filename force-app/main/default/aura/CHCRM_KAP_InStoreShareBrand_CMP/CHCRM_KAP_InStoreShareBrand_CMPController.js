({
    init : function(component, event, helper) {
        helper.init(component);
    },
    handleRowAction : function(component, event, helper) {
        
    },
    handleSaveEdition : function(component, event, helper) {
        helper.updateDataList(component,event);
    },
    addInStoreShareBrand : function(component, event, helper) {
        component.set('v.isEditForm',true);
        component.set('v.isAdd',true);
        component.set("v.editRecordId", "");
    },
    onSubmit : function(component, event, helper) {
        component.set('v.isloading',true);
        event.preventDefault();
        var fields = event.getParam('fields');
        fields.Key_Account_Plan__c = component.get('v.recordId'); // modify a field
        fields.CHCRM_Share_of_wallet_VOL__c = 0.00; // modify a field
        component.find('editForm').submit(fields);
    },
    closeForm : function(component, event, helper) {
        component.set('v.isEditForm',false);
        component.set('v.isAdd',false);
        helper.init(component);
    }
})