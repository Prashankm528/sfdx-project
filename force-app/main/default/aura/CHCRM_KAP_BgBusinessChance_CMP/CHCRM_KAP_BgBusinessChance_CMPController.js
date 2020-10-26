({
    init : function(component, event, helper) {
        helper.initDatable(component);
    },
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        if(action.name == 'edit'){
            var row = event.getParam('row');            
            if(row.index == '4' || row.index == '5'){
                row.lastYear3 = row.lastYear3.replace('%','');
                row.lastYear2 = row.lastYear2.replace('%','');
                row.lastYear = row.lastYear.replace('%','');
                row.curYear = row.curYear.replace('%','');
                row.nextYear = row.nextYear.replace('%','');
                row.nextYear2 = row.nextYear2.replace('%','');
                component.set('v.isPercent',true);
                component.set('v.editRow',row);
            }else{
                component.set('v.isPercent',false);
                component.set('v.editRow',row);
            }
            component.set('v.isEditForm',true);
        }
    },
    closeEdit : function(component, event, helper) {
        helper.initDatable(component);       
        component.set('v.isEditForm',false);
        component.set('v.inputError',false);
        component.set('v.errorMessage',[]);
    },
    editSave : function(component, event, helper) {
        component.set('v.isloading',true);
        helper.saveHelper(component);
    },
    cancelErrorAlert : function(component, event, helper) {
        helper.initDatable(component);
        component.set('v.inputError',false);
        component.set('v.errorMessage',[]);
    }
})