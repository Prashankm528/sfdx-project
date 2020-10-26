({
	getCountries : function (component, event, helper) {
        var action = component.get("c.getCountriesPicklist");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.allCountries', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    filterCountries : function (component, event, helper) {

        var currCountries = [];
        var mask = event.target.value;

        function containsMask(value) {
            return value.toLowerCase().startsWith(mask.toLowerCase());
        }

        if (mask) {
            var allCountries = component.get("v.allCountries");
            currCountries = allCountries.filter(containsMask).slice(0,5);
        }
        component.set('v.countries', currCountries);
    },

    getUser : function (component, event, helper) {

    	var action = component.get("c.getUser");

	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var usrInfo = response.getReturnValue();
                if(usrInfo != null) {
	            	component.set("v.user", usrInfo);
	            	component.set("v.selectedCountry", usrInfo.Country);
	            }
	        }
	        else {
	            console.log("Failed with state: " + state);
	        }
	    });

	    $A.enqueueAction(action);
    },

    saveUser : function (component, event, helper) {

    	var action = component.get("c.saveUser");
	    action.setParams({
	        "user": component.get("v.user"),
	        "country": component.get("v.selectedCountry")
	    });
	    $A.enqueueAction(action);
	}  
})