({
    // Set the columns of the Table
    doInit: function(component, event, helper) {
        component.set('v.mycolumns', [
            
            {label: 'Power BI Report',
            type: 'button',
             typeAttributes: {
            title: 'Click here to view Report',
            variant: 'Neutral',
            alternativeText: 'View',
            disabled: false,
            label: { fieldName: 'Name'},
                name: { fieldName: 'Name'},
            }},
        ]);
        helper.getPBListHandler(component,event);      
    },
    // handle on click on Report record 
    handleClick : function (component, event, helper) {
        var row = event.getParam('row');
        var selValue = row.Name;
        var appEvent = $A.get("e.c:ICRM_GetPBReportEvent");
        appEvent.setParams({
            "PBName" : selValue,
        });
        appEvent.fire();
    },
    // handle pagintaion for next button 
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    // handle pagintaion for previous button 
    previous: function (component, event, helper) {
        helper.previous(component, event);
    }
})