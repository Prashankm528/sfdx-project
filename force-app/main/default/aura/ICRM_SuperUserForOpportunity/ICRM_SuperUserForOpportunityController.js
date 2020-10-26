({
    doinit : function(component, event, helper) {
        // Set the columns of the Table 
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text', sortable: true,initialWidth:125},   
            {label: 'BU', fieldName: 'ICRM_RBU__c', type: 'text', sortable: true,initialWidth: 20},
            {label: 'Email', fieldName: 'Email', type: 'text', sortable: true}
            
        ]);
        helper.getUserList(component, helper);
    },
    
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    },
    next: function (component, event, helper) {
        // For the Next Button Pagination
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        // For the Previous Button Pagination
        helper.previous(component, event);
    }
})