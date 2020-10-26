({
    initHelper : function(component) {
        var dateFormat = {  
            day: 'numeric',  
            month: 'numeric',  
            year: 'numeric',  
            hour: 'numeric',  
            minute: 'numeric',  
            second: 'numeric',  
            hour12: false}
        var eventColumns = [
            { label: 'Progress',cellAttributes: { class: { fieldName: 'progress' }},initialWidth: 120,fixedWidth:120},            
            { label: '主题', fieldName: 'eventUrl', type: 'url', typeAttributes: { label: { fieldName: 'Subject'}},initialWidth: 250},
            { label: '详细安排', fieldName: 'Description', type: 'text',initialWidth: 250},
            { label: 'Planned Start Date', fieldName: 'planStartDate', type: 'date' ,typeAttributes: dateFormat,initialWidth: 250},
            { label: 'Planned End Date', fieldName: 'planEndDate', type: 'date' ,typeAttributes: dateFormat,initialWidth: 250},
            { label: 'Actual Start Date', fieldName: 'acStartDate', type: 'date' ,typeAttributes: dateFormat,initialWidth: 250},
            { label: 'Actual Completion Date', fieldName: 'acEndDate', type: 'date' ,typeAttributes: dateFormat,initialWidth: 250},
            { label: '负责人', fieldName: 'owner', type: 'text' ,initialWidth: 150},
            { label: 'Status', fieldName: 'status', type: 'text' ,initialWidth: 150},  
            { label: '备注', fieldName: 'remark', type: 'text',initialWidth: 500}
        ];
        component.set('v.eventColumns',eventColumns); 
        var action = component.get("c.initDataList");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.eventDatatable',response.getReturnValue().eventDatatable);
            }
        });
        $A.enqueueAction(action);
    }
})