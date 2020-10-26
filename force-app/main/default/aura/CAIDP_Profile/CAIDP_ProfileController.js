({

	doInit : function(component, event, helper) {

		component.set('v.allCountries', helper.getCountries(component, event, helper));
		helper.getUser(component, event, helper);
	},

	editDetails : function(component, event, helper) {
		var mode = component.get("v.editMode");
		component.set("v.editMode", !mode);

		helper.getUser(component, event, helper);
	},

	cancel : function(component, event, helper) {
		component.set("v.editMode", false);

		helper.getUser(component, event, helper);
	},

	save : function(component, event, helper) {

		if(document.getElementById("countryCombobox").classList.contains('slds-is-open')) {
			document.getElementById("countryForm").classList.add('slds-has-error');
			document.getElementById("country-error-message").classList.remove('slds-hide');
		}
		else {
			helper.saveUser(component, event, helper);
			component.set("v.editMode", false);
			helper.getUser(component, event, helper);
		}	
	},

	onKeyUp: function(component, event, helper) {
		
		if (event.target.id == 'countryId') {
			// component.set("v.selectedCountry", "");
            helper.filterCountries(component, event, helper);
        }
    },

    checkPhone: function(component, event, helper) {

    	var value = event.getSource().get("v.value");
    	var regex = new RegExp('^[\\d\\s()+-]{7,25}$');
    	if (value != null && value != '' && !regex.test(value)) {
    		var staticLabel = $A.get("$Label.c.CastrolInvalidPhone");
            event.getSource().set("v.errors", [{message: staticLabel + ": " + value}]);
        } else {
            event.getSource().set("v.errors", null);
        }
    },

    showList: function(component, event, helper) {
        
        if(component.get("v.countries").length == 0) {
            document.getElementById("countryCombobox").classList.remove('slds-is-open');
        }
        else if(!document.getElementById("countryCombobox").classList.contains('slds-is-open')) {
            document.getElementById("countryCombobox").classList.add('slds-is-open');
        }
    },

    selectItem : function(component, event, helper) {
        
        if(document.getElementById("countryForm").classList.contains('slds-has-error')) {
        	document.getElementById("countryForm").classList.remove('slds-has-error');
			document.getElementById("country-error-message").classList.add('slds-hide');
        }
        component.set("v.selectedCountry", event.target.closest(".slds-listbox__item").id);
        console.log("country: " + component.get("v.selectedCountry"));
        component.set("v.countries", []);
    }
})