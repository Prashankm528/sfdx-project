({
    init : function(component, event, helper) {
        helper.init(component);
    },
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        if(action.name == 'edit'){
           component.set('v.isEditForm',true);
           component.set('v.isAdd',false); 
           component.set('v.editRecordId' , row.id);
        }
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
        if(component.get('v.isAdd')){
            fields.CHCRM_Share_of_wallet_VOL__c = 0.00; // modify a field  
        }        
        component.find('editForm').submit(fields);
    },
    closeForm : function(component, event, helper) {
        component.set('v.isEditForm',false);
        component.set('v.isAdd',false);
        //component.set('v.editRecordId' , "");
        helper.init(component);
    }
})