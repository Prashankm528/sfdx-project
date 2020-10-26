({
    doInit: function(component, event, helper) {
        const recordData = component.get('v.record');
        const valueField = component.get('v.valueField');

        //The first field in the config fields will always be the label field.
        component.set('v.label', recordData[1].value);

        //Find the nominated value field to assign for selection.
        component.set('v.value', recordData.filter(function(item) {
            return item.field === valueField;
        })[0].value);

        //Assign the correct slds layout.
        switch(component.get('v.layoutType')) {
            case 'inline':
                component.set('v.layoutClass', 'slds-list_inline');
                break;
            case 'horizontal':
                component.set('v.layoutClass', 'slds-list_horizontal slds-wrap');
                break;
            case 'stacked':
                component.set('v.layoutClass', 'slds-list_stacked');
                break;
            default:
                component.set('v.layoutClass', 'slds-list_inline');
                break;
        }
    }
});