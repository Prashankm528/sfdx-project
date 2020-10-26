({
    doInit: function(component, event, helper) {
        var countryCode = component.get("c.getCountryCallingCodes");
        var defaultCountryCode = component.get("c.getDefaultCountryCode");
        countryCode.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countryList = response.getReturnValue();
                component.set('v.countryCode', countryList[0].value.split("_")[0]);
                component.set("v.countryCodes", response.getReturnValue());
            }
        });
        
        defaultCountryCode.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var defCcode = response.getReturnValue();
                if (defCcode !== null) {
                    component.find("comboCountry").set("v.value", defCcode.value);
                    component.find("comboCountry").set("v.class", defCcode.value.split("_")[1]);
                } else if (defCcode === null) {
                    var countryClass = component.get("v.countryCodes")[0].value;
                    component.find("comboCountry").set("v.value", countryClass);
                    component.find("comboCountry").set("v.class", countryClass.split("_")[1]);
                }
            }
        });
        
        $A.enqueueAction(countryCode);
        $A.enqueueAction(defaultCountryCode);
    },
    
    handleSelectedCode: function(component, event, helper) {
        component.find("comboCountry").set('v.class', event.getSource().get("v.value").split("_")[1]);
        component.set('v.countryCode', event.getSource().get("v.value").split("_")[0]);
    }
})