({
    init : function(component, event, helper) {
        var isDraft = component.get('v.isDraft');
        var caltrolAction = [
            { label: 'Edit', name: 'edit' }
        ];
        var yearHeader = component.get('V.yearHeader');
        //嘉实多业务总量 
        var finacnceAllColumns = [
            { label: '财务指标', fieldName: 'financeTarget', type: 'text' ,initialWidth: 250},
            { label: yearHeader[0], fieldName: 'lastYear3', type: 'text' },
            { label: yearHeader[1], fieldName: 'lastYear2', type: 'text' },
            { label: yearHeader[2], fieldName: 'lastYear', type: 'text' , editable: false },
            { label: yearHeader[3], fieldName: 'curYear', type: 'text' , editable: false},
            { label: yearHeader[4], fieldName: 'nextYear', type: 'text' , editable: false},
            { label: yearHeader[5], fieldName: 'nextYear2', type: 'text' , editable: false},
            { label: 'CAGR', fieldName: 'CAGR', type: 'text' , editable: false}             
        ];
        if(isDraft){
           finacnceAllColumns.push({ type: 'action', typeAttributes: { rowActions: caltrolAction } }); 
        }
        component.set('v.finacnceAllColumns',finacnceAllColumns);
        var otherAction = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        var dateFormat = { 
            month: 'numeric',  
            year: 'numeric',   
            hour12: false}
        var projectAllColumns = [
            { label: '状态', cellAttributes: { class: { fieldName: 'status' }},initialWidth: 75,fixedWidth:75},
            { label: '赋能项目', fieldName: 'projectName', type: 'text', editable: false},
            { label: '赋能目标', fieldName: 'projectTarget', type: 'text' , editable: false},
            { label: '完成月份', fieldName: 'projectCompleteDate', type: 'date' ,typeAttributes: dateFormat, editable: false },
            { label: '截止月份', fieldName: 'projectEndDate', type: 'date' ,typeAttributes: dateFormat, editable: false },
            { label: '销售负责人', fieldName: 'projectOwner', type: 'text' , editable: false }            
        ];
        //if(isDraft){
           projectAllColumns.push({ type: 'action', typeAttributes: { rowActions: otherAction } } ); 
        //}
        component.set('v.projectAllColumns',projectAllColumns);
    },
    handleFinanceRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        if(action.name == 'edit'){
            var row = event.getParam('row');
            if(row.index == 4){
                row.lastYear3 = row.lastYear3.replace('%','');
                row.lastYear2 = row.lastYear2.replace('%','');
                row.lastYear = row.lastYear.replace('%','');
                row.curYear = row.curYear.replace('%','');
                row.nextYear = row.nextYear.replace('%','');
                row.nextYear2 = row.nextYear2.replace('%','');
                component.set('v.isPercent',true);
                component.set('v.financeEditRow',row);
            }else{
                component.set('v.isPercent',false);
                component.set('v.financeEditRow',row);
            }            
            component.set('v.isEditFinanceForm',true);
        }
    },
    closeFinanceEdit : function(component, event, helper) {
        helper.refreshFinanceHelper(component);
        component.set('v.isEditFinanceForm',false);
    },
    financeSave : function(component, event, helper) {
        component.set('v.isloading',true);
        helper.financeSaveHelper(component);
    },
    deleteSOVClr : function(component, event, helper) {
        component.set('v.isDeleteSOV',true);       
    },
    addProjectNewRow : function(component, event, helper) {       
        component.set("v.editRecordId", "");
        component.set("v.isEditProjectForm", true);
    },
    onSubmit : function(component, event, helper) {
        component.set('v.isloading',true);
        event.preventDefault();
        var fields = event.getParam('fields');
        fields.CHCRM_KAP_Sov_AUTO_Title__c = component.get('v.sovTitleId'); // modify a field
        component.find('projectForm').submit(fields);
    },
    handleProjectRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.editRecordId", row.id);
        if(action.name == 'edit'){            
            component.set("v.isEditProjectForm", true);
        }else if(action.name == 'delete'){            
            component.set("v.isEditProjectForm", true);
            component.set("v.isDeleteProjectForm", true);
        }
    },
    closeProjectEdit : function(component, event, helper) {
        helper.refreshProjectHelper(component);
        component.set("v.isEditProjectForm", false);
        component.set("v.isDeleteProjectForm", false);
    },
    deleteProjectCrtl : function(component, event, helper) {
        helper.deleteProjectHelper(component);
    },
    refresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
       component.getEvent("DeleteSovEvent").fire();
    },
    closeDeleteSOV : function(component, event, helper){
        component.set('v.isDeleteSOV',false);    
    },
    deleteSOVItem : function(component, event, helper){
        component.set('v.isloading',true);
        helper.deleteSovHelper(component);  
    }
 
})