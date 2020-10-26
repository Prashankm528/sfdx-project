({
    doInit: function(component, event, helper) {
        const apexProvider = component.find("apexProvider");
        const action = component.get("c.getRecords");

        var params = {
            sObjectName: component.get('v.sObjectName'),
            fields: component.get('v.configFields'),
            filters: component.get('v.configFilters'),
            valueField: component.get('v.valueField'),
            sortBy: component.get('v.sortBy'),
            recordLimit: component.get('v.limit')
        };

        apexProvider.execute(action, params, function(error, data) {
            if (error) {
                console.error(error.message);
            } else {
                component.set('v.records', JSON.parse(data));
            }
        });
    },

    /*
    * Captures the values selected into selectedValues.
    */
    onChange: function(component, event, helper) {
        //The type of choice this is i.e. single or multiple.
        const choiceType = component.get('v.choiceType');
        //The current selected value, this is determined by the valueField configured.
        const targetValue = event.getSource().get('v.value');

        if (choiceType === 'single') {
            //If single just put the current value into an array.
            component.set('v.selectedValues', [targetValue]);
        } else {
            //Multiple values will have their isSelected attribute set, so filter out only those.
            var selectedValues = [];
            var options = component.find('options');
            options = Array.isArray(options) ? options : [options];

            Array.prototype.push.apply(selectedValues, options.filter(function(item) {
                return item.get('v.isSelected');
            }).map(function(item) {
                return item.get('v.value');
            }));

            component.set('v.selectedValues', selectedValues);
        }
    }
});