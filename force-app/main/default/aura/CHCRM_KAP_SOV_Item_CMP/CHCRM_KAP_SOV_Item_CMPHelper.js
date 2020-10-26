({
    refreshFinanceHelper : function(component) {
        var action = component.get("c.refreshFinance");
        action.setParams({ titleId : component.get("v.sovTitleId"),
                          yearStrList : component.get("v.yearHeader") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                               
                component.set('v.financeList',response.getReturnValue().financeList); 
                component.set('v.isloading',false);
            }
        });
        $A.enqueueAction(action);
    },    
    financeSaveHelper : function(component) {
        var action = component.get("c.saveSOVFinance");
        action.setParams({ editRow : component.get("v.financeEditRow") , 
                          titleId : component.get("v.sovTitleId"),
                          yearStrList : component.get("v.yearHeader")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isloading',false);
                component.set('v.isEditFinanceForm',false);
                component.set('v.financeList',response.getReturnValue().financeList);
            }
        });
        $A.enqueueAction(action);
    },
    deleteSovHelper : function(component){
        var action = component.get("c.deleteSOV");
        action.setParams({ titleId : component.get("v.sovTitleId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //刷新父组件
                component.getEvent("DeleteSovEvent").fire();
                component.set('v.isDeleteSOV',false);
                component.set('v.isloading',false);
            }
        });
        $A.enqueueAction(action);
    },
    refreshProjectHelper : function(component){
        var action = component.get("c.refreshProject");
        action.setParams({ titleId : component.get("v.sovTitleId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.projectList',response.getReturnValue().projectList);
                component.set('v.isloading',false);
            }
        });
        $A.enqueueAction(action);
    },
    deleteProjectHelper : function(component){
        var deleteId = component.get('v.editRecordId');
        var action = component.get("c.delereProject");
        action.setParams({ recordId : deleteId });
        component.set('v.editRecordId','');
        action.setCallback(this, function(response) {
            var state = response.getState();                       
            if (state === "SUCCESS") {                
                this.refreshProjectHelper(component);               
                component.set("v.isEditProjectForm", false);
                component.set("v.isDeleteProjectForm", false);
            }
        });
        $A.enqueueAction(action);
    }
})