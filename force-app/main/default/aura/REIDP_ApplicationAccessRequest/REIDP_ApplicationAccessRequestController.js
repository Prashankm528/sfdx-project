({
    init: function(component, event, helper) {
        var nameLabel = $A.get("$Label.c.REIDP_NameLabel");
        var statusLabel = $A.get("$Label.c.REIDP_StatusLabel");
        component.set('v.columns', [
            {label: nameLabel,  fieldName: 'name', sortable: false, type: 'text'},
            {label: statusLabel, type: 'button', initialWidth: 250, sortable: false, 
             	typeAttributes: { 
                    label: { fieldName: 'actionLabel'}, 
                    name: {fieldName: 'request'}, 
                    disabled: {fieldName: 'actionDisabled'}, 
                    class: {fieldName: 'btnColor'}
                }
            },
        ]);
            helper.getAppList(component);
    },
    
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'requestApproval':
                helper.showRowDetails(component, row);
                break;
            default:
                helper.showRowDetails(component, row);
                break;
        }
    },
});